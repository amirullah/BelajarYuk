import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/sfx_service.dart';
import '../utils/app_colors.dart';

/// Maskot Uku yang hidup: mengambang lembut, berganti ekspresi, dan bila
/// disentuh akan bereaksi (ekspresi + animasi acak + gelembung kata semangat).
///
/// Dipakai di banyak layar sebagai penyemangat. Animasi &amp; kata-katanya
/// dibuat bervariasi supaya tidak membosankan.
class UkuMascot extends StatefulWidget {
  final double size;
  final bool interactive; // bisa disentuh
  final bool bubble; // tampilkan gelembung kata saat disentuh
  final bool autoLiven; // sesekali berganti ekspresi sendiri
  final String? greeting; // kalimat awal opsional (mis. sapaan)
  const UkuMascot({
    super.key,
    this.size = 88,
    this.interactive = true,
    this.bubble = true,
    this.autoLiven = false,
    this.greeting,
  });

  @override
  State<UkuMascot> createState() => _UkuMascotState();
}

class _UkuMascotState extends State<UkuMascot> {
  static const _exprs = ['happy', 'wink', 'cheer', 'surprised', 'love'];
  static const _phrases = [
    'Semangat ya! 💪', 'Kamu hebat! 🌟', 'Kamu pasti bisa!', 'Wah, keren!',
    'Terus semangat!', 'Jangan menyerah ya!', 'Aku bangga padamu!',
    'Yuk lanjut main!', 'Pintar sekali! 🎉', 'Hebat, teruskan!',
    'Belajar itu seru!', 'Ayo kumpulkan bintang! ⭐', 'Kamu juara! 🏆',
  ];

  final _rng = Random();
  String _expr = 'happy';
  int _tapTick = 0;
  int _animStyle = 0;
  String? _bubbleText;
  Timer? _bubbleTimer;
  Timer? _livenTimer;

  @override
  void initState() {
    super.initState();
    if (widget.greeting != null) {
      _bubbleText = widget.greeting;
      _bubbleTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _bubbleText = null);
      });
    }
    if (widget.autoLiven) {
      _livenTimer = Timer.periodic(const Duration(seconds: 6), (_) {
        if (!mounted) return;
        setState(() {
          _expr = _exprs[_rng.nextInt(_exprs.length)];
          _tapTick++;
          _animStyle = _rng.nextInt(4);
        });
      });
    }
  }

  @override
  void dispose() {
    _bubbleTimer?.cancel();
    _livenTimer?.cancel();
    super.dispose();
  }

  void _react() {
    if (!widget.interactive) return;
    setState(() {
      // Ekspresi acak yang berbeda dari sekarang.
      String next = _expr;
      while (next == _expr) {
        next = _exprs[_rng.nextInt(_exprs.length)];
      }
      _expr = next;
      _animStyle = _rng.nextInt(4);
      _tapTick++;
      if (widget.bubble) {
        _bubbleText = _phrases[_rng.nextInt(_phrases.length)];
        _bubbleTimer?.cancel();
        _bubbleTimer = Timer(const Duration(milliseconds: 2600), () {
          if (mounted) setState(() => _bubbleText = null);
        });
      }
    });
    // Suara ringan bergiliran: kadang suara anak, kadang denting.
    if (_tapTick.isEven && SfxService.instance.hasVoice) {
      SfxService.instance.voice();
    } else {
      SfxService.instance.star();
    }
  }

  /// Animasi reaksi acak (melompat / berputar / bergoyang / meletup).
  Widget _applyTapAnim(Widget child) {
    final a = child.animate(key: ValueKey(_tapTick));
    switch (_animStyle) {
      case 0: // melompat
        return a
            .moveY(begin: 0, end: -18, duration: 220.ms, curve: Curves.easeOut)
            .then()
            .moveY(begin: -18, end: 0, duration: 260.ms, curve: Curves.bounceOut);
      case 1: // berputar kecil
        return a.rotate(begin: -0.12, end: 0.12, duration: 500.ms, curve: Curves.elasticOut);
      case 2: // bergoyang
        return a.shakeX(hz: 4, amount: 5, duration: 500.ms);
      default: // meletup
        return a.scaleXY(begin: 0.7, end: 1, duration: 450.ms, curve: Curves.elasticOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget img = Image.asset('assets/img/ukus/uku_$_expr.png',
        width: widget.size, height: widget.size);
    img = _applyTapAnim(img);
    // Mengambang lembut terus-menerus.
    img = img
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: 0, end: -5, duration: 1500.ms, curve: Curves.easeInOut);

    return GestureDetector(
      onTap: _react,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_bubbleText != null)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              constraints: const BoxConstraints(maxWidth: 220),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: kPrimary.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Text(_bubbleText!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: kPrimary)),
            ).animate().fadeIn(duration: 200.ms).scale(
                begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          img,
        ],
      ),
    );
  }
}
