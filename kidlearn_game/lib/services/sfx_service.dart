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
  static const _musicKey = 'music_enabled';
  bool _enabled = true;
  bool _musicEnabled = false; // default mati — musik latar bersifat opsional
  bool get enabled => _enabled;
  bool get musicEnabled => _musicEnabled;

  Soundpool? _pool;
  final Map<String, int> _ids = {};

  int? _musicId;
  int? _musicStream; // stream aktif saat musik diputar

  static const _files = [
    'correct', 'wrong', 'tap', 'star', 'coin', 'levelup', 'perfect',
  ];

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _enabled = sp.getBool(_prefKey) ?? true;
    _musicEnabled = sp.getBool(_musicKey) ?? false;
    try {
      _pool = Soundpool.fromOptions(
        options: const SoundpoolOptions(streamType: StreamType.music),
      );
      for (final name in _files) {
        final data = await rootBundle.load('assets/sfx/$name.wav');
        _ids[name] = await _pool!.load(data);
      }
      final music = await rootBundle.load('assets/sfx/bg_music.wav');
      _musicId = await _pool!.load(music);
    } catch (_) {
      _pool = null; // audio tak tersedia — app tetap jalan tanpa suara
    }
  }

  Future<void> setEnabled(bool v) async {
    _enabled = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_prefKey, v);
  }

  Future<void> setMusicEnabled(bool v) async {
    _musicEnabled = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_musicKey, v);
    if (v) {
      await startMusic();
    } else {
      await stopMusic();
    }
  }

  /// Mulai musik latar (loop) bila diaktifkan. Aman dipanggil berulang.
  Future<void> startMusic() async {
    final pool = _pool;
    final id = _musicId;
    if (!_musicEnabled || pool == null || id == null || _musicStream != null) {
      return;
    }
    try {
      _musicStream = await pool.play(id, repeat: -1);
      await pool.setVolume(streamId: _musicStream, volume: 0.35);
    } catch (_) {}
  }

  Future<void> stopMusic() async {
    final pool = _pool;
    final s = _musicStream;
    if (pool == null || s == null) return;
    try {
      await pool.stop(s);
    } catch (_) {}
    _musicStream = null;
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
