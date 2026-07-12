import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kunci Aplikasi Anak — mencegah anak keluar app tanpa PIN orang tua.
/// Bila aktif: saat app kembali dari latar belakang, layar PIN muncul.
/// Flag _prefBg disimpan ke disk saat ke latar belakang, dibersihkan setelah
/// kunci dibuka — sehingga cold restart pun tetap meminta PIN.
class AppLockService {
  static final AppLockService instance = AppLockService._();
  AppLockService._();

  static const _prefEnabled = 'app_lock_enabled';
  static const _prefPin    = 'app_lock_pin';
  static const _prefBg     = 'app_lock_bg';   // flag "app sedang/pernah di background"

  bool _enabled = false;
  String? _pin;
  bool _bgFlag = false;   // nilai yang dibaca dari disk saat load()

  bool get enabled => _enabled;
  bool get hasPin => _pin != null && _pin!.isNotEmpty;
  // true bila app sebelumnya dimatikan/proses dikill SAAT ke latar belakang
  bool get wasBackgrounded => _bgFlag;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _enabled = sp.getBool(_prefEnabled) ?? false;
    _pin     = sp.getString(_prefPin);
    _bgFlag  = sp.getBool(_prefBg) ?? false;
  }

  /// Dipanggil saat app ke latar belakang (paused/hidden).
  Future<void> markBackground() async {
    if (!_enabled) return;
    _bgFlag = true;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_prefBg, true);
  }

  /// Dipanggil setelah PIN berhasil diverifikasi (atau saat app kembali ke
  /// depan tanpa kunci aktif) agar flag tidak tersisa.
  Future<void> clearBackground() async {
    _bgFlag = false;
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_prefBg);
  }

  Future<void> enable(String pin) async {
    final sp = await SharedPreferences.getInstance();
    _enabled = true;
    _pin = pin;
    await sp.setBool(_prefEnabled, true);
    await sp.setString(_prefPin, pin);
  }

  Future<void> disable() async {
    final sp = await SharedPreferences.getInstance();
    _enabled = false;
    _pin = null;
    _bgFlag = false;
    await sp.setBool(_prefEnabled, false);
    await sp.remove(_prefPin);
    await sp.remove(_prefBg);
  }

  bool verifyPin(String input) => _pin != null && _pin!.isNotEmpty && input == _pin;

  static const _ch = MethodChannel('kidlearn/lock_task');

  /// Pin app via Android Lock Task Mode — mencegah anak keluar lewat gesture home.
  /// Pertama kali dipanggil, OS menampilkan dialog konfirmasi "Pin app?" ke pengguna.
  Future<void> enterLockTask() async {
    if (!_enabled) return;
    try { await _ch.invokeMethod<void>('start'); } catch (_) {}
  }

  /// Unpin app — dipanggil sebelum orang tua keluar atau menonaktifkan kunci.
  Future<void> exitLockTask() async {
    try { await _ch.invokeMethod<void>('stop'); } catch (_) {}
  }
}
