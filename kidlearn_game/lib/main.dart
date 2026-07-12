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
    // Periksa cold-start: bila app dikill saat di latar belakang dan kunci aktif,
    // flag _prefBg masih tersimpan di disk → tampilkan layar kunci.
    _checkColdStartLock();
  }

  Future<void> _checkColdStartLock() async {
    // Await load() langsung — aman dipanggil ulang karena SharedPreferences
    // di-cache oleh paket; tidak ada duplikasi IO yang mahal.
    await AppLockService.instance.load();
    if (!mounted) return;
    if (AppLockService.instance.enabled && AppLockService.instance.wasBackgrounded) {
      await AppLockService.instance.clearBackground();
      _wasBackground = true;
      _showResumeLock();
      // enterLockTask() dipanggil oleh _showResumeLock → onUnlock
    } else if (AppLockService.instance.enabled) {
      // Cold start normal dengan kunci aktif — pin app segera.
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
      if (_wasBackground && AppLockService.instance.enabled) {
        _showResumeLock();
        // enterLockTask() dipanggil oleh _showResumeLock → onUnlock
      } else if (AppLockService.instance.enabled && !_lockShowing) {
        // Resume singkat (misal notifikasi ditutup) — pin kembali bila belum.
        unawaited(AppLockService.instance.enterLockTask());
      }
      _wasBackground = false;
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // paused = app tidak terlihat (Home ditekan).
      // hidden = semua view tersembunyi (beberapa versi Android/perangkat mengirim
      //          hidden tanpa paused) — tangkap keduanya agar deteksi lebih andal.
      SfxService.instance.pauseMusic();
      _wasBackground = true;
      unawaited(AppLockService.instance.markBackground());
    } else if (state == AppLifecycleState.inactive) {
      SfxService.instance.pauseMusic();
      // inactive = selingan singkat (dialog sistem, notifikasi) — bukan ke background.
    }
  }

  // Intercept tombol back sistem saat tidak ada route yang bisa di-pop:
  // jika kunci aktif, tampilkan layar PIN untuk konfirmasi keluar.
  @override
  Future<bool> didPopRoute() async {
    if (AppLockService.instance.enabled) {
      _showExitLock();
      return true; // konsumsi event — cegah exit
    }
    return false;
  }

  // Kunci resume: muncul saat app kembali dari background, tidak bisa dibatal.
  void _showResumeLock() {
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
            unawaited(AppLockService.instance.clearBackground());
            // Pin ulang — anak tetap terkunci meski orang tua buka layar.
            unawaited(AppLockService.instance.enterLockTask());
          },
        ),
      );
      overlay.insert(entry);
    });
  }

  // Kunci exit: muncul saat back ditekan di root; benar → keluar, batal → tetap.
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
            // Unpin dulu, baru keluar — agar OS tak menolak penutupan task.
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
