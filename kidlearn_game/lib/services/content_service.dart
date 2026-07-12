import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../models/subject.dart';

/// Menyediakan bank soal yang BISA DIPERBARUI DARI SERVER tanpa memasang ulang
/// APK. Soal disimpan sebagai `content.json` statis di hosting; aplikasi
/// mengunduhnya, menyimpannya (cache), lalu memakainya menimpa bank bawaan.
///
/// Alur aman:
///  - Saat buka: [loadFromCache] memuat konten tersimpan (bila ada) — instan,
///    tanpa jaringan. Bila belum ada cache, LevelService memakai bank BAWAAN.
///  - Di latar: [refreshFromServer] mengecek versi konten; bila server lebih
///    baru, unduh & simpan → dipakai pada sesi berikutnya (atau setelah reload).
///  - Semua kegagalan (offline/JSON rusak) diabaikan diam-diam → app tetap jalan
///    memakai bank bawaan.
class ContentService {
  static final ContentService instance = ContentService._(http.Client());
  ContentService._(this._client);

  /// Untuk pengujian: instance dengan klien HTTP yang disuntik.
  factory ContentService.test(http.Client client) =>
      ContentService._(client);

  static const String contentUrl =
      'https://belajaryuk.mkz.my.id/content.json';
  static const String versionUrl =
      'https://belajaryuk.mkz.my.id/version.json';
  static const String _prefJson = 'content_json';
  static const String _prefVersion = 'content_version';
  static const String bundledAsset = 'assets/content.json';

  final http.Client _client;

  int _loadedVersion = 0;
  final Map<String, List<Question>> _banks = {};
  bool get hasContent => _banks.isNotEmpty;
  int get loadedVersion => _loadedVersion;

  String _key(Subject s, int grade) => '$grade|${s.name}';

  /// Bank soal server untuk (mapel, kelas); null bila belum ada → pakai bawaan.
  List<Question>? forSubject(Subject s, int grade) => _banks[_key(s, grade)];

  /// Muat konten yang DIBUNDEL di APK (assets/content.json) sebagai basis.
  /// Selalu tersedia (offline / pemasangan baru). Dipakai bila versinya lebih
  /// tinggi dari yang sudah dimuat (mis. APK baru membawa konten lebih baru
  /// daripada cache server lama).
  Future<void> loadBundledAsset() async {
    try {
      final raw = await rootBundle.loadString(bundledAsset);
      _parseInto(raw);
    } catch (_) {
      // aset tak ada / rusak → abaikan, LevelService pakai bank Dart bawaan
    }
  }

  /// Muat konten dari cache lokal (hasil unduhan server sebelumnya) — cepat,
  /// tanpa jaringan. Dipakai bila versinya lebih tinggi dari yang sudah dimuat.
  Future<void> loadFromCache() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_prefJson);
      if (raw == null || raw.isEmpty) return;
      _parseInto(raw);
    } catch (_) {
      // cache rusak → abaikan, pakai bawaan
    }
  }

  /// Cek versi konten di server; bila lebih baru, unduh & simpan ke cache.
  /// Mengembalikan true bila cache diperbarui.
  Future<bool> refreshFromServer() async {
    try {
      final client = _client;
      // 1) Cek versi ringan lewat version.json (kecil).
      final serverVersion = await _serverContentVersion(client);
      final sp = await SharedPreferences.getInstance();
      final cachedVersion = sp.getInt(_prefVersion) ?? 0;
      if (serverVersion <= cachedVersion && cachedVersion != 0) {
        return false; // sudah terbaru
      }
      // 2) Unduh konten penuh & validasi.
      final res = await client
          .get(Uri.parse(contentUrl))
          .timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return false;
      final ver = _versionOf(res.body);
      if (ver <= 0) return false;
      // Hanya adopsi bila benar-benar lebih baru dari cache.
      if (ver <= cachedVersion && cachedVersion != 0) return false;
      // Validasi bisa di-parse sebelum menyimpan.
      final parsed = _parse(res.body);
      if (parsed.isEmpty) return false;
      await sp.setString(_prefJson, res.body);
      await sp.setInt(_prefVersion, ver);
      _banks
        ..clear()
        ..addAll(parsed);
      _loadedVersion = ver;
      return true;
    } catch (_) {
      return false; // best-effort
    }
  }

  Future<int> _serverContentVersion(http.Client client) async {
    try {
      final res = await client
          .get(Uri.parse(versionUrl))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return 1 << 30; // tak tahu → paksa cek konten
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return (j['content'] as num?)?.toInt() ?? (1 << 30);
    } catch (_) {
      return 1 << 30; // gagal cek versi → biarkan langkah unduh yang memutuskan
    }
  }

  int _versionOf(String body) {
    try {
      final j = jsonDecode(body) as Map<String, dynamic>;
      return (j['content'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Adopsi konten [body] HANYA bila versinya lebih tinggi dari yang sudah
  /// dimuat — sehingga sumber terbaru (bundel APK / cache server) selalu menang,
  /// apa pun urutan pemanggilannya.
  void _parseInto(String body) {
    final version = _versionOf(body);
    if (_banks.isNotEmpty && version <= _loadedVersion) return;
    final parsed = _parse(body);
    if (parsed.isEmpty) return;
    _banks
      ..clear()
      ..addAll(parsed);
    _loadedVersion = version;
  }

  Map<String, List<Question>> _parse(String body) {
    final out = <String, List<Question>>{};
    final j = jsonDecode(body) as Map<String, dynamic>;
    final banks = j['banks'];
    if (banks is! Map) return out;
    banks.forEach((key, value) {
      if (value is List) {
        final list = <Question>[];
        for (final item in value) {
          if (item is Map) {
            list.add(Question.fromJson(item.cast<String, dynamic>()));
          }
        }
        if (list.isNotEmpty) out['$key'] = list;
      }
    });
    return out;
  }
}
