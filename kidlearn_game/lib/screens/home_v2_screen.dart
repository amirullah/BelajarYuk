import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/subject.dart';
import '../models/profile.dart';
import '../services/sfx_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import 'level_map_screen.dart';
import 'about_screen.dart';
import 'avatar_shop_screen.dart';
import 'settings_screen.dart';
import 'leaderboard_screen.dart';
import 'achievements_screen.dart';

/// Beranda BelajarYuk! 2.0 — pilih mata pelajaran (Kelas 1).
class HomeV2Screen extends StatefulWidget {
  const HomeV2Screen({super.key});

  @override
  State<HomeV2Screen> createState() => _HomeV2ScreenState();
}

class _HomeV2ScreenState extends State<HomeV2Screen> {
  final _storage = StorageService();
  ChildProfile? _profile;

  @override
  void initState() {
    super.initState();
    _init();
    SfxService.instance.playMusic('home'); // musik beranda (bila diaktifkan)
  }

  Future<void> _init() async {
    final p = await _storage.ensureLocalProfile();
    await _storage.touchStreak(p);
    if (mounted) setState(() => _profile = p);
    // Hadiah harian saat pertama buka hari ini.
    final reward = await _storage.claimDailyReward(p);
    if (reward > 0 && mounted) {
      setState(() {});
      SfxService.instance.coin();
      _showDailyReward(reward);
    }
  }

  Future<void> _showDailyReward(int coins) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(children: [
          Image.asset('assets/img/mascot.png', width: 80, height: 80),
          const SizedBox(height: 8),
          Text('Hadiah Harian! 🎁',
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w900, color: kDark)),
        ]),
        content: Text('Selamat datang kembali! Ini +$coins koin 🪙 untukmu.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 14, color: kMuted)),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
              child: Text('Terima kasih!',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAccount() async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()));
    _init(); // segarkan profil aktif setelah kembali
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _init,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Sapaan + maskot ──
              Row(
                children: [
                  Text(_profile?.avatar ?? '🦊',
                      style: const TextStyle(fontSize: 44)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Halo, ${_profile?.name ?? "Pemain"}! 👋',
                            style: GoogleFonts.nunito(
                                fontSize: 22, fontWeight: FontWeight.w900)),
                        Text(
                            (_profile?.streak ?? 0) > 1
                                ? '🔥 ${_profile!.streak} hari beruntun — hebat!'
                                : 'Ayo belajar sambil bermain — Kelas 1',
                            style: GoogleFonts.nunito(
                                fontSize: 13, color: kMuted)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const AvatarShopScreen()));
                      _init();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kStar.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                          '⭐ ${_profile?.totalStars() ?? 0}  🪙 ${_profile?.coins ?? 0}',
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w800, color: kAccent)),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const AchievementsScreen())),
                    icon: const Icon(Icons.military_tech_outlined),
                    color: kStar,
                    tooltip: 'Lencana',
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen())),
                    icon: const Icon(Icons.emoji_events_outlined),
                    color: kAccent,
                    tooltip: 'Peringkat',
                  ),
                  IconButton(
                    onPressed: _openAccount,
                    icon: const Icon(Icons.account_circle_outlined),
                    color: kPrimary,
                    tooltip: 'Akun & Profil',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Banner sambutan + maskot ──
              _WelcomeBanner(name: _profile?.name)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),
              if (_profile != null) _DailyChallengeCard(profile: _profile!),
              const SizedBox(height: 12),

              // ── Kartu mata pelajaran ──
              ...List.generate(SubjectInfo.all.length, (i) {
                final info = SubjectInfo.all[i];
                return _SubjectCard(info: info)
                    .animate()
                    .fadeIn(delay: (80 * i).ms)
                    .slideY(begin: 0.15, end: 0);
              }),

              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const AboutScreen())),
                  icon: const Icon(Icons.info_outline_rounded, size: 18),
                  label: Text('Tentang BelajarYuk!',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700, color: kMuted)),
                  style: TextButton.styleFrom(foregroundColor: kMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectInfo info;
  const _SubjectCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => LevelMapScreen(subject: info.subject, grade: 1))),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: info.color,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: info.color.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            children: [
              // Lencana putih berisi ilustrasi khas mapel (agar kontras di kartu).
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Image.asset('assets/img/subjects/subj_${info.subject.name}.png'),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: 0, end: -4, duration: 1600.ms, curve: Curves.easeInOut),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.name,
                        style: GoogleFonts.nunito(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    Text(info.tagline,
                        style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu tantangan harian: main 3 level untuk bonus koin.
class _DailyChallengeCard extends StatelessWidget {
  final ChildProfile profile;
  const _DailyChallengeCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    const target = 3;
    final today = StorageService.dayKey();
    final count = profile.dailyDate == today ? profile.dailyCount : 0;
    final done = count >= target;
    final progress = (count / target).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kStar.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Text(done ? '🎉' : '🎯', style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(done ? 'Tantangan hari ini selesai! 🪙+20' : 'Tantangan Harian',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800, color: kDark)),
                const SizedBox(height: 2),
                Text(done
                    ? 'Datang lagi besok untuk tantangan baru'
                    : 'Selesaikan 3 level hari ini ($count/$target)',
                    style: GoogleFonts.nunito(fontSize: 12, color: kMuted)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: kMuted.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(done ? kSuccess : kStar),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner sambutan ceria dengan maskot burung hantu + gelembung ucapan.
class _WelcomeBanner extends StatelessWidget {
  final String? name;
  const _WelcomeBanner({this.name});

  static const _tips = [
    'Aku Uku si burung hantu. Yuk main & kumpulkan bintang bersamaku!',
    'Tahukah kamu? Belajar 10 menit tiap hari bikin makin pintar! 🌟',
    'Jawab dengan teliti ya, tidak apa-apa kalau salah — coba lagi! 💪',
    'Kumpulkan koin untuk membeli avatar lucu di toko! 🪙',
    'Main tiap hari untuk menjaga api semangatmu tetap menyala! 🔥',
    'Kalau bingung, tekan tombol 🔊 supaya soal dibacakan!',
  ];

  String get _tip {
    // Ganti tiap hari (deterministik) agar terasa "hidup".
    final day = DateTime.now().day;
    return _tips[day % _tips.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryLight, kPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset('assets/img/mascot.png', width: 84, height: 84)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -6, duration: 1400.ms, curve: Curves.easeInOut)
              .rotate(begin: -0.02, end: 0.02, duration: 1400.ms),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Hai${name != null ? ', $name' : ''}! 🌟',
                    style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(_tip,
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.95))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
