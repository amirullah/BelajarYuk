import 'dart:async';
import 'dart:math';
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
  final List<int> _ukuVoiceIds = []; // suara KHAS Uku (celoteh sintetis)
  int _ukuTurn = -1;
  int? _ukuStream; // stream suara Uku yang sedang berbunyi (agar bisa dihentikan)
  bool _ukuMuted = false; // flag untuk membatalkan ukuVoice yang masih await
  final _rng = Random();

  int? _musicStream; // stream musik yang sedang berputar
  String? _currentMusic; // kunci trek yang sedang diputar

  static const _sfxFiles = [
    'correct', 'wrong', 'tap', 'star', 'coin', 'levelup', 'perfect',
    'graduation', 'uku', 'aww',
  ];
  // Sorak "yay" ekspresif khas anak untuk jawaban BENAR (bergiliran acak).
  static const _cheerFiles = ['yay1', 'yay2', 'yay3'];
  final List<int> _cheerIds = [];
  int _cheerTurn = -1;
  // Suara khas Uku (celoteh burung hantu, disintesis sendiri) — bukan TTS,
  // jadi jelas berbeda dari suara benar/salah. Diputar bergiliran acak.
  static const _ukuVoiceFiles = [
    'uku_v1', 'uku_v2', 'uku_v3', 'uku_v4', 'uku_v5', 'uku_v6',
  ];

  static const double _musicVol = 0.30; // volume musik latar normal
  static const double _duckVol = 0.08; // volume saat "ditekan" (mis. sorak)
  // Nama trek = 'home' + nilai enum Subject.
  static const _musicFiles = [
    'home', 'math', 'english', 'indonesian', 'science', 'religion',
    'socialStudies',
  ];
  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _enabled = sp.getBool(_prefKey) ?? true;
    _musicEnabled = sp.getBool(_musicKey) ?? true;
    try {
      // maxStreams > 1 WAJIB: default 1 membuat efek suara (mis. sentuh maskot)
      // menghentikan musik latar karena berebut satu-satunya stream.
      _pool = Soundpool.fromOptions(
        options: const SoundpoolOptions(
            streamType: StreamType.music, maxStreams: 12),
      );
      for (final name in _sfxFiles) {
        final data = await rootBundle.load('assets/sfx/$name.wav');
        _sfxIds[name] = await _pool!.load(data);
      }
      for (final name in _musicFiles) {
        // Musik dikompresi ke OGG (jauh lebih kecil dari WAV) — hemat ukuran APK.
        final data = await rootBundle.load('assets/sfx/music_$name.ogg');
        _musicIds[name] = await _pool!.load(data);
      }
      for (final name in _ukuVoiceFiles) {
        try {
          final data = await rootBundle.load('assets/sfx/$name.wav');
          _ukuVoiceIds.add(await _pool!.load(data));
        } catch (_) {}
      }
      for (final name in _cheerFiles) {
        try {
          final data = await rootBundle.load('assets/sfx/$name.wav');
          _cheerIds.add(await _pool!.load(data));
        } catch (_) {}
      }
    } catch (_) {
      _pool = null; // audio tak tersedia — app tetap jalan tanpa suara
    }
    // Karena load() kini berjalan di LATAR, sebuah layar mungkin sudah meminta
    // musik (mis. beranda) sebelum pool siap → permintaan itu terlewat. Setelah
    // pool siap, mulai musik yang terakhir diminta agar tetap berbunyi.
    if (_pool != null && _musicEnabled && _currentMusic != null) {
      unawaited(playMusic(_currentMusic!));
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

  String? _playingKey;
  String? _desiredMusic; // trek yang diinginkan (target)
  bool _musicBusy = false; // kunci agar tak ada dua loop tumpang-tindih

  /// Putar trek [key] (loop) dengan fade-in. Aman dipanggil bersamaan/cepat:
  /// permintaan dikumpulkan lewat [_desiredMusic] dan diproses satu per satu,
  /// sehingga tidak pernah ada dua musik berputar sekaligus.
  Future<void> playMusic(String key) async {
    _currentMusic = key;
    _desiredMusic = key;
    if (!_musicEnabled || _pool == null || _musicIds[key] == null) return;
    if (_playingKey == key && _musicStream != null) return; // sudah main
    if (_musicBusy) return; // sedang berganti — loop di bawah akan menanganinya
    _musicBusy = true;
    try {
      while (_desiredMusic != null &&
          _desiredMusic != _playingKey &&
          _musicEnabled) {
        await _switchTo(_desiredMusic!);
      }
    } finally {
      _musicBusy = false;
    }
  }

  /// Ganti ke satu trek: hentikan yang lama lalu mainkan yang baru (dengan fade).
  Future<void> _switchTo(String key) async {
    final pool = _pool;
    final id = _musicIds[key];
    if (pool == null || id == null) return;
    if (_musicStream != null) {
      try {
        await pool.stop(_musicStream!);
      } catch (_) {}
      _musicStream = null;
      _playingKey = null;
    }
    try {
      final s = await pool.play(id, repeat: -1);
      _musicStream = s;
      _playingKey = key;
      await _fadeTo(_musicVol, steps: 6, ms: 360);
    } catch (_) {}
  }

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
    _desiredMusic = null; // jangan biarkan loop menyalakan kembali
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
  Future<void> uku() => _play('uku');
  Future<void> aww() => _play('aww'); // salah — lembut & menyemangati

  /// Sorak "yay" ekspresif khas anak untuk jawaban BENAR (acak, tak berulang).
  Future<void> cheer() async {
    if (!_enabled) return;
    final pool = _pool;
    if (pool == null || _cheerIds.isEmpty) return;
    int i = _cheerTurn;
    while (i == _cheerTurn && _cheerIds.length > 1) {
      i = _rng.nextInt(_cheerIds.length);
    }
    if (i < 0) i = 0;
    _cheerTurn = i;
    try {
      await pool.play(_cheerIds[i]);
    } catch (_) {}
  }

  /// Suara KHAS Uku (celoteh) — dipakai saat Uku menyapa/mengintip/disentuh.
  /// Bergiliran acak & tak mengulang berturut-turut agar bervariasi.
  Future<void> ukuVoice() async {
    if (!_enabled) return;
    final pool = _pool;
    if (pool == null || _ukuVoiceIds.isEmpty) return;
    int i = _ukuTurn;
    while (i == _ukuTurn && _ukuVoiceIds.length > 1) {
      i = _rng.nextInt(_ukuVoiceIds.length);
    }
    if (i < 0) i = 0;
    _ukuTurn = i;
    _ukuMuted = false;
    try {
      final stream = await pool.play(_ukuVoiceIds[i]);
      // Bila stopUku() dipanggil saat play masih await, batalkan segera.
      if (_ukuMuted) {
        try { await pool.stop(stream); } catch (_) {}
        return;
      }
      _ukuStream = stream;
    } catch (_) {}
  }

  /// Hentikan suara Uku bila sedang berbunyi — termasuk yang masih dalam await.
  Future<void> stopUku() async {
    _ukuMuted = true;
    final pool = _pool;
    final s = _ukuStream;
    if (pool != null && s != null) {
      try {
        await pool.stop(s);
      } catch (_) {}
    }
    _ukuStream = null;
  }
}
