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

  test('B2: kelas lebih tinggi MEMULAI dari tingkat lebih sulit (tak reset mudah)',
      () {
    final svc = LevelService(1);
    double startAvg(Subject s, int grade) =>
        avgDiff(svc.buildQuestions(GameLevel.buildGrade(s, grade).first));
    for (final s in Subject.values) {
      if (s == Subject.math) continue;
      // Level 1 Kelas 3 tidak boleh lebih mudah dari Level 1 Kelas 1
      // (Kelas 3+ melewati intro mudah).
      expect(startAvg(s, 3), greaterThan(startAvg(s, 1)),
          reason: '$s: awal Kelas 3 harus lebih sulit dari awal Kelas 1');
    }
  });
}
