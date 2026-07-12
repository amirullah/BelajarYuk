import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidlearn_game/models/subject.dart';
import 'package:kidlearn_game/models/question.dart';
import 'package:kidlearn_game/data/content_kelas1.dart';
import 'package:kidlearn_game/data/content_kelas2.dart';
import 'package:kidlearn_game/data/content_kelas3.dart';
import 'package:kidlearn_game/data/content_kelas4.dart';
import 'package:kidlearn_game/data/content_kelas5.dart';
import 'package:kidlearn_game/data/content_kelas6.dart';

/// Ekspor bank soal bawaan ke `content.json` (untuk update soal TANPA APK).
/// Hanya berjalan bila diminta lewat env var, agar tidak menulis file saat
/// menjalankan seluruh suite:
///   EXPORT_CONTENT=1 CONTENT_VERSION=3 flutter test test/export_content_test.dart
void main() {
  test('Ekspor content.json (opt-in via EXPORT_CONTENT)', () {
    if (Platform.environment['EXPORT_CONTENT'] == null) {
      return; // no-op dalam suite normal
    }
    final version =
        int.tryParse(Platform.environment['CONTENT_VERSION'] ?? '1') ?? 1;
    final out = Platform.environment['CONTENT_OUT'] ?? '../landing/content.json';

    final rawBank = <int, List<Question> Function(Subject)>{
      1: ContentKelas1.forSubject,
      2: ContentKelas2.forSubject,
      3: ContentKelas3.forSubject,
      4: ContentKelas4.forSubject,
      5: ContentKelas5.forSubject,
      6: ContentKelas6.forSubject,
    };

    final banks = <String, dynamic>{};
    int total = 0;
    for (int grade = 1; grade <= 6; grade++) {
      for (final s in Subject.values) {
        if (s == Subject.math) continue;
        final qs = rawBank[grade]!(s);
        banks['$grade|${s.name}'] = qs.map((q) => q.toJson()).toList();
        total += qs.length;
      }
    }
    File(out).writeAsStringSync(jsonEncode({'content': version, 'banks': banks}));
    // ignore: avoid_print
    print('Ditulis $out — versi $version, $total soal, ${banks.length} bank.');
    expect(total, greaterThan(0));
  });
}
