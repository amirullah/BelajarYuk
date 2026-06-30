import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import 'math_game_screen.dart';
import 'word_game_screen.dart';
import 'science_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _mathBest = 0;
  int _wordBest = 0;
  int _scienceBest = 0;

  @override
  void initState() {
    super.initState();
    _loadBestScores();
  }

  Future<void> _loadBestScores() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _mathBest = prefs.getInt('best_math') ?? 0;
        _wordBest = prefs.getInt('best_word') ?? 0;
        _scienceBest = prefs.getInt('best_science') ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'BelajarYuk! 🌟',
          style: GoogleFonts.nunito(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEDE9FF),
              Color(0xFFF8F9FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Pelajaran! 🎮',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kDark,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.2, end: 0, duration: 400.ms),
                const SizedBox(height: 4),
                Text(
                  'Ayo belajar sambil bermain!',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms),
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _GameCard(
                          emoji: '🔢',
                          title: 'Matematika',
                          subtitle: 'Tambah & Kurang',
                          gradientColors: const [
                            Color(0xFFFF6B6B),
                            Color(0xFFFF8E53),
                          ],
                          bestScore: _mathBest,
                          delay: 0,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MathGameScreen(),
                              ),
                            );
                            _loadBestScores();
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _GameCard(
                          emoji: '📖',
                          title: 'Kata-Kata',
                          subtitle: 'Kosa Kata Indonesia',
                          gradientColors: const [
                            Color(0xFF4ECDC4),
                            Color(0xFF44B89D),
                          ],
                          bestScore: _wordBest,
                          delay: 150,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WordGameScreen(),
                              ),
                            );
                            _loadBestScores();
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _GameCard(
                          emoji: '🔬',
                          title: 'Sains',
                          subtitle: 'Hewan & Alam',
                          gradientColors: const [
                            Color(0xFFFFE66D),
                            Color(0xFFFFD000),
                          ],
                          bestScore: _scienceBest,
                          delay: 300,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ScienceGameScreen(),
                              ),
                            );
                            _loadBestScores();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    '✨ Selamat Belajar! ✨',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: kPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final int bestScore;
  final int delay;
  final VoidCallback onTap;

  const _GameCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.bestScore,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 52),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 3,
                            color: Color(0x33000000),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          'Terbaik: $bestScore/10',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: Duration(milliseconds: delay + 200))
        .slideY(
          begin: 0.4,
          end: 0,
          duration: 500.ms,
          delay: Duration(milliseconds: delay + 200),
          curve: Curves.easeOutBack,
        );
  }
}
