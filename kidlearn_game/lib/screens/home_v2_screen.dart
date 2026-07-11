import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/subject.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import 'level_map_screen.dart';
import 'login_screen.dart';
import 'profile_select_screen.dart';
import 'about_screen.dart';
import 'avatar_shop_screen.dart';

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
  }

  Future<void> _init() async {
    final p = await _storage.ensureLocalProfile();
    if (mounted) setState(() => _profile = p);
  }

  Future<void> _openAccount() async {
    final loggedIn = await _storage.isLoggedIn;
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            loggedIn ? const ProfileSelectScreen() : const LoginScreen()));
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
                        Text('Ayo belajar sambil bermain — Kelas 1',
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
                    onPressed: _openAccount,
                    icon: const Icon(Icons.account_circle_outlined),
                    color: kPrimary,
                    tooltip: 'Akun & Profil',
                  ),
                ],
              ),
              const SizedBox(height: 24),

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
              Text(info.emoji, style: const TextStyle(fontSize: 40)),
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
