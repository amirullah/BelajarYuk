import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kidlearn_game/screens/home_v2_screen.dart';
import 'package:kidlearn_game/data/math_generator.dart';

void main() {
  testWidgets('Home menampilkan mata pelajaran', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: HomeV2Screen()));
    await tester.pumpAndSettle();

    // Kartu teratas pasti terlihat di viewport test (800x600).
    expect(find.text('Matematika'), findsOneWidget);
    expect(find.text('Bahasa Inggris'), findsOneWidget);
    expect(find.textContaining('Halo'), findsOneWidget);
  });

  test('MathGenerator menghasilkan soal valid', () {
    final qs = MathGenerator(42).generate(1, count: 15);
    expect(qs.length, 15);
    for (final q in qs) {
      expect(q.options.length, 4);
      expect(q.correctIndex, inInclusiveRange(0, 3));
      expect(q.options[q.correctIndex], isNotEmpty);
    }
  });
}
