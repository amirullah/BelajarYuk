import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/app_lock_service.dart';
import '../services/sfx_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/parent_gate.dart';
import 'about_screen.dart';
import 'parent_dashboard_screen.dart';
import 'profile_select_screen.dart';
import 'login_screen.dart';
import 'app_gate.dart';

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
  bool _lockEnabled = AppLockService.instance.enabled;
  String? _email; // email akun yang login
  bool _google = false;

  /// Akun developer/admin — hanya mereka yang boleh "Mode Review" (buka semua
  /// kelas). Orang tua biasa tak melihat menu ini.
  static const _adminEmails = {
    'amir.pnl08@gmail.com',
    'amirullah.pnl@gmail.com',
    'markazvirtual@gmail.com',
  };
  bool get _isAdmin =>
      _email != null && _adminEmails.contains(_email!.trim().toLowerCase());

  @override
  void initState() {
    super.initState();
    _initAccount();
  }

  Future<void> _initAccount() async {
    final loggedIn = await _storage.isLoggedIn;
    // Tampilkan email dari cache dulu agar tetap terlihat walau offline.
    final cached = await _storage.cachedEmail();
    if (mounted) {
      setState(() {
        _loggedIn = loggedIn;
        if (loggedIn) _email = cached;
      });
    }
    if (loggedIn) {
      final token = await _storage.getToken();
      if (token != null) {
        final res = await ApiService().me(token);
        if (res['ok'] == true && mounted) {
          final email = res['email'] as String?;
          if (email != null && email.isNotEmpty) _storage.cacheEmail(email);
          setState(() {
            _email = email ?? _email;
            _google = res['google'] == true;
          });
        }
      }
    }
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
          if (_loggedIn && _email != null)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(_google ? Icons.g_mobiledata_rounded : Icons.email_rounded,
                      color: kPrimary, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Masuk sebagai',
                            style: GoogleFonts.nunito(
                                fontSize: 11, color: kMuted)),
                        Text(_email!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: kDark)),
                      ],
                    ),
                  ),
                  if (_google)
                    Text('Google',
                        style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: kMuted)),
                ],
              ),
            ),
          _soundTile(),
          _musicTile(),
          _lockTile(),
          _tile(Icons.bar_chart_rounded, 'Progres Anak', 'Lihat kemajuan per mapel',
              _openDashboard),
          // Mode Review hanya untuk developer/admin (bukan orang tua umum).
          if (_isAdmin)
            _tile(Icons.explore_rounded, 'Mode Review (Buka Semua Kelas)',
                'Khusus developer/admin — meninjau soal Kelas 1–6',
                _openReviewMode),
          if (_loggedIn)
            _tile(Icons.switch_account_rounded, 'Ganti Profil',
                'Pilih anak lain', () => _push(const ProfileSelectScreen())),
          if (!_loggedIn)
            _tile(Icons.login_rounded, 'Masuk / Daftar',
                'Simpan progres ke cloud', () => _push(const LoginScreen())),
          _tile(Icons.info_outline_rounded, 'Tentang', 'BelajarYuk! v2.0',
              () => _push(const AboutScreen())),
          if (_loggedIn && !_google)
            _tile(Icons.password_rounded, 'Ganti Kata Sandi',
                'Perbarui kata sandi akun', _changePassword),
          if (_loggedIn) ...[
            const SizedBox(height: 8),
            _tile(Icons.logout_rounded, 'Keluar', 'Logout dari akun', _logout,
                danger: true),
          ],
        ],
      ),
    );
  }

  Widget _lockTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: kSurface, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(
          _lockEnabled ? Icons.lock_rounded : Icons.lock_open_rounded,
          color: _lockEnabled ? kSuccess : kPrimary,
        ),
        title: Text('Kunci Aplikasi Anak',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, color: kDark)),
        subtitle: Text(
          _lockEnabled
              ? 'Aktif — anak tidak bisa keluar tanpa PIN'
              : 'Nonaktif — ketuk untuk mengaktifkan',
          style: GoogleFonts.nunito(fontSize: 12, color: kMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_lockEnabled)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kSuccess.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('AKTIF',
                    style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: kSuccess)),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: kMuted),
          ],
        ),
        onTap: _manageLock,
      ),
    );
  }

  Future<void> _manageLock() async {
    if (!await ParentGate.show(context,
        reason: 'Kunci Anak mencegah anak keluar app. '
            'Jawab soal ini untuk mengelola pengaturan kunci.')) {
      return;
    }
    if (!mounted) return;
    if (_lockEnabled) {
      await _showLockOptions();
    } else {
      await _setupLock();
    }
  }

  Future<void> _setupLock() async {
    final pin = await _showPinDialog();
    if (pin == null || !mounted) return;
    await AppLockService.instance.enable(pin);
    if (!mounted) return;
    setState(() => _lockEnabled = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('🔒 Kunci Anak aktif! Anak perlu PIN untuk keluar app.'),
        behavior: SnackBarBehavior.floating));
  }

  Future<void> _showLockOptions() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Kunci Aplikasi Anak',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w900)),
        content: Text('Kunci sedang aktif. Pilih tindakan:',
            style: GoogleFonts.nunito()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'disable'),
            child: Text('Nonaktifkan',
                style: GoogleFonts.nunito(
                    color: kError, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'change'),
            child: Text('Ganti PIN',
                style: GoogleFonts.nunito(
                    color: kPrimary, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tutup',
                style: GoogleFonts.nunito(color: kMuted)),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (result == 'disable') {
      await AppLockService.instance.disable();
      if (!mounted) return;
      setState(() => _lockEnabled = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Kunci Anak dinonaktifkan.'),
          behavior: SnackBarBehavior.floating));
    } else if (result == 'change') {
      final pin = await _showPinDialog();
      if (!mounted) return;
      if (pin != null) {
        await AppLockService.instance.enable(pin);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('PIN berhasil diperbarui ✅'),
            behavior: SnackBarBehavior.floating));
      }
    }
  }

  Future<String?> _showPinDialog() async {
    final c1 = TextEditingController();
    final c2 = TextEditingController();
    String? err;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Buat PIN Orang Tua',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('PIN 4 digit ini digunakan saat anak ingin keluar app.',
                  style: GoogleFonts.nunito(fontSize: 12, color: kMuted)),
              const SizedBox(height: 14),
              TextField(
                controller: c1,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 22, fontWeight: FontWeight.w800,
                    letterSpacing: 10),
                decoration: InputDecoration(
                    labelText: 'PIN baru',
                    counterText: '',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
                onChanged: (_) => setLocal(() => err = null),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: c2,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 22, fontWeight: FontWeight.w800,
                    letterSpacing: 10),
                decoration: InputDecoration(
                    labelText: 'Konfirmasi PIN',
                    counterText: '',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
                onChanged: (_) => setLocal(() => err = null),
              ),
              if (err != null) ...[
                const SizedBox(height: 8),
                Text(err!,
                    style:
                        GoogleFonts.nunito(color: kError, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  Text('Batal', style: GoogleFonts.nunito(color: kMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
              onPressed: () {
                if (c1.text.length != 4) {
                  setLocal(() => err = 'PIN harus tepat 4 digit.');
                  return;
                }
                if (c1.text != c2.text) {
                  setLocal(() => err = 'PIN tidak cocok. Coba lagi.');
                  return;
                }
                Navigator.pop(ctx, c1.text);
              },
              child: Text('Simpan',
                  style: GoogleFonts.nunito(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        );
      }),
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
        subtitle: Text('Musik ceria berbeda tiap pelajaran',
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

  Future<void> _changePassword() async {
    final oldC = TextEditingController();
    final newC = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        String? err;
        bool busy = false;
        return StatefulBuilder(builder: (ctx, setLocal) {
          Future<void> submit() async {
            if (newC.text.length < 6) {
              setLocal(() => err = 'Kata sandi baru minimal 6 karakter.');
              return;
            }
            setLocal(() {
              busy = true;
              err = null;
            });
            final token = await _storage.getToken();
            final res = await ApiService()
                .changePassword(token ?? '', oldC.text, newC.text);
            if (res['ok'] == true) {
              if (ctx.mounted) Navigator.pop(ctx, true);
            } else {
              setLocal(() {
                busy = false;
                err = res['error']?.toString() ?? 'Gagal mengganti kata sandi.';
              });
            }
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Ganti Kata Sandi',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w900)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: oldC,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Kata sandi lama')),
                const SizedBox(height: 8),
                TextField(
                    controller: newC,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Kata sandi baru')),
                if (err != null) ...[
                  const SizedBox(height: 8),
                  Text(err!,
                      style: GoogleFonts.nunito(
                          color: kError, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
            actions: [
              TextButton(
                  onPressed: busy ? null : () => Navigator.pop(ctx, false),
                  child: Text('Batal',
                      style: GoogleFonts.nunito(color: kMuted))),
              ElevatedButton(
                onPressed: busy ? null : submit,
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                child: busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('Simpan',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Kata sandi berhasil diganti ✅')));
    }
  }

  /// Dashboard adalah area orang tua → lindungi dengan gerbang.
  Future<void> _openDashboard() async {
    if (await ParentGate.show(context)) {
      if (mounted) _push(const ParentDashboardScreen());
    }
  }

  /// Mode Review: buka semua kelas (1–6) agar orang tua/guru bisa meninjau soal
  /// tanpa harus menuntaskan setiap kelas. Dilindungi gerbang orang tua.
  Future<void> _openReviewMode() async {
    if (!await ParentGate.show(context,
        reason: 'Mode Review membuka semua kelas untuk ditinjau. '
            'Jawab soal ini dulu ya.')) {
      return;
    }
    final storage = StorageService();
    final p = await storage.currentProfile();
    if (p == null) return;
    if (p.unlockedGrade < 6) {
      p.unlockedGrade = 6;
      await storage.upsertProfile(p);
      storage.syncProfile(p);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Semua kelas (1–6) terbuka untuk ditinjau ✅'),
          behavior: SnackBarBehavior.floating));
    }
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
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AppGate()),
            (r) => false);
      }
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
