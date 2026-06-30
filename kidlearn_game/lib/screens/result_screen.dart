import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../widgets/score_stars.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final String gameKey;
  final Color gameColor;
  final VoidCallback onRetry;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.gameKey,
    required this.gameColor,
    required this.onRetry,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _stars = 0;
  bool _isNewRecord = false;

  @override
  void initState() {
    super.initState();
    _stars = _calculateStars();
    _saveBestScore();
  }

  int _calculateStars() {
    if (widget.score <= 4) return 1;
    if (widget.score <= 7) return 2;
    return 3;
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = prefs.getInt('best_${widget.gameKey}') ?? 0;
    if (widget.score > currentBest) {
      await prefs.setInt('best_${widget.gameKey}', widget.score);
      if (mounted) setState(() => _isNewRecord = true);
    }
  }

  String get _motivationalMessage {
    if (widget.score == widget.total) {
      return 'SEMPURNA! Kamu Luar Biasa! 🎉🎊';
    } else if (widget.score >= 8) {
      return 'Hebat Sekali! Hampir Sempurna! 🌟';
    } else if (widget.score >= 5) {
      return 'Bagus! Terus Berlatih! 💪';
    } else {
      return 'Jangan Menyerah! Coba Lagi! 🚀';
    }
  }

  Color get _messageColor {
    if (widget.score >= 8) return const Color(0xFF00B894);
    if (widget.score >= 5) return const Color(0xFF0984E3);
    return const Color(0xFFE17055);
  }

  String _starsEmoji() {
    if (_stars == 3) return '🏆';
    if (_stars == 2) return '😊';
    return '💪';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.gameColor.withOpacity(0.15),
              kBg,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hasil Kamu! 🎮',
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: kDark,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.3, end: 0, duration: 400.ms),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: widget.gameColor.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (_isNewRecord)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE66D),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '🏆 Rekor Baru!',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF6D4C00),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 200.ms)
                            .scale(delay: 200.ms),
                      if (_isNewRecord) const SizedBox(height: 12),
                      Text(
                        _starsEmoji(),
                        style: const TextStyle(fontSize: 60),
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          ),
                      const SizedBox(height: 16),
                      ScoreStars(stars: _stars),
                      const SizedBox(height: 20),
                      ScoreLabel(score: widget.score, total: widget.total),
                      const SizedBox(height: 12),
                      Text(
                        _motivationalMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _messageColor,
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onRetry,
                        icon: const Text('🔄', style: TextStyle(fontSize: 20)),
                        label: Text(
                          'Coba Lagi',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.gameColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 1000.ms)
                        .slideY(begin: 0.3, end: 0, delay: 1000.ms),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).popUntil(
                            (route) => route.isFirst,
                          );
                        },
                        icon: const Text('🏠', style: TextStyle(fontSize: 20)),
                        label: Text(
                          'Menu Utama',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: kDark,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: widget.gameColor,
                              width: 2,
                            ),
                          ),
                          elevation: 2,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 1100.ms)
                        .slideY(begin: 0.3, end: 0, delay: 1100.ms),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
