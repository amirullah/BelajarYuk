import 'package:flutter_test/flutter_test.dart';
import 'package:kidlearn_game/models/question.dart';
import 'package:kidlearn_game/models/subject.dart';
import 'package:kidlearn_game/data/content_kelas1.dart';
import 'package:kidlearn_game/data/content_kelas2.dart';
import 'package:kidlearn_game/data/content_kelas3.dart';
import 'package:kidlearn_game/data/content_kelas4.dart';
import 'package:kidlearn_game/data/content_kelas5.dart';
import 'package:kidlearn_game/data/content_kelas6.dart';

/// Integritas bank soal: setiap soal harus terbentuk benar (opsi valid,
/// correctIndex dalam rentang, tak ada opsi kembar, isian punya jawaban).
/// Mengunci mutu struktural bank yang diperluas.
void main() {
  List<Question> bankFor(int grade, Subject s) {
    switch (grade) {
      case 1: return ContentKelas1.forSubject(s);
      case 2: return ContentKelas2.forSubject(s);
      case 3: return ContentKelas3.forSubject(s);
      case 4: return ContentKelas4.forSubject(s);
      case 5: return ContentKelas5.forSubject(s);
      default: return ContentKelas6.forSubject(s);
    }
  }

  test('Semua soal bank terbentuk valid & tak ada duplikat teks per mapel', () {
    for (int grade = 1; grade <= 6; grade++) {
      for (final s in Subject.values) {
        if (s == Subject.math) continue; // math dihasilkan algoritmik
        final bank = bankFor(grade, s);
        final texts = <String>{};
        for (final q in bank) {
          final where = '$s K$grade: "${q.question}"';
          expect(q.question.trim(), isNotEmpty, reason: 'kosong @ $where');
          // Tak ada teks soal identik dalam satu bank.
          expect(texts.add(q.question.trim().toLowerCase()), isTrue,
              reason: 'duplikat teks @ $where');
          switch (q.type) {
            case QuestionType.multipleChoice:
            case QuestionType.listening:
            case QuestionType.imageChoice:
              expect(q.options.length, 4, reason: 'butuh 4 opsi @ $where');
              expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1),
                  reason: 'correctIndex di luar rentang @ $where');
              // Case-sensitive: sebagian soal sengaja beda kapitalisasi
              // (mis. budi vs Budi), itu opsi yang sah berbeda.
              final distinct = q.options.map((o) => o.trim()).toSet();
              expect(distinct.length, q.options.length,
                  reason: 'ada opsi kembar @ $where');
              break;
            case QuestionType.trueFalse:
              expect(q.options.length, 2, reason: 'B/S butuh 2 opsi @ $where');
              expect(q.correctIndex, inInclusiveRange(0, 1));
              break;
            case QuestionType.fillBlank:
              expect(q.answer != null && q.answer!.trim().isNotEmpty, isTrue,
                  reason: 'isian tanpa jawaban @ $where');
              break;
            case QuestionType.matching:
              expect(q.pairs != null && q.pairs!.isNotEmpty, isTrue);
              break;
            case QuestionType.sequence:
              expect(q.sequence != null && q.sequence!.length >= 2, isTrue);
              break;
          }
        }
      }
    }
  });
}
