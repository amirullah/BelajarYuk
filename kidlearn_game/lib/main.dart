import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/lock_screen.dart';
import 'services/sfx_service.dart';
import 'services/content_service.dart';
import 'services/app_lock_service.dart';
import 'utils/app_colors.dart';
import 'utils/nav_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Tampilkan UI SEGERA — jangan menunggu muat audio/konten dulu, agar tak ada
  // "layar biru" lama di awal (frame pertama tak tertahan).
  runApp(const BelajarYukApp());
  // Muat aset & konten di LATAR (tak memblokir frame pertama):
  //  - audio (SFX/musik) dimuat sambil splash tampil;
  //  - konten soal: aset bundel (basis) + cache server (bila lebih baru), lalu
  //    segarkan dari server (update soal tanpa pasang APK). Versi TERTINGGI menang.
  unawaited(SfxService.instance.load());
  unawaited(AppLockService.instance.load());
  unawaited(() async {
    await ContentService.instance.loadBundledAsset();
    await ContentService.instance.loadFromCache();
    await ContentService.instance.refreshFromServer();
  }());
}

class BelajarYukApp extends StatefulWidget {
  const BelajarYukApp({super.key});

  @override
  State<BelajarYukApp> createState() => _BelajarYukAppState();
}

class _BelajarYukAppState extends State<BelajarYukApp>
    with WidgetsBindingObserver {
  final _navKey = GlobalKey<NavigatorState>();
  bool _wasBackground = false;
  bool _lockShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SfxService.instance.resumeMusic();
      if (_wasBackground && AppLockService.instance.enabled) {
        _showLockScreen();
      }
      _wasBackground = false;
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      SfxService.instance.pauseMusic();
      if (state == AppLifecycleState.paused) _wasBackground = true;
    }
  }

  void _showLockScreen() {
    if (_lockShowing) return;
    _lockShowing = true;
    // Tunggu satu frame agar Navigator sudah siap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) { _lockShowing = false; return; }
      final nav = _navKey.currentState;
      if (nav == null) { _lockShowing = false; return; }
      nav.push(PageRouteBuilder(
        opaque: true,
        fullscreenDialog: true,
        settings: const RouteSettings(name: '/lock'),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => LockScreen(
          onUnlock: () {
            _navKey.currentState?.pop();
            _lockShowing = false;
          },
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      )).then((_) => _lockShowing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BelajarYuk!',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimary,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      navigatorObservers: [routeObserver],
      home: const SplashScreen(),
    );
  }
}
