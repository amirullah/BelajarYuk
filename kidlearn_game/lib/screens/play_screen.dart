import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/level.dart';
import '../models/question.dart';
import '../models/subject.dart';
import '../services/level_service.dart';
import '../services/sfx_service.dart';
import '../services/tts_service.dart';
import '../widgets/game_button.dart';
import '../widgets/uku_mascot.dart';
import '../utils/app_colors.dart';
import 'level_result_screen.dart';

/// Layar bermain satu level: soal ditampilkan satu per satu, jawaban
/// langsung diwarnai benar/salah, lalu lanjut otomatis.
class PlayScreen extends StatefulWidget {
  final GameLevel level;

  /// Seed opsional untuk membuat urutan soal deterministik (dipakai pengujian
  /// otomatis). Bila null, soal diacak seperti biasa.
  final int? seed;
  const PlayScreen({super.key, required this.level, this.seed});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late final List<Question> _questions;
  int _index = 0;
  int _correct = 0;
  int? _selected;
  bool _locked = false;
  bool? _fillCorrect;
  final TextEditingController _fill = TextEditingController();
  Timer? _timer;

  // ── State soal pasangkan ──
  String? _matchLeft;
  final Set<String> _matched = {};
  List<String> _rightOrder = [];
  String? _wrongRight;

  // ── State soal susun urutan ──
  List<String> _seqPool = [];
  final List<String> _seqPicked = [];

  Timer? _idleTimer;
  bool _showHint = false;
  String _hintText = '';

  // Uku "mengintip" menyemangati — kata-katanya selalu berganti (tak berulang
  // berturut-turut) agar tak membosankan.
  static const _hintPhrases = [
    'Ayo, kamu pasti bisa! 💪', 'Baca lagi pelan-pelan ya 🧐',
    'Huu-huu! Aku percaya padamu! 🌟', 'Tenang, pikirkan dulu ya 😊',
    'Semangat! Jawabannya dekat lho ✨', 'Kamu hebat, coba lagi! 🎉',
    'Yuk, pilih yang menurutmu benar! 👍', 'Jangan buru-buru, kamu bisa! 🦉',
    'Wah, kamu pintar! Ayo jawab 🌈', 'Uku temani kamu, semangat! ❤️',
  ];
  int _hintTurn = -1;
  // Arah masuk Uku: 0=kiri inline, 1=kanan inline,
  // 2=atas-tengah, 3=bawah-tengah, 4=pojok-kiriatas,
  // 5=pojok-kananas, 6=pojok-kiribawah, 7=pojok-kananbawah
  int _hintDir = 0;
  final _rng = Random();

  SubjectInfo get _info => SubjectInfo.of(widget.level.subject);
  Question get _q => _questions[_index];

  /// Maskot Uku menyemangati bila anak diam terlalu lama.
  void _resetIdle() {
    _idleTimer?.cancel();
    if (_showHint) setState(() => _showHint = false);
    // Lebih sering muncul (±9 dtk) agar Uku terasa hadir menemani.
    _idleTimer = Timer(const Duration(seconds: 9), () {
      if (!mounted || _locked) return;
      // Pilih frasa baru yang beda dari sebelumnya (selalu berganti).
      int next = _hintTurn;
      while (next == _hintTurn) {
        next = _rng.nextInt(_hintPhrases.length);
      }
      _hintTurn = next;
      setState(() {
        _hintText = _hintPhrases[next];
        _hintDir = _rng.nextInt(8); // 0-7: inline-kiri/kanan, atas/bawah, 4 pojok
        _showHint = true;
      });
      // Suara KHAS Uku (celoteh) saat mengintip menyemangati.
      SfxService.instance.ukuVoice();
    });
  }

  void _ukuTap() {
    SfxService.instance.ukuVoice();
    int next = _hintTurn;
    while (next == _hintTurn && _hintPhrases.length > 1) {
      next = _rng.nextInt(_hintPhrases.length);
    }
    setState(() { _hintTurn = next; _hintText = _hintPhrases[next]; });
  }

  /// Uku inline (dirs 0–1): besar, muncul dari kiri/kanan dengan gelembung kata.
  /// Tidak menutup soal karena berada di baris tersendiri antara soal & jawaban.
  Widget _ukuPeekInline() {
    final onRight = _hintDir == 1;
    const sz = 96.0;
    final uku = GestureDetector(
      onTap: _ukuTap,
      child: const UkuMascot(size: sz, bubble: false),
    );
    final bubble = Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _info.color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(_hintText,
            style: GoogleFonts.nunito(
                fontSize: 14, fontWeight: FontWeight.w800, color: _info.color)),
      ),
    );
    final row = Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: onRight
            ? [bubble, const SizedBox(width: 8), uku]
            : [uku, const SizedBox(width: 8), bubble],
      ),
    );
    // Dir 0: slide dari kiri + easeOutBack; Dir 1: slide dari kanan + slight rotate
    final base = row
        .animate(key: ValueKey(_hintTurn))
        .fadeIn(duration: 220.ms)
        .slideX(
            begin: onRight ? 0.55 : -0.55,
            end: 0,
            duration: 460.ms,
            curve: Curves.easeOutBack);
    if (onRight) {
      return base.then().rotate(begin: 0.04, end: 0, duration: 350.ms,
          curve: Curves.easeOut);
    }
    return base;
  }

  /// Uku muncul dari tepi/pojok layar (dirs 2–7).
  /// Posisi AKHIR selalu di DALAM batas layar (menghormati safe-area) sehingga
  /// Uku — terutama wajahnya — selalu terlihat. Efek "datang dari luar" murni
  /// dari animasi move(begin → zero); Stack.clipBehavior.hardEdge menyembunyikan
  /// Uku selama ia masih di luar batas Stack.
  Widget _ukuEdgePeek() {
    const ukuSz = 96.0;
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final safePad = mq.padding; // inset status-bar / nav-bar

    final uku = GestureDetector(
      onTap: _ukuTap,
      child: const UkuMascot(size: ukuSz, bubble: false),
    );

    double? left, right, top, bottom;
    double mx = 0, my = 0;
    const margin = 12.0; // jarak dari tepi dalam area aman

    switch (_hintDir) {
      case 2: // atas-tengah: Uku meluncur turun, wajah masuk dari atas
        left = sw / 2 - ukuSz / 2;
        top = safePad.top + margin;
        my = -(ukuSz + safePad.top + margin + 16);
        break;
      case 3: // bawah-tengah: Uku meluncur naik dari bawah
        left = sw / 2 - ukuSz / 2;
        bottom = safePad.bottom + margin;
        my = ukuSz + safePad.bottom + margin + 16;
        break;
      case 4: // pojok kiri-atas
        left = margin;
        top = safePad.top + margin;
        mx = -(ukuSz + margin + 16); my = -(ukuSz + safePad.top + margin + 16);
        break;
      case 5: // pojok kanan-atas
        right = margin;
        top = safePad.top + margin;
        mx = ukuSz + margin + 16; my = -(ukuSz + safePad.top + margin + 16);
        break;
      case 6: // pojok kiri-bawah
        left = margin;
        bottom = safePad.bottom + margin;
        mx = -(ukuSz + margin + 16); my = ukuSz + safePad.bottom + margin + 16;
        break;
      default: // 7 — pojok kanan-bawah
        right = margin;
        bottom = safePad.bottom + margin;
        mx = ukuSz + margin + 16; my = ukuSz + safePad.bottom + margin + 16;
        break;
    }

    var anim = uku
        .animate(key: ValueKey(_hintTurn))
        .fadeIn(duration: 260.ms)
        .move(
            begin: Offset(mx, my),
            end: Offset.zero,
            duration: 560.ms,
            curve: Curves.easeOutBack);

    switch (_hintDir) {
      case 2:
        anim = anim.then().shakeX(hz: 3, amount: 4, duration: 420.ms);
        break;
      case 3:
        anim = anim.then().moveY(
            begin: -8, end: 0, duration: 380.ms, curve: Curves.bounceOut);
        break;
      case 4:
        anim = anim.then().rotate(
            begin: -0.15, end: 0, duration: 480.ms, curve: Curves.elasticOut);
        break;
      case 5:
        anim = anim.then().scaleXY(
            begin: 0.8, end: 1.0, duration: 380.ms, curve: Curves.elasticOut);
        break;
      case 6:
        anim = anim.then()
            .rotate(begin: 0.1, end: -0.05, duration: 300.ms)
            .then()
            .rotate(begin: -0.05, end: 0, duration: 300.ms, curve: Curves.easeOut);
        break;
      default:
        anim = anim.then().scaleXY(
            begin: 1.2, end: 1.0, duration: 320.ms, curve: Curves.easeOut);
        break;
    }

    return Positioned(
      left: left, right: right, top: top, bottom: bottom,
      child: anim,
    );
  }

  @override
  void initState() {
    super.initState();
    _questions = LevelService(widget.seed).buildQuestions(widget.level);
    // Bila bank soal kosong, jangan sentuh _q (mencegah RangeError di initState);
    // build() menampilkan layar "soal belum tersedia".
    if (_questions.isEmpty) return;
    _setupMatching();
    _maybeAutoPlay();
    _resetIdle();
  }

  /// Untuk soal "dengar", bacakan otomatis audioText saat soal muncul.
  void _maybeAutoPlay() {
    if (_q.type == QuestionType.listening && (_q.audioText ?? '').isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          TtsService.instance.speak(_q.audioText!,
              subject: widget.level.subject,
              english: widget.level.subject == Subject.english);
        }
      });
    }
  }

  /// Siapkan urutan kolom kanan (acak) untuk soal pasangkan.
  void _setupMatching() {
    _matched.clear();
    _matchLeft = null;
    _wrongRight = null;
    if (_q.type == QuestionType.matching && _q.pairs != null) {
      _rightOrder = _q.pairs!.values.toList()..shuffle();
    } else {
      _rightOrder = [];
    }
    // Susun urutan: acak kolam sampai berbeda dari urutan benar.
    _seqPicked.clear();
    if (_q.type == QuestionType.sequence && _q.sequence != null) {
      _seqPool = List<String>.from(_q.sequence!);
      if (_seqPool.length > 1) {
        // Acak sampai beda dari urutan benar, TAPI batasi percobaan agar tak
        // pernah macet bila (mis.) semua elemen kebetulan sama.
        var tries = 0;
        do {
          _seqPool.shuffle();
        } while (_listEq(_seqPool, _q.sequence!) && ++tries < 12);
      }
    } else {
      _seqPool = [];
    }
  }

  bool _listEq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _seqPick(String item) {
    if (_locked || _seqPicked.contains(item)) return;
    setState(() => _seqPicked.add(item));
    SfxService.instance.tap();
    if (_seqPicked.length == _q.sequence!.length) {
      final ok = _listEq(_seqPicked, _q.sequence!);
      setState(() => _locked = true);
      if (ok) _correct++;
      _feedback(ok);
      _timer = Timer(const Duration(milliseconds: 1000), _next);
    }
  }

  void _seqRemove(int index) {
    if (_locked || index >= _seqPicked.length) return;
    setState(() => _seqPicked.removeAt(index));
  }

  void _tapLeft(String key) {
    if (_locked || _matched.contains(key)) return;
    setState(() => _matchLeft = key);
  }

  void _tapRight(String value) {
    if (_locked || _matchLeft == null) return;
    final expected = _q.pairs![_matchLeft!];
    if (expected == value) {
      setState(() {
        _matched.add(_matchLeft!);
        _matchLeft = null;
      });
      SfxService.instance.tap();
      if (_matched.length == _q.pairs!.length) {
        setState(() {
          _locked = true;
          _correct++;
        });
        _feedback(true);
        _timer = Timer(const Duration(milliseconds: 1000), _next);
      }
    } else {
      SfxService.instance.wrong();
      setState(() => _wrongRight = value);
      Timer(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _wrongRight = null);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _idleTimer?.cancel();
    _fill.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  // Umpan balik audio+visual: chime + seruan anak (pujian/semangat).
  bool _cheerOk = false;
  int _cheerTick = 0;
  int _combo = 0; // jawaban benar beruntun
  int _comboBonus = 0; // koin bonus dari combo (diteruskan ke hasil)
  void _feedback(bool ok) {
    SfxService.instance.stopUku();
    if (ok) {
      unawaited(SfxService.instance.duckMusic(restoreAfterMs: 2200));
      SfxService.instance.correct();
      SfxService.instance.cheer();
      // Pujian langsung — TTS punya startup async sendiri (~200ms) yang
      // menjadi jeda alami setelah chime. Tidak perlu tunda lebih.
      TtsService.instance.praise(subject: widget.level.subject);
      _combo++;
      if (_combo >= 3) _comboBonus += 2;
    } else {
      unawaited(SfxService.instance.duckMusic(restoreAfterMs: 1600));
      SfxService.instance.wrong();
      SfxService.instance.aww();
      TtsService.instance.encourage();
      _combo = 0;
    }
    _idleTimer?.cancel();
    setState(() {
      _cheerOk = ok;
      _cheerTick++; // memicu animasi lencana umpan balik
      _showHint = false;
    });
  }

  void _answer(int i) {
    if (_locked) return;
    final ok = i == _q.correctIndex;
    setState(() {
      _selected = i;
      _locked = true;
      if (ok) _correct++;
    });
    _feedback(ok);
    _timer = Timer(Duration(milliseconds: ok ? 1050 : 1000), _next);
  }

  void _answerFill() {
    if (_locked) return;
    final expected = (_q.answer ?? '').trim().toLowerCase();
    final given = _fill.text.trim().toLowerCase();
    final ok = expected.isNotEmpty && given == expected;
    setState(() {
      _locked = true;
      _fillCorrect = ok;
      if (ok) _correct++;
    });
    _feedback(ok);
    _timer = Timer(const Duration(milliseconds: 1150), _next);
  }

  void _next() {
    // Hentikan TTS pujian/semangat agar tidak terbawa ke soal berikutnya.
    TtsService.instance.stop();
    if (_index + 1 >= _questions.length) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => LevelResultScreen(
          level: widget.level,
          correct: _correct,
          total: _questions.length,
          comboBonus: _comboBonus,
        ),
      ));
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _locked = false;
      _fillCorrect = null;
      _fill.clear();
      _setupMatching();
      _showHint = false;
    });
    _maybeAutoPlay();
    _resetIdle();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(_info.name)),
        body: const Center(child: Text('Soal belum tersedia untuk level ini.')),
      );
    }
    final double progress = (_index + 1) / _questions.length;

    // Stack + clipBehavior.hardEdge memungkinkan Uku mengintip dari tepi layar
    // tanpa menutup soal (soal di area atas, Uku di tepi/pojok).
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          SafeArea(
            child: Column(
              children: [
            // ── Header: progress + skor ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: Colors.black12,
                        valueColor: AlwaysStoppedAnimation(_info.color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (_combo >= 3)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text('🔥x$_combo',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: kAccent))
                          .animate(key: ValueKey('combo_$_combo'))
                          .scale(
                              duration: 300.ms,
                              curve: Curves.elasticOut,
                              begin: const Offset(0.4, 0.4),
                              end: const Offset(1, 1)),
                    ),
                  Text('⭐ $_correct',
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w800, fontSize: 16))
                      .animate(key: ValueKey('score_$_correct'))
                      .scale(
                          duration: 300.ms,
                          curve: Curves.elasticOut,
                          begin: const Offset(1.4, 1.4),
                          end: const Offset(1, 1)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_info.emoji} ${_info.name} · Level ${widget.level.index} · Soal ${_index + 1}/${_questions.length}',
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kMuted),
                ),
              ),
            ),

            // ── Soal ──
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    key: ValueKey(_index),
                    children: [
                      if (_q.emoji.isNotEmpty)
                        Text(_q.emoji, style: const TextStyle(fontSize: 72))
                            .animate()
                            .scale(duration: 300.ms, curve: Curves.easeOut),
                      const SizedBox(height: 16),
                      Text(
                        _q.question,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            fontSize: 22, fontWeight: FontWeight.w800, color: kDark),
                      ).animate().fadeIn(duration: 250.ms),
                      const SizedBox(height: 8),
                      // Tombol bacakan (read-aloud) — bantu anak yang belum lancar baca.
                      IconButton(
                        onPressed: () => TtsService.instance.speak(
                          _q.audioText ?? _q.question,
                          subject: widget.level.subject,
                          english: widget.level.subject == Subject.english,
                        ),
                        icon: Icon(Icons.volume_up_rounded, color: _info.color),
                        iconSize: 30,
                        tooltip: 'Bacakan',
                      ),
                      // Lencana umpan balik yang meletup saat menjawab.
                      if (_locked && _q.type != QuestionType.matching)
                        Text(_cheerOk ? '🎉' : '💪',
                                style: const TextStyle(fontSize: 46))
                            .animate(key: ValueKey(_cheerTick))
                            .scale(
                                duration: 350.ms,
                                curve: Curves.elasticOut,
                                begin: const Offset(0.2, 0.2),
                                end: const Offset(1, 1))
                            .then()
                            .shakeX(hz: 3, amount: 2),
                    ],
                  ),
                ),
              ),
            ),

            // ── Uku inline (kiri/kanan): di ruangnya sendiri, tak menutup soal ──
            if (_showHint && _hintDir < 2) _ukuPeekInline(),

            // ── Opsi jawaban ── (beranimasi masuk tiap soal)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: _answerArea()
                  .animate(key: ValueKey('ans_$_index'))
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.25, end: 0, curve: Curves.easeOut),
            ),
          ],
        ),
          ),
          // ── Uku mengintip dari tepi/pojok (dirs 2–7) ──
          if (_showHint && _hintDir >= 2) _ukuEdgePeek(),
        ],
      ),
    );
  }

  Widget _answerArea() {
    switch (_q.type) {
      case QuestionType.trueFalse:
        return _tfButtons();
      case QuestionType.fillBlank:
        return _fillInput();
      case QuestionType.matching:
        return _matchingArea();
      case QuestionType.imageChoice:
        return _imageGrid();
      case QuestionType.sequence:
        return _sequenceArea();
      default:
        return _mcGrid();
    }
  }

  Widget _seqChip(String label, {required VoidCallback? onTap, required bool filled}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: filled ? _info.color : kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: filled ? _info.color : kMuted.withOpacity(0.3), width: 2),
        ),
        child: Text(label,
            style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: filled ? Colors.white : kDark)),
      ),
    );
  }

  Widget _sequenceArea() {
    final seq = _q.sequence!;
    return Column(
      children: [
        Text('Ketuk sesuai urutan yang benar',
            style: GoogleFonts.nunito(fontSize: 12, color: kMuted)),
        const SizedBox(height: 10),
        // Slot jawaban (urutan yang sudah dipilih).
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _info.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: List.generate(seq.length, (i) {
              final has = i < _seqPicked.length;
              return (has
                      ? _seqChip(_seqPicked[i],
                          filled: true,
                          onTap: _locked ? null : () => _seqRemove(i))
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: kMuted.withOpacity(0.3),
                                width: 2,
                                style: BorderStyle.solid),
                          ),
                          child: Text('${i + 1}',
                              style: GoogleFonts.nunito(
                                  fontSize: 18, color: kMuted)),
                        ))
                  .animate(key: ValueKey('slot_${_index}_${i}_$has'))
                  .fadeIn(duration: 200.ms)
                  .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1));
            }),
          ),
        ),
        const SizedBox(height: 14),
        // Kolam pilihan.
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: _seqPool.map((item) {
            final used = _seqPicked.contains(item);
            return Opacity(
              opacity: used ? 0.25 : 1,
              child: _seqChip(item,
                  filled: false,
                  onTap: (_locked || used) ? null : () => _seqPick(item)),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Grid pilih-gambar: emoji besar yang bisa diketuk.
  Widget _imageGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.35,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: List.generate(_q.options.length, (i) {
        final state = _correctness(i);
        Color bg = kSurface;
        Color border = kMuted.withOpacity(0.25);
        if (state == true) {
          bg = kSuccess.withOpacity(0.18);
          border = kSuccess;
        } else if (state == false) {
          bg = kError.withOpacity(0.18);
          border = kError;
        }
        return GestureDetector(
          onTap: () => _answer(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border, width: 2.5),
            ),
            // Kecilkan otomatis agar emoji/gambar tak terpotong.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(_q.options[i],
                  style: const TextStyle(fontSize: 52)),
            ),
          )
              .animate(target: state == false ? 1 : 0)
              .shakeX(amount: 4, duration: 400.ms),
        );
      }),
    );
  }

  Widget _matchingArea() {
    final keys = _q.pairs!.keys.toList();
    Widget cell(String label, {required bool left}) {
      final matched = left
          ? _matched.contains(label)
          : _matched.any((k) => _q.pairs![k] == label);
      final selected = left && _matchLeft == label;
      final wrong = !left && _wrongRight == label;
      Color bg = kSurface;
      if (matched) {
        bg = kSuccess;
      } else if (wrong) {
        bg = kError;
      } else if (selected) {
        bg = _info.color;
      }
      final white = matched || wrong || selected;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: GestureDetector(
          onTap: matched
              ? null
              : () => left ? _tapLeft(label) : _tapRight(label),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kMuted.withOpacity(0.25)),
            ),
            child: Center(
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: white ? Colors.white : kDark)),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Text('Pasangkan yang cocok',
            style: GoogleFonts.nunito(fontSize: 12, color: kMuted)),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Column(
                    children: keys.map((k) => cell(k, left: true)).toList())),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    children:
                        _rightOrder.map((v) => cell(v, left: false)).toList())),
          ],
        ),
      ],
    );
  }

  bool? _correctness(int i) {
    if (!_locked) return null;
    if (i == _q.correctIndex) return true;
    if (i == _selected) return false;
    return null;
  }

  Widget _fillInput() {
    Color border = _info.color;
    if (_locked) border = _fillCorrect == true ? kSuccess : kError;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _fill,
          enabled: !_locked,
          textAlign: TextAlign.center,
          onSubmitted: (_) => _answerFill(),
          style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            hintText: 'Ketik jawaban…',
            filled: true,
            fillColor: kSurface,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: border, width: 2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: border, width: 2)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: border, width: 2)),
          ),
        ),
        if (_locked && _fillCorrect == false) ...[
          const SizedBox(height: 8),
          Text('Jawaban: ${_q.answer}',
              style: GoogleFonts.nunito(
                  color: kSuccess, fontWeight: FontWeight.w700)),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: GameButton(
            text: 'Cek',
            color: _info.color,
            onPressed: _locked ? null : _answerFill,
          ),
        ),
      ],
    );
  }

  Widget _mcGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.4,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: List.generate(_q.options.length, (i) {
        return GameButton(
          text: _q.options[i],
          color: _info.color,
          isCorrect: _correctness(i),
          onPressed: () => _answer(i),
        );
      }),
    );
  }

  Widget _tfButtons() {
    return Row(
      children: [
        Expanded(
          child: GameButton(
            text: '✓ Benar',
            color: kSuccess,
            isCorrect: _correctness(0),
            onPressed: () => _answer(0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GameButton(
            text: '✗ Salah',
            color: kError,
            isCorrect: _correctness(1),
            onPressed: () => _answer(1),
          ),
        ),
      ],
    );
  }
}
