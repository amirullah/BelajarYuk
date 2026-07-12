import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/subject.dart';
import '../models/profile.dart';
import '../services/sfx_service.dart';
import '../services/storage_service.dart';
import '../services/update_service.dart';
import '../utils/app_colors.dart';
import '../widgets/uku_mascot.dart';
import '../widgets/avatar_view.dart';
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
    if (mounted) setState(() => _profile = p); // tampilkan cepat dari lokal
    // Tarik progres + state dari server (bila login) — memulihkan koin/lencana/
    // bintang/streak setelah pasang ulang. pushState:false agar state lokal yang
    // masih kosong TIDAK menimpa data di server (hanya menarik/mengadopsi).
    await _storage.syncProfile(p, pushState: false);
    if (mounted) setState(() => _profile = p);
    // Perkenalan Uku (sekali) sebelum hadiah harian.
    if (!await _storage.ukuIntroSeen() && mounted) {
      await _showUkuIntro();
      await _storage.markUkuIntroSeen();
    }
    // Hadiah harian (setelah sync agar tak dobel bila sudah klaim di perangkat lain).
    final reward = await _storage.claimDailyReward(p);
    if (reward > 0 && mounted) {
      setState(() {});
      SfxService.instance.coin();
      await _showDailyReward(reward);
    }
    // Cek versi baru & sarankan perbarui (best-effort; diam bila offline/gagal).
    await _checkUpdate();
  }

  /// Cek apakah ada versi baru di server; bila ada, tampilkan saran perbarui.
  Future<void> _checkUpdate() async {
    final info = await UpdateService().check();
    if (info == null || !mounted) return;
    final sp = await SharedPreferences.getInstance();
    final dismissed = sp.getInt('update_dismissed_build') ?? 0;
    // Bila bukan wajib & pengguna sudah menunda build ini, jangan ganggu lagi.
    if (!info.mandatory && dismissed >= info.build) return;
    if (!mounted) return;
    await _showUpdateDialog(info, sp);
  }

  Future<void> _showUpdateDialog(
      UpdateInfo info, SharedPreferences sp) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: !info.mandatory,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(children: [
          Image.asset('assets/img/ukus/uku_cheer.png', width: 84, height: 84)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                  begin: const Offset(0.94, 0.94),
                  end: const Offset(1.06, 1.06),
                  duration: 700.ms),
          const SizedBox(height: 8),
          Text('Ada Versi Baru! 🎉',
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w900, color: kDark)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                info.version.isNotEmpty
                    ? 'Versi ${info.version} sudah tersedia. '
                        'Yuk perbarui agar dapat perbaikan & fitur terbaru!'
                    : 'Versi terbaru sudah tersedia. Yuk perbarui!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 14, height: 1.4, color: kDark)),
            if (info.notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(info.notes,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(fontSize: 12.5, color: kMuted)),
              ),
            ],
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: info.mandatory
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              if (!info.mandatory)
                TextButton(
                  onPressed: () async {
                    await sp.setInt('update_dismissed_build', info.build);
                    if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                  },
                  child: Text('Nanti',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800, color: kMuted)),
                ),
              ElevatedButton(
                onPressed: () => _openUpdate(info.url),
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                child: Text('Perbarui Sekarang',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Buka tautan unduh APK di browser. Bila gagal, salin tautan ke papan klip
  /// sebagai cadangan agar pengguna tetap bisa mengunduh manual.
  Future<void> _openUpdate(String url) async {
    final uri = Uri.tryParse(url);
    bool opened = false;
    if (uri != null) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    if (!mounted) return;
    if (opened) {
      Navigator.pop(context);
    } else {
      await Clipboard.setData(ClipboardData(text: url));
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Tautan unduh disalin: $url',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
      ));
    }
  }

  /// Perkenalan maskot Uku saat pertama kali membuka app.
  Future<void> _showUkuIntro() async {
    SfxService.instance.ukuVoice();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(children: [
          Image.asset('assets/img/ukus/uku_cheer.png', width: 96, height: 96)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .rotate(begin: -0.05, end: 0.05, duration: 700.ms),
          const SizedBox(height: 8),
          Text('Hai, aku Uku! 🦉',
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w900, color: kDark)),
        ]),
        content: Text(
            'Aku burung hantu teman belajarmu! Aku akan menemani, '
            'menyemangati, dan bertepuk tangan saat kamu benar. '
            'Ayo kumpulkan bintang & koin bersama Uku! ⭐🪙',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontSize: 14, height: 1.4, color: kDark)),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
              child: Text('Halo Uku! 👋',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
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

  /// Klaim hadiah Target Mingguan (bila bintang minggu ini cukup).
  Future<void> _claimWeekly() async {
    final p = _profile;
    if (p == null) return;
    final coins = await _storage.claimWeeklyTarget(p);
    if (coins > 0 && mounted) {
      SfxService.instance.coin();
      SfxService.instance.cheer();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('🎉 Target mingguan tercapai! +$coins koin 🪙'),
          behavior: SnackBarBehavior.floating));
    }
  }

  /// Buka mapel. Bila sudah membuka kelas >1, tampilkan pemilih kelas dulu
  /// sehingga anak bisa memainkan kelas yang sudah terbuka.
  Future<void> _openSubject(Subject s) async {
    final unlocked = _profile?.unlockedGrade ?? 1;
    int grade = 1;
    if (unlocked > 1) {
      final chosen = await showModalBottomSheet<int>(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text('Pilih Kelas',
                    style: GoogleFonts.nunito(
                        fontSize: 18, fontWeight: FontWeight.w900)),
              ),
              ...List.generate(unlocked, (i) {
                final g = i + 1;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: SubjectInfo.of(s).color.withOpacity(0.15),
                    child: Text('$g',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w900,
                            color: SubjectInfo.of(s).color)),
                  ),
                  title: Text('Kelas $g',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  trailing: g == unlocked
                      ? const Icon(Icons.lock_open_rounded, color: kSuccess)
                      : null,
                  onTap: () => Navigator.pop(context, g),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
      if (chosen == null) return;
      grade = chosen;
    }
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => LevelMapScreen(subject: s, grade: grade)));
    _init(); // segarkan kelas terbuka & koin setelah bermain
  }

  Future<void> _openAccount() async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()));
    _init(); // segarkan profil aktif setelah kembali
  }

  /// Chip aksi cepat: ikon berwarna + label kontras (mudah dibaca anak).
  Widget _actionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 4),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: kDark)),
            ],
          ),
        ),
      ),
    );
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
              // ── Sapaan ──
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: AvatarView(_profile?.avatar ?? '🦊', size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Halo, ${_profile?.name ?? "Pemain"}! 👋',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: kDark)),
                        Text(
                            (_profile?.streak ?? 0) > 1
                                ? '🔥 ${_profile!.streak} hari beruntun — hebat!'
                                : '⭐ ${_profile?.totalStars() ?? 0} bintang · ayo belajar!',
                            style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _openAccount,
                    icon: const Icon(Icons.settings_rounded),
                    color: kPrimary,
                    tooltip: 'Akun & Pengaturan',
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Aksi cepat (chip warna, teks kontras) ──
              Row(
                children: [
                  _actionChip(
                    icon: Icons.storefront_rounded,
                    label: '${_profile?.coins ?? 0} Koin',
                    color: kAccent,
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const AvatarShopScreen()));
                      _init();
                    },
                  ),
                  const SizedBox(width: 10),
                  _actionChip(
                    icon: Icons.military_tech_rounded,
                    label: 'Lencana',
                    color: kScience,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const AchievementsScreen())),
                  ),
                  const SizedBox(width: 10),
                  _actionChip(
                    icon: Icons.emoji_events_rounded,
                    label: 'Peringkat',
                    color: kEnglish,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen())),
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
              if (_profile != null)
                _MissionsCard(profile: _profile!, onClaimWeekly: _claimWeekly),
              const SizedBox(height: 18),

              // ── Judul bagian ──
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text('Ayo Belajar! 📚',
                    style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: kDark)),
              ),

              // ── Kartu mata pelajaran ──
              ...List.generate(SubjectInfo.all.length, (i) {
                final info = SubjectInfo.all[i];
                return _SubjectCard(
                        info: info, onTap: () => _openSubject(info.subject))
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
  final VoidCallback onTap;
  const _SubjectCard({required this.info, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                info.color,
                HSLColor.fromColor(info.color)
                    .withLightness(
                        (HSLColor.fromColor(info.color).lightness - 0.12)
                            .clamp(0.0, 1.0))
                    .toColor(),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: info.color.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6)),
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
/// Kartu Misi Harian (3 misi) + Target Mingguan (cincin bintang).
/// Sederhana & tak membingungkan: pakai bintang & koin yang sudah dikenal.
class _MissionsCard extends StatelessWidget {
  final ChildProfile profile;
  final Future<void> Function() onClaimWeekly;
  const _MissionsCard({required this.profile, required this.onClaimWeekly});

  @override
  Widget build(BuildContext context) {
    final today = StorageService.dayKey();
    final isToday = profile.dailyDate == today;
    final levels = isToday ? profile.dailyCount : 0;
    final starsToday = isToday ? profile.dailyStars : 0;
    final perfect = isToday && profile.dailyPerfect;

    final isWeek = profile.weekKey == StorageService.weekKey();
    final wStars = isWeek ? profile.weekStars : 0;
    const wTarget = StorageService.weeklyTarget;
    final wPct = (wStars / wTarget).clamp(0.0, 1.0);
    final wReady = wStars >= wTarget && !(isWeek && profile.weekClaimed);
    final wClaimed = isWeek && profile.weekClaimed;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kStar.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Target Mingguan (cincin) ──
          Row(
            children: [
              SizedBox(
                width: 46,
                height: 46,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: wPct,
                      strokeWidth: 5,
                      backgroundColor: kMuted.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(
                          wClaimed ? kSuccess : kStar),
                    ),
                    const Text('⭐', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target Mingguan',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w900, color: kDark)),
                    Text(
                        wClaimed
                            ? 'Selesai! Hebat 🎉'
                            : 'Kumpulkan $wTarget ⭐ minggu ini ($wStars/$wTarget)',
                        style: GoogleFonts.nunito(
                            fontSize: 12, color: kMuted)),
                  ],
                ),
              ),
              if (wReady)
                ElevatedButton(
                  onPressed: onClaimWeekly,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kStar,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8)),
                  child: Text('Klaim 🪙',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w900, color: kDark)),
                ),
            ],
          ),
          const Divider(height: 18),
          Text('Misi Harian',
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w900, color: kDark, fontSize: 13)),
          const SizedBox(height: 6),
          _mission('🎯', 'Selesaikan 3 level', levels, 3),
          _mission('⭐', 'Kumpulkan 8 bintang', starsToday, 8),
          _missionBool('🌟', 'Dapat 1 level sempurna (3⭐)', perfect),
        ],
      ),
    );
  }

  Widget _mission(String emoji, String label, int val, int target) {
    final done = val >= target;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text('$label  ($val/$target)',
                style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: done ? kSuccess : kDark)),
          ),
          Text(done ? '✅' : '⬜',
              style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _missionBool(String emoji, String label, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: done ? kSuccess : kDark)),
          ),
          Text(done ? '✅' : '⬜', style: const TextStyle(fontSize: 15)),
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
          const UkuMascot(size: 84, bubble: false, autoLiven: true),
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
