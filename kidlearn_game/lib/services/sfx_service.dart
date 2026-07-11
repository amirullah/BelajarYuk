import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundpool/soundpool.dart';

/// Efek suara (SFX) BelajarYuk!: benar, salah, ketuk, bintang, koin,
/// naik level, sempurna. Semua file dibuat sendiri (WAV, di assets/sfx/).
///
/// Memakai [Soundpool] (Android SoundPool) — ringan & latensi rendah untuk
/// suara pendek. Bisa dimatikan lewat pengaturan.
class SfxService {
  static final SfxService instance = SfxService._();
  SfxService._();

  static const _prefKey = 'sfx_enabled';
  bool _enabled = true;
  bool get enabled => _enabled;

  Soundpool? _pool;
  final Map<String, int> _ids = {};

  static const _files = [
    'correct', 'wrong', 'tap', 'star', 'coin', 'levelup', 'perfect',
  ];

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _enabled = sp.getBool(_prefKey) ?? true;
    try {
      _pool = Soundpool.fromOptions(
        options: const SoundpoolOptions(streamType: StreamType.music),
      );
      for (final name in _files) {
        final data = await rootBundle.load('assets/sfx/$name.wav');
        _ids[name] = await _pool!.load(data);
      }
    } catch (_) {
      _pool = null; // audio tak tersedia — app tetap jalan tanpa suara
    }
  }

  Future<void> setEnabled(bool v) async {
    _enabled = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_prefKey, v);
  }

  Future<void> _play(String name) async {
    if (!_enabled) return;
    final pool = _pool;
    final id = _ids[name];
    if (pool == null || id == null) return;
    try {
      await pool.play(id);
    } catch (_) {}
  }

  Future<void> correct() => _play('correct');
  Future<void> wrong() => _play('wrong');
  Future<void> tap() => _play('tap');
  Future<void> star() => _play('star');
  Future<void> coin() => _play('coin');
  Future<void> levelUp() => _play('levelup');
  Future<void> perfect() => _play('perfect');
}
