import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../models/question.dart';
import '../utils/app_colors.dart';
import '../widgets/game_button.dart';
import 'result_screen.dart';

const _kQuestions = [
  Question(question: 'Ini adalah...?', emoji: '🦁', options: ['Singa', 'Harimau', 'Gajah', 'Kuda'], correctIndex: 0),
  Question(question: 'Buah ini namanya...?', emoji: '🍎', options: ['Jeruk', 'Mangga', 'Apel', 'Pisang'], correctIndex: 2),
  Question(question: 'Gambar apa ini?', emoji: '🌧️', options: ['Angin', 'Hujan', 'Panas', 'Salju'], correctIndex: 1),
  Question(question: 'Ini adalah...?', emoji: '🚀', options: ['Kapal', 'Pesawat', 'Mobil', 'Roket'], correctIndex: 3),
  Question(question: 'Hewan ini namanya...?', emoji: '🦋', options: ['Lebah', 'Kupu-kupu', 'Capung', 'Nyamuk'], correctIndex: 1),
  Question(question: 'Buah ini namanya...?', emoji: '🍌', options: ['Pisang', 'Mangga', 'Pepaya', 'Nanas'], correctIndex: 0),
  Question(question: 'Ini adalah...?', emoji: '⛵', options: ['Perahu', 'Kapal Selam', 'Kapal Udara', 'Kereta'], correctIndex: 0),
  Question(question: 'Hewan ini namanya...?', emoji: '🐘', options: ['Kuda Nil', 'Badak', 'Gajah', 'Jerapah'], correctIndex: 2),
  Question(question: 'Ini adalah...?', emoji: '🌺', options: ['Daun', 'Bunga', 'Akar', 'Biji'], correctIndex: 1),
  Question(question: 'Buah ini namanya...?', emoji: '🍇', options: ['Stroberi', 'Anggur', 'Bluberi', 'Kismis'], correctIndex: 1),
];

class WordGameScreen extends StatefulWidget {
  const WordGameScreen({super.key});

  @override
  State<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen> {
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
              gameKey: 'word',
              gameColor: kWord,
              onRetry: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WordGameScreen()),
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
        backgroundColor: kWord,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '📖 Kata-Kata',
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
            backgroundColor: kWord.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(kWord),
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
                          color: kWord.withOpacity(0.1),
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
                                color: kWord,
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
                          colors: [kWord.withOpacity(0.15), kWord.withOpacity(0.05)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: kWord.withOpacity(0.2), width: 2),
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
                          Text(
                            q.question,
                            style: GoogleFonts.nunito(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: kDark,
                            ),
                          )
                              .animate(key: ValueKey('q$_current'))
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.2, end: 0, duration: 300.ms),
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
                    childAspectRatio: 2.2,
                    children: List.generate(q.options.length, (i) {
                      bool? isCorrect;
                      if (_answered && _selectedIndex == i) {
                        isCorrect = i == q.correctIndex;
                      } else if (_answered && i == q.correctIndex) {
                        isCorrect = true;
                      }
                      return GameButton(
                        text: q.options[i],
                        color: kWord.withOpacity(0.15),
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
