import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import 'home_v2_screen.dart';
import 'login_screen.dart';
import 'profile_select_screen.dart';

/// Gerbang alur awal: arahkan pengguna untuk login lalu membuat profil anak
/// sebelum masuk beranda. Dipanggil setelah splash & setelah login/logout.
class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final storage = StorageService();
    final loggedIn = await storage.isLoggedIn;
    if (!mounted) return;

    Widget next;
    if (!loggedIn) {
      // Belum login → arahkan ke login (wajib, sebagai gerbang awal).
      next = const LoginScreen(asGate: true);
    } else {
      final profiles = await storage.loadProfiles();
      final current = await storage.currentProfile();
      if (profiles.isEmpty) {
        next = const ProfileSelectScreen(mustCreate: true);
      } else if (current == null) {
        next = const ProfileSelectScreen();
      } else {
        next = const HomeV2Screen();
      }
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kBg,
      body: Center(child: CircularProgressIndicator(color: kPrimary)),
    );
  }
}
