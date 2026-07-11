import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/level.dart';
import '../models/achievement.dart';
import '../services/sfx_service.dart';
import '../services/tts_service.dart';
import '../services/storage_service.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/score_stars.dart';
import '../utils/app_colors.dart';
import 'play_screen.dart';

/// Layar hasil setelah menyelesaikan satu level.
class LevelResultScreen extends StatefulWidget {
  final GameLevel level;
  final int correct;
  final int total;
  final int comboBonus;

  const LevelResultScreen({
    super.key,
    required this.level,
    required this.correct,
    required this.total,
    this.comboBonus = 0,
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
    _playResultSound();
    _save();
  }

  /// Suara berjenjang: naik kelas (boss lulus) paling meriah, lalu sempurna,
  /// lalu naik level; gagal → semangat lembut. Musik "ditekan" agar sorak jelas.
  void _playResultSound() {
    final passed = _result.passed(widget.level);
    final sfx = SfxService.instance;
    final tts = TtsService.instance;
    if (passed && widget.level.isBoss) {
      // Naik kelas — perayaan terbesar + musik energik.
      sfx.duckMusic(restoreAfterMs: 3200);
      sfx.graduation();
      sfx.playMusic('home'); // trek ceria/energik untuk beranda berikutnya
      Future.delayed(const Duration(milliseconds: 900),
          () => tts.cheer('Selamat! Kamu naik kelas!'));
    } else if (passed && _result.stars >= 3) {
      sfx.duckMusic();
      sfx.perfect();
      Future.delayed(const Duration(milliseconds: 700),
          () => tts.cheer('Sempurna! Luar biasa!'));
    } else if (passed) {
      sfx.duckMusic();
      sfx.levelUp();
      Future.delayed(const Duration(milliseconds: 600),
          () => tts.cheer('Hebat! Naik level!'));
    } else {
      sfx.wrong();
      tts.encourage();
    }
  }

  Future<void> _save() async {
    final storage = StorageService();
    final profile = await storage.currentProfile();
    if (profile == null) return;
    final isRecord = await storage.recordLevelResult(
        profile, widget.level.id, _result.stars, _result.percent.round());
    // Koin: 2 per jawaban benar + 5 per bintang + bonus combo.
    final earned = widget.correct * 2 + _result.stars * 5 + widget.comboBonus;
    profile.coins += earned;
    await storage.upsertProfile(profile);
    // Buka kelas berikutnya bila boss level lulus.
    if (widget.level.isBoss &&
        _result.passed(widget.level) &&
        profile.unlockedGrade == widget.level.grade) {
      profile.unlockedGrade = widget.level.grade + 1;
      await storage.upsertProfile(profile);
    }
    // Tantangan harian (hanya bila lulus) + lencana pencapaian.
    ({int count, int target, bool justCompleted})? daily;
    if (_result.passed(widget.level)) {
      daily = await storage.recordDailyChallenge(profile);
    }
    final newBadges = Achievement.newlyEarned(profile);
    if (newBadges.isNotEmpty) {
      profile.badges.addAll(newBadges.map((a) => a.id));
      await storage.upsertProfile(profile);
    }
    unawaited(storage.syncProfile(profile));
    if (mounted) {
      setState(() {
        _newRecord = isRecord;
        _earned = earned;
        _dailyDone = daily?.justCompleted ?? false;
        _newBadges = newBadges;
      });
      _announceExtras();
    }
  }

  bool _dailyDone = false;
  List<Achievement> _newBadges = const [];

  /// Umumkan lencana baru & tantangan harian lewat dialog kecil beruntun.
  Future<void> _announceExtras() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    for (final b in _newBadges) {
      if (!mounted) return;
      await _popup('${b.emoji}  Lencana Baru!', b.title, b.desc);
    }
    if (_dailyDone && mounted) {
      await _popup('🎯  Tantangan Harian Selesai!',
          'Kamu main 3 level hari ini', '+20 koin bonus 🪙');
    }
  }

  Future<void> _popup(String head, String title, String sub) async {
    SfxService.instance.star();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(head,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w900, color: kDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 18, fontWeight: FontWeight.w800, color: kPrimary)),
            const SizedBox(height: 4),
            Text(sub,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 13, color: kMuted)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
              child: Text('Hore!',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool passed = _result.passed(widget.level);
    final int pct = _result.percent.round();
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          SafeArea(
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
          if (passed) ConfettiOverlay(count: widget.level.isBoss ? 46 : 24),
        ],
      ),
    );
  }
}
