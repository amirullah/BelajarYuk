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

  SubjectInfo get _info => SubjectInfo.of(widget.level.subject);
  Question get _q => _questions[_index];

  @override
  void initState() {
    super.initState();
    _questions = LevelService().buildQuestions(widget.level);
    _setupMatching();
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
        SfxService.instance.correct();
        _timer = Timer(const Duration(milliseconds: 800), _next);
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
    _fill.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  void _answer(int i) {
    if (_locked) return;
    final ok = i == _q.correctIndex;
    setState(() {
      _selected = i;
      _locked = true;
      if (ok) _correct++;
    });
    ok ? SfxService.instance.correct() : SfxService.instance.wrong();
    _timer = Timer(const Duration(milliseconds: 900), _next);
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
    ok ? SfxService.instance.correct() : SfxService.instance.wrong();
    _timer = Timer(const Duration(milliseconds: 1100), _next);
  }

  void _next() {
    if (_index + 1 >= _questions.length) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => LevelResultScreen(
          level: widget.level,
          correct: _correct,
          total: _questions.length,
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
    });
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
                  const SizedBox(width: 12),
                  Text('⭐ $_correct',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800, fontSize: 16)),
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
                          english: widget.level.subject == Subject.english,
                        ),
                        icon: Icon(Icons.volume_up_rounded, color: _info.color),
                        iconSize: 30,
                        tooltip: 'Bacakan',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Opsi jawaban ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: _answerArea(),
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
      default:
        return _mcGrid();
    }
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
