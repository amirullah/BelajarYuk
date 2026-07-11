import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Hujan konfeti sederhana (emoji berwarna) untuk momen kemenangan.
/// Ringan — hanya memakai flutter_animate, tanpa paket tambahan.
class ConfettiOverlay extends StatelessWidget {
  final int count;
  const ConfettiOverlay({super.key, this.count = 24});

  static const _bits = ['🎉', '⭐', '🌟', '✨', '🎊', '🥳', '💙', '🏆'];

  @override
  Widget build(BuildContext context) {
    final rng = Random(7);
    final size = MediaQuery.of(context).size;
    return IgnorePointer(
      child: Stack(
        children: List.generate(count, (i) {
          final startX = rng.nextDouble() * size.width;
          final drift = (rng.nextDouble() - 0.5) * 120;
          final delay = (rng.nextInt(600)).ms;
          final dur = (1400 + rng.nextInt(1400)).ms;
          final emoji = _bits[rng.nextInt(_bits.length)];
          final fontSize = 18.0 + rng.nextDouble() * 20;
          return Positioned(
            left: startX,
            top: -40,
            child: Text(emoji, style: TextStyle(fontSize: fontSize))
                .animate(onPlay: (c) => c.repeat())
                .moveY(
                    begin: -40,
                    end: size.height + 40,
                    duration: dur,
                    delay: delay,
                    curve: Curves.easeIn)
                .moveX(begin: 0, end: drift, duration: dur, delay: delay)
                .rotate(begin: 0, end: rng.nextDouble() * 2 - 1, duration: dur, delay: delay)
                .fadeIn(duration: 200.ms, delay: delay),
          );
        }),
      ),
    );
  }
}
