import 'package:flutter_test/flutter_test.dart';
import 'package:kidlearn_game/models/subject.dart';
import 'package:kidlearn_game/models/level.dart';
import 'package:kidlearn_game/models/question.dart';
import 'package:kidlearn_game/services/level_service.dart';

/// Kesulitan soal non-Matematika naik seiring level: level awal lebih mudah,
/// level akhir lebih sulit (setelah soal ditandai difficulty 1/2/3).
void main() {
  double avgDiff(List<Question> qs) =>
      qs.isEmpty ? 0 : qs.map((q) => q.difficulty).reduce((a, b) => a + b) / qs.length;

  test('Level akhir ≥ level awal, dan agregat naik jelas (non-Matematika)', () {
    final svc = LevelService(1);
    double sumEarly = 0, sumLate = 0;
    for (int grade = 1; grade <= 6; grade++) {
      for (final s in Subject.values) {
        if (s == Subject.math) continue;
        final levels = GameLevel.buildGrade(s, grade);
        final early = avgDiff(svc.buildQuestions(levels[0])); // level 1
        final late = avgDiff(svc.buildQuestions(levels[11])); // level 12 (boss)
        expect(late, greaterThanOrEqualTo(early),
            reason: 'Kesulitan $s Kelas $grade turun (L12 $late < L1 $early)');
        sumEarly += early;
        sumLate += late;
      }
    }
    // Secara keseluruhan, level akhir HARUS jelas lebih sulit dari level awal.
    expect(sumLate, greaterThan(sumEarly),
        reason: 'Agregat kesulitan level akhir harus > level awal '
            '(late=$sumLate, early=$sumEarly)');
  });

  test('Antar-level DISJOIN: tak ada soal sama muncul di dua level berbeda '
      '(Level 1-11, non-Matematika)', () {
    final svc = LevelService(1);
    for (int grade = 1; grade <= 6; grade++) {
      for (final s in Subject.values) {
        if (s == Subject.math) continue;
        final levels = GameLevel.buildGrade(s, grade);
        final seen = <String>{};
        // Level 1..11 harus benar-benar disjoin (boss/Level 12 boleh mengulang
        // soal TERSULIT sebagai review bila bank lebih kecil dari total slot).
        for (int i = 0; i < 11; i++) {
          for (final q in svc.buildQuestions(levels[i])) {
            expect(seen.contains(q.question), isFalse,
                reason: 'Soal berulang antar-level di $s Kelas $grade: '
                    '"${q.question}" (Level ${levels[i].index})');
            seen.add(q.question);
          }
        }
      }
    }
  });

  test('B2: kelas lebih tinggi lebih menantang secara AGREGAT (konten sesuai '
      'jenjang)', () {
    final svc = LevelService(1);
    // Rerata kesulitan seluruh 12 level untuk satu (mapel, kelas).
    double gradeAvg(int grade) {
      double sum = 0;
      int nLevels = 0;
      for (final s in Subject.values) {
        if (s == Subject.math) continue;
        for (final lvl in GameLevel.buildGrade(s, grade)) {
          sum += avgDiff(svc.buildQuestions(lvl));
          nLevels++;
        }
      }
      return sum / nLevels;
    }

    // Bank tiap kelas ditulis makin sulit sesuai jenjang: rerata kesulitan
    // jenjang atas (Kelas 4-6) HARUS jelas lebih tinggi dari jenjang bawah
    // (Kelas 1-2), dan Kelas 6 lebih sulit dari Kelas 1.
    final low = (gradeAvg(1) + gradeAvg(2)) / 2;
    final high = (gradeAvg(4) + gradeAvg(5) + gradeAvg(6)) / 3;
    expect(high, greaterThan(low),
        reason: 'Kelas atas harus lebih menantang dari kelas bawah '
            '(atas=$high, bawah=$low)');
    expect(gradeAvg(6), greaterThan(gradeAvg(1)),
        reason: 'Kelas 6 harus lebih menantang dari Kelas 1');
  });
}
