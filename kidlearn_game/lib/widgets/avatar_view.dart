import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/avatars.dart';

/// Menampilkan avatar (emoji). Avatar tier "bergerak" (Avatars.animated)
/// dianimasikan terus-menerus agar terlihat hidup & istimewa — pendorong anak
/// mengejar koin untuk membelinya.
class AvatarView extends StatelessWidget {
  final String emoji;
  final double size;
  const AvatarView(this.emoji, {super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final text = Text(emoji, style: TextStyle(fontSize: size));
    if (!Avatars.isAnimated(emoji)) return text;
    // Denyut + goyang halus, berulang selamanya.
    return text
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.15, 1.15),
            duration: 850.ms,
            curve: Curves.easeInOut)
        .rotate(begin: -0.03, end: 0.03, duration: 850.ms);
  }
}
