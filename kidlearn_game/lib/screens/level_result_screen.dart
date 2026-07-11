import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/level.dart';
import '../services/storage_service.dart';
import '../widgets/score_stars.dart';
import '../utils/app_colors.dart';
import 'play_screen.dart';

/// Layar hasil setelah menyelesaikan satu level.
class LevelResultScreen extends StatefulWidget {
  final GameLevel level;
  final int correct;
  final int total;

  const LevelResultScreen({
    super.key,
    required this.level,
    required this.correct,
    required this.total,
  });

  @override
  State<LevelResultScreen> createState() => _LevelResultScreenState();
}

class _LevelResultScreenState extends State<LevelResultScreen> {
  bool _newRecord = false;
  int _earned = 0;

  LevelResult get _result =>
      LevelResult(correct: widget.correct, total: widget.total);

  @override
  void initState() {
    super.initState();
    _save();
  }

  Future<void> _save() async {
    final storage = StorageService();
    final profile = await storage.currentProfile();
    if (profile == null) return;
    final isRecord = await storage.recordLevelResult(
        profile, widget.level.id, _result.stars, _result.percent.round());
    // Koin: 2 per jawaban benar + 5 per bintang.
    final earned = widget.correct * 2 + _result.stars * 5;
    profile.coins += earned;
    await storage.upsertProfile(profile);
    // Buka kelas berikutnya bila boss level lulus.
    if (widget.level.isBoss &&
        _result.passed(widget.level) &&
        profile.unlockedGrade == widget.level.grade) {
      profile.unlockedGrade = widget.level.grade + 1;
      await storage.upsertProfile(profile);
    }
    unawaited(storage.syncProfile(profile));
    if (mounted) {
      setState(() {
        _newRecord = isRecord;
        _earned = earned;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool passed = _result.passed(widget.level);
    final int pct = _result.percent.round();
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(passed ? '🎉' : '💪', style: const TextStyle(fontSize: 80))
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 8),
                Text(
                  passed ? 'Hebat!' : 'Coba Lagi, Hampir!',
                  style: GoogleFonts.nunito(
                      fontSize: 28, fontWeight: FontWeight.w900, color: kDark),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 20),
                ScoreStars(stars: _result.stars),
                const SizedBox(height: 12),
                if (_earned > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: kStar.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('🪙 +$_earned koin',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800, color: kAccent)),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.4, end: 0),
                const SizedBox(height: 12),
                ScoreLabel(score: widget.correct, total: widget.total),
                const SizedBox(height: 8),
                Text('$pct% benar · butuh ${widget.level.passPercent}% lulus',
                    style: GoogleFonts.nunito(
                        fontSize: 14, color: kMuted, fontWeight: FontWeight.w600)),
                if (_newRecord) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: kStar.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('🏆 Rekor Baru!',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800, color: kAccent)),
                  ).animate().fadeIn(delay: 600.ms).scale(),
                ],
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => PlayScreen(level: widget.level)),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: kMuted.withOpacity(0.4)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('🔄 Ulang',
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w800, color: kDark)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).popUntil((r) => r.isFirst),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('🏠 Selesai',
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                    ),
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
