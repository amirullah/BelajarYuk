import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidlearn_game/data/math_generator.dart';
import 'package:kidlearn_game/models/question.dart';

/// Matematika: SETIAP kelas (1-6) harus terasa lebih sulit di level akhir
/// dibanding level awal — angka pada soal jelas lebih besar (lantai naik).
void main() {
  int maxNumber(List<Question> qs) {
    int m = 0;
    for (final q in qs) {
      final text = '${q.question} '
          '${q.options.join(" ")} ${q.answer ?? ""}';
      for (final match in RegExp(r'\d+').allMatches(text)) {
        m = max(m, int.parse(match.group(0)!));
      }
    }
    return m;
  }

  test('Semua kelas 1-6: level akhir memakai angka lebih besar dari level awal',
      () {
    for (int grade = 1; grade <= 6; grade++) {
      final early = maxNumber(MathGenerator(3).generate(grade, count: 40, level: 1));
      final late = maxNumber(MathGenerator(3).generate(grade, count: 40, level: 12));
      expect(late, greaterThan(early),
          reason: 'Kelas $grade: angka level 12 ($late) harus > level 1 ($early)');
    }
  });

  test('Semua kelas 1-6: soal tetap valid di level 1 & 12', () {
    for (int grade = 1; grade <= 6; grade++) {
      for (final level in [1, 6, 12]) {
        final qs = MathGenerator(5).generate(grade, count: 15, level: level);
        expect(qs.length, 15);
        for (final q in qs) {
          if (q.type == QuestionType.fillBlank) {
            expect(q.answer, isNotNull);
            expect(q.answer!.isNotEmpty, isTrue);
          } else {
            expect(q.options.length, 4);
            expect(q.correctIndex, inInclusiveRange(0, 3));
            expect(q.options[q.correctIndex], isNotEmpty);
          }
        }
      }
    }
  });
}
