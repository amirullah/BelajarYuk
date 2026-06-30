import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../models/question.dart';
import '../utils/app_colors.dart';
import '../widgets/game_button.dart';
import 'result_screen.dart';

const _kScience = Color(0xFFFFD000);

const _kQuestions = [
  Question(question: 'Hewan ini tinggal di...?', emoji: '🐘', options: ['Laut', 'Hutan/Savana', 'Kutub', 'Gurun'], correctIndex: 1),
  Question(question: 'Hewan ini bisa...?', emoji: '🦅', options: ['Berenang', 'Berlari', 'Terbang', 'Memanjat'], correctIndex: 2),
  Question(question: 'Tanaman butuh apa untuk tumbuh?', emoji: '🌱', options: ['Gula & garam', 'Es & salju', 'Air & cahaya', 'Pasir & angin'], correctIndex: 2),
  Question(question: 'Bintang ada di...?', emoji: '⭐', options: ['Laut', 'Hutan', 'Langit', 'Gunung'], correctIndex: 2),
  Question(question: 'Hewan ini makannya...?', emoji: '🐼', options: ['Ikan', 'Bambu', 'Daging', 'Rumput'], correctIndex: 1),
  Question(question: 'Hewan ini tinggal di...?', emoji: '🐧', options: ['Gurun', 'Hutan tropis', 'Kutub', 'Padang rumput'], correctIndex: 2),
  Question(question: 'Apa yang membuat pelangi?', emoji: '🌈', options: ['Angin kencang', 'Hujan & matahari', 'Salju', 'Petir'], correctIndex: 1),
  Question(question: 'Hewan ini bertelur...?', emoji: '🐢', options: ['Di pohon', 'Di air', 'Di pasir', 'Di salju'], correctIndex: 2),
  Question(question: 'Planet tempat kita tinggal?', emoji: '🌍', options: ['Mars', 'Venus', 'Bumi', 'Jupiter'], correctIndex: 2),
  Question(question: 'Hewan ini adalah...?', emoji: '🦓', options: ['Kuda', 'Zebra', 'Keledai', 'Rusa'], correctIndex: 1),
];

class ScienceGameScreen extends StatefulWidget {
  const ScienceGameScreen({super.key});

  @override
  State<ScienceGameScreen> createState() => _ScienceGameScreenState();
}

class _ScienceGameScreenState extends State<ScienceGameScreen> {
  int _current = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _answered = false;

  void _onAnswer(int idx) {
    if (_answered) return;
    final correct = _kQuestions[_current].correctIndex;
    setState(() {
      _selectedIndex = idx;
      _answered = true;
      if (idx == correct) _score++;
    });
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_current + 1 < _kQuestions.length) {
        setState(() {
          _current++;
          _selectedIndex = null;
          _answered = false;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              score: _score,
              total: _kQuestions.length,
              gameKey: 'science',
              gameColor: _kScience,
              onRetry: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ScienceGameScreen()),
                );
              },
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _kQuestions[_current];
    final progress = (_current + 1) / _kQuestions.length;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: _kScience,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '🔬 Sains',
          style: GoogleFonts.nunito(
              fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_current + 1}/${_kQuestions.length}',
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: _kScience.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(_kScience),
            minHeight: 6,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _kScience.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              'Skor: $_score',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_kScience.withOpacity(0.2), _kScience.withOpacity(0.05)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: _kScience.withOpacity(0.3), width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(q.emoji, style: const TextStyle(fontSize: 72))
                              .animate(key: ValueKey(_current))
                              .scale(
                                begin: const Offset(0, 0),
                                end: const Offset(1, 1),
                                duration: 400.ms,
                                curve: Curves.elasticOut,
                              ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              q.question,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: kDark,
                              ),
                            )
                                .animate(key: ValueKey('q$_current'))
                                .fadeIn(duration: 300.ms)
                                .slideY(begin: 0.2, end: 0, duration: 300.ms),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.0,
                    children: List.generate(q.options.length, (i) {
                      bool? isCorrect;
                      if (_answered && _selectedIndex == i) {
                        isCorrect = i == q.correctIndex;
                      } else if (_answered && i == q.correctIndex) {
                        isCorrect = true;
                      }
                      return GameButton(
                        text: q.options[i],
                        color: _kScience.withOpacity(0.2),
                        onPressed: _answered ? null : () => _onAnswer(i),
                        isCorrect: isCorrect,
                      )
                          .animate(key: ValueKey('btn${_current}_$i'))
                          .fadeIn(
                            duration: 300.ms,
                            delay: Duration(milliseconds: 100 * i),
                          )
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            duration: 300.ms,
                            delay: Duration(milliseconds: 100 * i),
                          );
                    }),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
