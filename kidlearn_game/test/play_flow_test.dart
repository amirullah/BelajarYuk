import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kidlearn_game/screens/play_screen.dart';
import 'package:kidlearn_game/models/subject.dart';
import 'package:kidlearn_game/models/level.dart';
import 'package:kidlearn_game/widgets/game_button.dart';

/// Tes ALUR BERMAIN pada kode asli: buka level Matematika Kelas 1, jawab soal
/// pertama dengan BENAR, lalu pastikan soal maju ke berikutnya. Karena PlayScreen
/// membangun soalnya sendiri, kita pakai `seed` agar deterministik.
void main() {
  // Bungkam plugin flutter_tts agar tak melempar di lingkungan test.
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('flutter_tts'), (call) async => 1);
    SharedPreferences.setMockInitialValues({});
  });

  // Cari teks soal aritmatika "a + b = ?" / "a − b = ?" di antara widget Text.
  ({int expected})? findArithmetic(WidgetTester tester) {
    final re = RegExp(r'(\d+)\s*([+−-])\s*(\d+)\s*=\s*\?');
    for (final w in tester.widgetList<Text>(find.byType(Text))) {
      final data = w.data ?? '';
      final m = re.firstMatch(data);
      if (m == null) continue;
      final a = int.parse(m.group(1)!);
      final b = int.parse(m.group(3)!);
      final op = m.group(2)!;
      return (expected: op == '+' ? a + b : a - b);
    }
    return null;
  }

  testWidgets('Jawab benar → soal maju ke berikutnya', (tester) async {
    final level = GameLevel.buildGrade(Subject.math, 1).first;
    await tester.pumpWidget(
      MaterialApp(home: PlayScreen(level: level, seed: 7)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Soal pertama tampil.
    expect(find.textContaining('Soal 1/'), findsOneWidget);

    final arith = findArithmetic(tester);
    expect(arith, isNotNull, reason: 'Soal Kelas 1 harus aritmatika');
    final answer = arith!.expected.toString();

    // Jawab: isian (TextField) atau pilihan ganda (GameButton).
    if (find.byType(TextField).evaluate().isNotEmpty) {
      await tester.enterText(find.byType(TextField), answer);
      await tester.testTextInput.receiveAction(TextInputAction.done);
    } else {
      // GameButton memuat teks pilihan; ketuk tombol dengan jawaban benar.
      await tester.tap(find.widgetWithText(GameButton, answer).first);
    }

    // Lewati timer auto-lanjut (~1050ms) + beberapa frame animasi.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 400));

    // Soal harus sudah maju.
    expect(find.textContaining('Soal 2/'), findsOneWidget,
        reason: 'Setelah jawaban benar, soal harus maju ke 2');

    // Buang PlayScreen agar timer 14 detik (idle) dibatalkan di dispose.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
  });
}
