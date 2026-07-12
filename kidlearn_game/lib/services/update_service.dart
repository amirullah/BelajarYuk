import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app_version.dart';

/// Info versi terbaru yang diambil dari server.
class UpdateInfo {
  final String version; // mis. "2.1.4"
  final int build; // versionCode terbaru
  final String url; // tautan unduh APK
  final String notes; // ringkasan pembaruan
  final bool mandatory; // bila true, sebaiknya dipaksa perbarui

  const UpdateInfo({
    required this.version,
    required this.build,
    required this.url,
    required this.notes,
    required this.mandatory,
  });
}

/// Mengecek apakah ada versi aplikasi yang lebih baru di server.
///
/// Server menaruh berkas statis `version.json` di root hosting, mis.:
/// {
///   "version": "2.1.4",
///   "build": 29,
///   "url": "https://belajaryuk.mkz.my.id/BelajarYuk.apk",
///   "notes": "Perbaikan soal & suara",
///   "mandatory": false
/// }
///
/// Pengecekan bersifat "best-effort": bila offline / gagal / JSON rusak,
/// mengembalikan null (aplikasi tetap jalan normal, tanpa mengganggu anak).
class UpdateService {
  static const String versionUrl =
      'https://belajaryuk.mkz.my.id/version.json';
  static const String fallbackApk =
      'https://belajaryuk.mkz.my.id/BelajarYuk.apk';

  final http.Client _client;
  UpdateService([http.Client? client]) : _client = client ?? http.Client();

  /// Kembalikan [UpdateInfo] bila server punya build lebih baru dari yang
  /// terpasang; null bila sudah terbaru atau tak bisa dicek.
  Future<UpdateInfo?> check() async {
    try {
      final res = await _client
          .get(Uri.parse(versionUrl))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final build = (j['build'] as num?)?.toInt() ?? 0;
      if (build <= AppVersion.build) return null; // sudah versi terbaru
      final url = (j['url'] as String?)?.trim();
      return UpdateInfo(
        version: (j['version'] as String?)?.trim() ?? '',
        build: build,
        url: (url != null && url.isNotEmpty) ? url : fallbackApk,
        notes: (j['notes'] as String?)?.trim() ?? '',
        mandatory: j['mandatory'] == true,
      );
    } catch (_) {
      return null; // best-effort — jangan pernah mengganggu bila gagal
    }
  }
}
