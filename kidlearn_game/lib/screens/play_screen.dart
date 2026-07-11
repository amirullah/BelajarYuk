import 'dart:async';
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
import '../utils/app_colors.dart';
import 'level_result_screen.dart';

/// Layar bermain satu level: soal ditampilkan satu per satu, jawaban
/// langsung diwarnai benar/salah, lalu lanjut otomatis.
class PlayScreen extends StatefulWidget {
  final GameLevel level;
  const PlayScreen({super.key, required this.level});

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

  SubjectInfo get _info => SubjectInfo.of(widget.level.subject);
  Question get _q => _questions[_index];

  /// Maskot Uku menyemangati bila anak diam terlalu lama.
  void _resetIdle() {
    _idleTimer?.cancel();
    if (_showHint) setState(() => _showHint = false);
    _idleTimer = Timer(const Duration(seconds: 14), () {
      if (mounted && !_locked) setState(() => _showHint = true);
    });
  }

  @override
  void initState() {
    super.initState();
    _questions = LevelService().buildQuestions(widget.level);
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
        do {
          _seqPool.shuffle();
        } while (_listEq(_seqPool, _q.sequence!));
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
    if (ok) {
      SfxService.instance.correct();
      // Selang-seling suara anak asli (klip) & pujian TTS agar bervariasi.
      if (SfxService.instance.hasVoice && _correct.isEven) {
        SfxService.instance.voice();
      } else {
        TtsService.instance.praise();
      }
      _combo++;
      if (_combo >= 3) _comboBonus += 2; // bonus koin saat combo panas
    } else {
      SfxService.instance.wrong();
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

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
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

            // ── Maskot Uku menyemangati saat lama diam ──
            if (_showHint)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Row(
                  children: [
                    Image.asset('assets/img/mascot.png', width: 40, height: 40),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _info.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text('Ayo, kamu pasti bisa! Coba baca lagi ya 💪',
                            style: GoogleFonts.nunito(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _info.color)),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0),

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
