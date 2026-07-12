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
  bool _lockShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLock();
  }

  // Muat kunci dan langsung pin app bila aktif — tanpa minta PIN saat buka.
  Future<void> _initLock() async {
    await AppLockService.instance.load();
    if (!mounted) return;
    if (AppLockService.instance.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(AppLockService.instance.enterLockTask());
      });
    }
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
      // Pin ulang bila kunci aktif (misal notifikasi menutup sebentar).
      if (AppLockService.instance.enabled && !_lockShowing) {
        unawaited(AppLockService.instance.enterLockTask());
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      SfxService.instance.pauseMusic();
    } else if (state == AppLifecycleState.inactive) {
      SfxService.instance.pauseMusic();
    }
  }

  // Intercept back dari beranda (root) — satu-satunya jalan keluar yang diizinkan.
  @override
  Future<bool> didPopRoute() async {
    if (AppLockService.instance.enabled) {
      _showExitLock();
      return true;
    }
    return false;
  }

  // PIN keluar: ada tombol Batal agar anak bisa kembali belajar.
  void _showExitLock() {
    if (_lockShowing) return;
    _lockShowing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) { _lockShowing = false; return; }
      final overlay = _navKey.currentState?.overlay;
      if (overlay == null) { _lockShowing = false; return; }
      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (_) => LockScreen(
          onUnlock: () {
            entry.remove();
            _lockShowing = false;
            AppLockService.instance.exitLockTask()
                .whenComplete(SystemNavigator.pop);
          },
          onCancel: () {
            entry.remove();
            _lockShowing = false;
          },
        ),
      );
      overlay.insert(entry);
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
