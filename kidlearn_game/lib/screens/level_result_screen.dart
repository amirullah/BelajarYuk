import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/level.dart';
import '../models/subject.dart';
import '../models/profile.dart';
import '../models/achievement.dart';
import '../services/sfx_service.dart';
import '../services/tts_service.dart';
import '../services/storage_service.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/score_stars.dart';
import '../widgets/uku_mascot.dart';
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
  bool _gradeUp = false;
  int _subjectsCleared = 0; // mapel yang boss-nya sudah lulus di kelas ini
  final _rng = Random();
  int _chestBonus = 0; // Peti Kejutan (hadiah acak) — 0 = tak muncul
  bool _chestOpened = false;

  LevelResult get _result =>
      LevelResult(correct: widget.correct, total: widget.total);

  /// Berapa mapel yang boss (level 12) kelas [grade]-nya sudah lulus.
  int _subjectsClearedFor(ChildProfile p, int grade) =>
      GameLevel.subjectsCleared(grade, p.isPassed);

  @override
  void initState() {
    super.initState();
    // Suara perayaan menunggu hasil _save() agar "naik kelas" hanya berbunyi
    // saat benar-benar naik (semua mapel selesai). Kasus non-boss tak menunggu.
    if (!(widget.level.isBoss && _result.passed(widget.level))) {
      _celebrate(false);
    }
    _save();
  }

  /// Suara berjenjang: naik kelas (semua mapel lulus) paling meriah, lalu
  /// boss selesai, sempurna, naik level; gagal → semangat lembut.
  void _celebrate(bool gradeUp) {
    final passed = _result.passed(widget.level);
    final sfx = SfxService.instance;
    final tts = TtsService.instance;
    if (passed && widget.level.isBoss && gradeUp) {
      // NAIK KELAS — perayaan terbesar + musik energik.
      sfx.duckMusic(restoreAfterMs: 3200);
      sfx.graduation();
      sfx.playMusic('home');
      Future.delayed(const Duration(milliseconds: 900),
          () => tts.cheer('Selamat! Kamu naik kelas!'));
    } else if (passed && widget.level.isBoss) {
      // Boss lulus, tapi belum semua mapel → rayakan boss, belum naik kelas.
      sfx.duckMusic();
      sfx.graduation();
      Future.delayed(const Duration(milliseconds: 800),
          () => tts.cheer('Hebat! Boss selesai!'));
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
    final wasPassed = profile.isPassed(widget.level.id); // sudah pernah lulus?
    final isRecord = await storage.recordLevelResult(
        profile, widget.level.id, _result.stars, _result.percent.round());
    // Koin: 2 per jawaban benar + 5 per bintang + bonus combo.
    final earned = widget.correct * 2 + _result.stars * 5 + widget.comboBonus;
    profile.coins += earned;
    // Peti Kejutan: sesekali (±1 dari 3 kelulusan) muncul hadiah koin ACAK —
    // kejutan tak terduga bikin anak ingin main lagi. Pakai koin (tanpa konsep baru).
    if (_result.passed(widget.level) && _rng.nextInt(3) == 0) {
      _chestBonus = const [5, 10, 15, 20, 30][_rng.nextInt(5)];
      profile.coins += _chestBonus;
    }
    await storage.upsertProfile(profile);
    // Naik kelas HANYA bila boss (level 12) SEMUA mapel di kelas ini sudah
    // lulus — mencegah anak lompat kelas hanya dengan menyelesaikan 1 mapel.
    bool gradeUp = false;
    final gradeCleared = _subjectsClearedFor(profile, widget.level.grade);
    if (widget.level.isBoss &&
        _result.passed(widget.level) &&
        profile.unlockedGrade == widget.level.grade &&
        gradeCleared == Subject.values.length) {
      profile.unlockedGrade = widget.level.grade + 1;
      await storage.upsertProfile(profile);
      gradeUp = true;
    }
    // Tantangan harian hanya dihitung saat pertama kali lulus level (bukan
    // ulang) agar tidak bisa "diakali" dengan mengulang level yang sama.
    ({int count, int target, bool justCompleted})? daily;
    if (_result.passed(widget.level) && !wasPassed) {
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
        _gradeUp = gradeUp;
        _subjectsCleared = _subjectsClearedFor(profile, widget.level.grade);
      });
      // Perayaan boss/naik-kelas menunggu di sini agar akurat.
      if (widget.level.isBoss && _result.passed(widget.level)) {
        _celebrate(gradeUp);
      }
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
                UkuMascot(
                  size: 104,
                  greeting: passed ? 'Hore, kamu berhasil! 🎉' : 'Coba lagi ya, semangat! 💪',
                ),
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
                // Info naik kelas: butuh SEMUA mapel selesai.
                if (widget.level.isBoss && _result.passed(widget.level)) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: (_gradeUp ? kSuccess : kPrimary).withOpacity(0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                        _gradeUp
                            ? '🎉 Semua mapel selesai — naik ke Kelas ${widget.level.grade + 1}!'
                            : '📚 Boss selesai! Tuntaskan semua mapel untuk naik kelas ($_subjectsCleared/${Subject.values.length})',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            color: _gradeUp ? kSuccess : kPrimary)),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0),
                ],
                // ── Peti Kejutan (hadiah acak) — ketuk untuk membuka ──
                if (_chestBonus > 0) ...[
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _chestOpened
                        ? null
                        : () {
                            setState(() => _chestOpened = true);
                            SfxService.instance.coin();
                            TtsService.instance
                                .ukuSay('Huu-huu! Ada kejutan untukmu!');
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: kStar.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: kStar, width: 2),
                      ),
                      child: _chestOpened
                          ? Text('🎉 Peti Kejutan: +$_chestBonus koin! 🪙',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w900, color: kDark))
                          : Text('🎁 Ketuk Peti Kejutan!',
                                  style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w900,
                                      color: kDark))
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(
                                  begin: const Offset(1, 1),
                                  end: const Offset(1.06, 1.06),
                                  duration: 600.ms),
                    ),
                  ).animate().fadeIn(delay: 650.ms).shakeX(hz: 3, amount: 2),
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
