import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreStars extends StatelessWidget {
  final int stars;
  final double size;

  const ScoreStars({
    super.key,
    required this.stars,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final bool filled = index < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            filled ? '⭐' : '☆',
            style: TextStyle(
              fontSize: size,
              color: filled ? null : Colors.grey.shade400,
            ),
          )
              .animate(delay: Duration(milliseconds: 300 + index * 200))
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 200.ms),
        );
      }),
    );
  }
}

class ScoreLabel extends StatelessWidget {
  final int score;
  final int total;

  const ScoreLabel({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$score dari $total',
      style: GoogleFonts.nunito(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF2D3436),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 500.ms);
  }
}
