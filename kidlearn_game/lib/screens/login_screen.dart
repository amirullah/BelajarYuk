import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/uku_mascot.dart';
import 'profile_select_screen.dart';
import 'home_v2_screen.dart';

/// Layar login orang tua — email/password atau "Masuk dengan Google".
/// [asGate] = dipakai sebagai gerbang awal (menyembunyikan tombol kembali).
class LoginScreen extends StatefulWidget {
  final bool asGate;
  const LoginScreen({super.key, this.asGate = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String?> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    String? err;
    try {
      err = await action();
    } catch (_) {
      err = 'Terjadi kesalahan. Coba lagi ya.';
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (err == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const ProfileSelectScreen(mustCreate: true)));
    } else {
      setState(() => _error = err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err),
        backgroundColor: kError,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  /// Cadangan: main tanpa akun (progres tersimpan di HP saja).
  Future<void> _skip() async {
    final storage = StorageService();
    await storage.ensureLocalProfile();
    if (mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeV2Screen()));
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
        automaticallyImplyLeading: !widget.asGate,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: UkuMascot(size: 100, greeting: 'Halo! Aku Uku 🦉'),
              ),
              const SizedBox(height: 8),
              Text(_register ? 'Buat Akun Orang Tua' : 'Masuk',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontSize: 26, fontWeight: FontWeight.w900, color: kDark)),
              Text(widget.asGate
                  ? 'Yuk masuk dulu, lalu buat profil anak untuk mulai belajar'
                  : 'Simpan progres & main di perangkat manapun',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 13, color: kMuted)),
              const SizedBox(height: 24),

              // ── Tombol Google ──
              _GoogleButton(
                onTap: _busy ? null : () => _run(_auth.loginGoogle),
              ),
              const SizedBox(height: 16),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('atau',
                        style: GoogleFonts.nunito(color: kMuted))),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 16),

              if (_register)
                _field(_name, 'Nama', Icons.person_outline),
              _field(_email, 'Email', Icons.email_outlined,
                  keyboard: TextInputType.emailAddress),
              _field(_pass, 'Password', Icons.lock_outline, obscure: true),

              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: GoogleFonts.nunito(
                        color: kError, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _busy
                    ? null
                    : () => _run(() => _register
                        ? _auth.registerEmail(
                            _email.text, _pass.text, _name.text)
                        : _auth.loginEmail(_email.text, _pass.text)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(_register ? 'Daftar' : 'Masuk',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() {
                          _register = !_register;
                          _error = null;
                        }),
                child: Text(
                    _register
                        ? 'Sudah punya akun? Masuk'
                        : 'Belum punya akun? Daftar',
                    style: GoogleFonts.nunito(
                        color: kPrimary, fontWeight: FontWeight.w700)),
              ),
              if (widget.asGate)
                TextButton(
                  onPressed: _busy ? null : _skip,
                  child: Text('Main dulu tanpa akun (progres di HP saja)',
                      style: GoogleFonts.nunito(
                          color: kMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon,
      {bool obscure = false, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: kSurface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _GoogleButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Text('G',
          style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF4285F4))),
      label: Text('Masuk dengan Google',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: kDark)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: kMuted.withOpacity(0.4)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
