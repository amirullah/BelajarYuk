import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_lock_service.dart';
import '../utils/app_colors.dart';
import '../widgets/uku_mascot.dart';

/// Layar kunci — dua mode:
///  - resume (onCancel null): muncul saat app kembali dari background; tidak bisa dibatal.
///  - exit (onCancel tidak null): muncul saat back ditekan; "Batal" tetap di app.
class LockScreen extends StatefulWidget {
  final VoidCallback onUnlock;
  final VoidCallback? onCancel;
  const LockScreen({super.key, required this.onUnlock, this.onCancel});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _input = '';
  int _attempts = 0;
  bool _shaking = false;
  bool _waiting = false;
  int _waitSec = 0;
  Timer? _waitTimer;

  @override
  void dispose() {
    _waitTimer?.cancel();
    super.dispose();
  }

  void _addDigit(String d) {
    if (_waiting || _input.length >= 4) return;
    setState(() => _input += d);
    if (_input.length == 4) _verify();
  }

  void _del() {
    if (_waiting || _input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  Future<void> _verify() async {
    if (AppLockService.instance.verifyPin(_input)) {
      widget.onUnlock();
      return;
    }
    _attempts++;
    setState(() { _shaking = true; _input = ''; });
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _shaking = false);
    if (_attempts >= 3) {
      setState(() { _waiting = true; _waitSec = 10; });
      _waitTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() => _waitSec--);
        if (_waitSec <= 0) {
          t.cancel();
          setState(() { _waiting = false; _attempts = 0; });
        }
      });
    }
  }

  Widget _dot(int i) {
    final filled = i < _input.length;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: filled ? kPrimary : Colors.transparent,
        border: Border.all(color: filled ? kPrimary : kMuted, width: 2.5),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _numKey(String label, {IconData? icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: _waiting ? null : (onTap ?? () => _addDigit(label)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.all(7),
        width: 76, height: 76,
        decoration: BoxDecoration(
          color: _waiting ? kSurface.withOpacity(0.5) : kSurface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08),
                blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: _waiting ? kMuted : kDark, size: 26)
              : Text(label,
                  style: GoogleFonts.nunito(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: _waiting ? kMuted : kDark)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dots = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          4,
          (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: _dot(i))),
    );

    final dotsAnimated = _shaking
        ? dots
            .animate()
            .shakeX(hz: 5, amount: 7, duration: 550.ms)
        : dots;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const UkuMascot(size: 110, autoLiven: true, bubble: false)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.elasticOut),
              const SizedBox(height: 18),
              Text(
                widget.onCancel != null ? '🔒 Keluar Aplikasi' : '🔒 Kunci Anak Aktif',
                style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: kDark)),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _waiting
                      ? 'Terlalu banyak percobaan. Coba lagi dalam $_waitSec detik…'
                      : widget.onCancel != null
                          ? 'Masukkan PIN orang tua untuk keluar dari aplikasi'
                          : 'Masukkan PIN orang tua untuk membuka aplikasi',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: _waiting ? kError : kMuted),
                ),
              ),
              const SizedBox(height: 32),
              dotsAnimated,
              const SizedBox(height: 36),
              // Numpad 3×3 + bawah
              for (final row in [
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9'],
              ])
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((d) => _numKey(d)).toList(),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 90), // placeholder kosong
                  _numKey('0'),
                  _numKey('', icon: Icons.backspace_outlined, onTap: _del),
                ],
              ),
              const Spacer(),
              if (widget.onCancel != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onCancel,
                      icon: const Icon(Icons.arrow_back_rounded, size: 22),
                      label: Text('Batal — Kembali Belajar',
                          style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimary,
                        side: BorderSide(color: kPrimary, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('Uku menunggu orang tua ya! 🦉',
                      style: GoogleFonts.nunito(fontSize: 12, color: kMuted)),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
