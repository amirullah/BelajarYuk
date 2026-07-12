import 'package:shared_preferences/shared_preferences.dart';

/// Kunci Aplikasi Anak — mencegah anak keluar app tanpa PIN orang tua.
/// Bila aktif: saat app kembali dari latar belakang, layar PIN muncul.
class AppLockService {
  static final AppLockService instance = AppLockService._();
  AppLockService._();

  static const _prefEnabled = 'app_lock_enabled';
  static const _prefPin = 'app_lock_pin';

  bool _enabled = false;
  String? _pin;

  bool get enabled => _enabled;
  bool get hasPin => _pin != null && _pin!.isNotEmpty;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _enabled = sp.getBool(_prefEnabled) ?? false;
    _pin = sp.getString(_prefPin);
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
    await sp.setBool(_prefEnabled, false);
    await sp.remove(_prefPin);
  }

  bool verifyPin(String input) => _pin != null && _pin!.isNotEmpty && input == _pin;
}
