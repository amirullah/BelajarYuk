import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/sfx_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import 'about_screen.dart';
import 'parent_dashboard_screen.dart';
import 'profile_select_screen.dart';
import 'login_screen.dart';

/// Pengaturan akun — dashboard, tentang, ganti profil, logout.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = AuthService();
  final _storage = StorageService();
  bool _loggedIn = false;
  bool _sfx = SfxService.instance.enabled;
  bool _music = SfxService.instance.musicEnabled;

  @override
  void initState() {
    super.initState();
    _storage.isLoggedIn.then((v) {
      if (mounted) setState(() => _loggedIn = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kDark,
        title: Text('Pengaturan',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _soundTile(),
          _musicTile(),
          _tile(Icons.bar_chart_rounded, 'Progres Anak', 'Lihat kemajuan per mapel',
              () => _push(const ParentDashboardScreen())),
          if (_loggedIn)
            _tile(Icons.switch_account_rounded, 'Ganti Profil',
                'Pilih anak lain', () => _push(const ProfileSelectScreen())),
          if (!_loggedIn)
            _tile(Icons.login_rounded, 'Masuk / Daftar',
                'Simpan progres ke cloud', () => _push(const LoginScreen())),
          _tile(Icons.info_outline_rounded, 'Tentang', 'BelajarYuk! v2.0',
              () => _push(const AboutScreen())),
          if (_loggedIn) ...[
            const SizedBox(height: 8),
            _tile(Icons.logout_rounded, 'Keluar', 'Logout dari akun', _logout,
                danger: true),
          ],
        ],
      ),
    );
  }

  Widget _soundTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        secondary: Icon(_sfx ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            color: kPrimary),
        title: Text('Efek Suara',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, color: kDark)),
        subtitle: Text('Suara benar, salah, & bintang',
            style: GoogleFonts.nunito(fontSize: 12, color: kMuted)),
        activeColor: kPrimary,
        value: _sfx,
        onChanged: (v) async {
          await SfxService.instance.setEnabled(v);
          if (v) SfxService.instance.correct(); // contoh suara saat dinyalakan
          setState(() => _sfx = v);
        },
      ),
    );
  }

  Widget _musicTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        secondary: Icon(_music ? Icons.music_note_rounded : Icons.music_off_rounded,
            color: kPrimary),
        title: Text('Musik Latar',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, color: kDark)),
        subtitle: Text('Musik lembut di beranda',
            style: GoogleFonts.nunito(fontSize: 12, color: kMuted)),
        activeColor: kPrimary,
        value: _music,
        onChanged: (v) async {
          await SfxService.instance.setMusicEnabled(v);
          setState(() => _music = v);
        },
      ),
    );
  }

  void _push(Widget screen) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text('Keluar dari akun?',
            style: GoogleFonts.nunito(fontSize: 16)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: kError),
              child: const Text('Keluar')),
        ],
      ),
    );
    if (ok == true) {
      await _auth.logout();
      if (mounted) Navigator.of(context).pop();
    }
  }

  Widget _tile(IconData icon, String title, String subtitle, VoidCallback onTap,
      {bool danger = false}) {
    final color = danger ? kError : kPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title,
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: danger ? kError : kDark)),
        subtitle: Text(subtitle,
            style: GoogleFonts.nunito(fontSize: 12, color: kMuted)),
        trailing: const Icon(Icons.chevron_right_rounded, color: kMuted),
        onTap: onTap,
      ),
    );
  }
}
