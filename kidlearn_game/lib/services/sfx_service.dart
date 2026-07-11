import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundpool/soundpool.dart';

/// Efek suara (SFX) & musik latar BelajarYuk!.
/// Semua audio dibuat sendiri (WAV, di assets/sfx/) — disintesis via numpy.
///
/// - Efek suara: benar, salah, ketuk, bintang, koin, naik level, sempurna.
/// - Musik latar berbeda per konteks: beranda + tiap mata pelajaran, agar
///   anak tidak bosan. Diputar berulang (loop) dengan volume rendah.
class SfxService {
  static final SfxService instance = SfxService._();
  SfxService._();

  static const _prefKey = 'sfx_enabled';
  static const _musicKey = 'music_enabled';
  bool _enabled = true;
  bool _musicEnabled = true; // default nyala — musik menambah semangat
  bool get enabled => _enabled;
  bool get musicEnabled => _musicEnabled;

  Soundpool? _pool;
  final Map<String, int> _sfxIds = {};
  final Map<String, int> _musicIds = {};
  final List<int> _voiceIds = []; // klip suara anak (CC0) untuk pujian
  int _voiceTurn = 0;

  int? _musicStream; // stream musik yang sedang berputar
  String? _currentMusic; // kunci trek yang sedang diputar

  static const _sfxFiles = [
    'correct', 'wrong', 'tap', 'star', 'coin', 'levelup', 'perfect',
    'graduation',
  ];

  static const double _musicVol = 0.30; // volume musik latar normal
  static const double _duckVol = 0.08; // volume saat "ditekan" (mis. sorak)
  // Nama trek = 'home' + nilai enum Subject.
  static const _musicFiles = [
    'home', 'math', 'english', 'indonesian', 'science', 'religion',
    'socialStudies',
  ];
  // Rekaman suara anak (CC0). Bisa ditambah/diganti pengguna.
  static const _voiceFiles = ['voice_yay.mp3'];

  bool get hasVoice => _voiceIds.isNotEmpty;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _enabled = sp.getBool(_prefKey) ?? true;
    _musicEnabled = sp.getBool(_musicKey) ?? true;
    try {
      _pool = Soundpool.fromOptions(
        options: const SoundpoolOptions(streamType: StreamType.music),
      );
      for (final name in _sfxFiles) {
        final data = await rootBundle.load('assets/sfx/$name.wav');
        _sfxIds[name] = await _pool!.load(data);
      }
      for (final name in _musicFiles) {
        final data = await rootBundle.load('assets/sfx/music_$name.wav');
        _musicIds[name] = await _pool!.load(data);
      }
      // Klip suara anak (opsional) — abaikan bila file tak ada.
      for (final vf in _voiceFiles) {
        try {
          final data = await rootBundle.load('assets/voice/$vf');
          _voiceIds.add(await _pool!.load(data));
        } catch (_) {}
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

  Future<void> setMusicEnabled(bool v) async {
    _musicEnabled = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_musicKey, v);
    if (v) {
      await playMusic(_currentMusic ?? 'home');
    } else {
      await stopMusic();
    }
  }

  /// Putar trek [key] (loop) dengan fade-in agar pergantian musik halus.
  /// Jika trek yang sama sudah berputar, biarkan (tidak restart).
  Future<void> playMusic(String key) async {
    _currentMusic = key;
    final pool = _pool;
    final id = _musicIds[key];
    if (!_musicEnabled || pool == null || id == null) return;
    if (_musicStream != null && _playingKey == key) return;
    await stopMusic();
    try {
      _musicStream = await pool.play(id, repeat: -1);
      _playingKey = key;
      await _fadeTo(_musicVol, steps: 6, ms: 360);
    } catch (_) {}
  }

  String? _playingKey;

  /// Ramp volume musik ke [target] secara bertahap (fade halus).
  Future<void> _fadeTo(double target, {int steps = 6, int ms = 300}) async {
    final pool = _pool;
    final s = _musicStream;
    if (pool == null || s == null) return;
    for (int i = 1; i <= steps; i++) {
      final v = target * i / steps;
      try {
        await pool.setVolume(streamId: s, volume: v);
      } catch (_) {}
      await Future.delayed(Duration(milliseconds: (ms / steps).round()));
    }
  }

  /// Turunkan volume musik sejenak (mis. saat sorak/pengumuman) lalu pulihkan.
  Future<void> duckMusic({int restoreAfterMs = 2200}) async {
    final pool = _pool;
    final s = _musicStream;
    if (pool == null || s == null) return;
    try {
      await pool.setVolume(streamId: s, volume: _duckVol);
    } catch (_) {}
    Future.delayed(Duration(milliseconds: restoreAfterMs), () async {
      if (_musicStream == s) await _fadeTo(_musicVol, steps: 5, ms: 400);
    });
  }

  Future<void> stopMusic() async {
    final pool = _pool;
    final s = _musicStream;
    if (pool != null && s != null) {
      try {
        await pool.stop(s);
      } catch (_) {}
    }
    _musicStream = null;
    _playingKey = null;
  }

  /// Jeda musik (mis. saat app ke latar belakang) tanpa kehilangan trek.
  Future<void> pauseMusic() async {
    final pool = _pool;
    final s = _musicStream;
    if (pool == null || s == null) return;
    try {
      await pool.pause(s);
    } catch (_) {}
  }

  /// Lanjutkan musik saat app kembali aktif.
  Future<void> resumeMusic() async {
    final pool = _pool;
    if (pool == null || !_musicEnabled) return;
    final s = _musicStream;
    if (s != null) {
      try {
        await pool.resume(s);
        return;
      } catch (_) {}
    }
    await playMusic(_currentMusic ?? 'home');
  }

  Future<void> _play(String name) async {
    if (!_enabled) return;
    final pool = _pool;
    final id = _sfxIds[name];
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
  Future<void> graduation() => _play('graduation');

  /// Putar satu klip suara anak (bergiliran). Return true bila dimainkan.
  Future<bool> voice() async {
    if (!_enabled || _voiceIds.isEmpty) return false;
    final pool = _pool;
    if (pool == null) return false;
    final id = _voiceIds[_voiceTurn % _voiceIds.length];
    _voiceTurn++;
    try {
      await pool.play(id);
      return true;
    } catch (_) {
      return false;
    }
  }
}
