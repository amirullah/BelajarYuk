import 'package:flutter_test/flutter_test.dart';
import 'package:kidlearn_game/models/level.dart';
import 'package:kidlearn_game/models/subject.dart';

/// Gerbang NAIK KELAS: hanya boleh naik bila boss (level 12) SEMUA mapel lulus.
void main() {
  String bossId(Subject s, int grade) =>
      GameLevel.buildGrade(s, grade).last.id;

  test('Lulus 1 mapel saja TIDAK cukup untuk naik kelas', () {
    final passed = <String>{bossId(Subject.math, 1)}; // hanya Matematika
    final cleared =
        GameLevel.subjectsCleared(1, (id) => passed.contains(id));
    expect(cleared, 1);
    expect(cleared == Subject.values.length, isFalse); // belum boleh naik
  });

  test('Lulus SEMUA mapel → boleh naik kelas', () {
    final passed = {for (final s in Subject.values) bossId(s, 1)};
    final cleared =
        GameLevel.subjectsCleared(1, (id) => passed.contains(id));
    expect(cleared, Subject.values.length);
    expect(cleared == Subject.values.length, isTrue);
  });

  test('Boss mapel dari kelas LAIN tak dihitung untuk kelas ini', () {
    // Semua boss Kelas 2 lulus, tapi kita cek Kelas 1 → 0.
    final passed = {for (final s in Subject.values) bossId(s, 2)};
    final cleared =
        GameLevel.subjectsCleared(1, (id) => passed.contains(id));
    expect(cleared, 0);
  });
}
