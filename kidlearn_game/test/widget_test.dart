import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kidlearn_game/screens/home_v2_screen.dart';
import 'package:kidlearn_game/data/math_generator.dart';
import 'package:kidlearn_game/models/question.dart';
import 'package:kidlearn_game/models/subject.dart';
import 'package:kidlearn_game/models/level.dart';
import 'package:kidlearn_game/services/level_service.dart';

void main() {
  testWidgets('Home menampilkan mata pelajaran', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: HomeV2Screen()));
    // Banner maskot memakai animasi berulang → pumpAndSettle tak akan selesai.
    // Cukup pump beberapa frame agar profil termuat & UI terbentuk.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Kartu teratas pasti terlihat di viewport test (800x600).
    expect(find.text('Matematika'), findsOneWidget);
    expect(find.text('Bahasa Inggris'), findsOneWidget);
    expect(find.textContaining('Halo'), findsOneWidget);
  });

  test('MathGenerator menghasilkan soal valid untuk semua kelas', () {
    for (int grade = 1; grade <= 6; grade++) {
      final qs = MathGenerator(42 + grade).generate(grade, count: 15);
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
  });

  test('Jawaban aritmatika Kelas 1-3 benar secara matematis', () {
    final re = RegExp(r'^(\d+) ([+×÷−-]) (\d+) = \?');
    for (final grade in [1, 2, 3]) {
      for (final q in MathGenerator(7 + grade).generate(grade, count: 40)) {
        final correct = q.type == QuestionType.fillBlank
            ? q.answer!
            : q.options[q.correctIndex];
        final m = re.firstMatch(q.question);
        if (m == null) continue; // soal non-aritmatika
        final a = int.parse(m.group(1)!);
        final b = int.parse(m.group(3)!);
        final int expected;
        switch (m.group(2)) {
          case '+':
            expected = a + b;
            break;
          case '−':
          case '-':
            expected = a - b;
            break;
          case '×':
            expected = a * b;
            break;
          case '÷':
            expected = a ~/ b;
            break;
          default:
            continue;
        }
        expect(correct, expected.toString(), reason: q.question);
      }
    }
  });

  test('Setiap kelas 1-6 & semua mapel menghasilkan level penuh', () {
    final svc = LevelService(1);
    for (int grade = 1; grade <= 6; grade++) {
      for (final s in Subject.values) {
        final level = GameLevel.buildGrade(s, grade).first;
        final qs = svc.buildQuestions(level);
        expect(qs.length, level.questionCount,
            reason: 'Mapel $s Kelas $grade harus punya ${level.questionCount} soal');
        for (final q in qs) {
          expect(q.question.isNotEmpty, isTrue);
        }
      }
    }
  });
}
