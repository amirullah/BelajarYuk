import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rocketController;
  late Animation<double> _rocketAnimation;

  @override
  void initState() {
    super.initState();
    _rocketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _rocketAnimation = Tween<double>(begin: -12.0, end: 12.0).animate(
      CurvedAnimation(parent: _rocketController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _rocketController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF3B37C8),
              Color(0xFF2196F3),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _rocketAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _rocketAnimation.value),
                      child: child,
                    );
                  },
                  child: const Text(
                    '🚀',
                    style: TextStyle(fontSize: 80),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'BelajarYuk! 🌟',
                  style: GoogleFonts.nunito(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      const Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Color(0x44000000),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 300.ms)
                    .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 300.ms),
                const SizedBox(height: 12),
                Text(
                  'Game Edukasi Seru',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.85),
                    letterSpacing: 0.5,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 600.ms),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFloatingEmoji('⭐', 0),
                    const SizedBox(width: 16),
                    _buildFloatingEmoji('🎉', 200),
                    const SizedBox(width: 16),
                    _buildFloatingEmoji('🌈', 400),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 900.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingEmoji(String emoji, int delayMs) {
    return Text(
      emoji,
      style: const TextStyle(fontSize: 32),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(
          begin: 0,
          end: -8,
          duration: 900.ms,
          delay: Duration(milliseconds: delayMs),
          curve: Curves.easeInOut,
        );
  }
}
