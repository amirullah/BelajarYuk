import 'package:flutter_test/flutter_test.dart';
import 'package:kidlearn_game/services/level_service.dart';
import 'package:kidlearn_game/models/subject.dart';
import 'package:kidlearn_game/models/level.dart';
import 'package:kidlearn_game/models/question.dart';

/// Regresi: opsi soal klik-gambar/menyimak/pilihan-ganda harus diacak, jadi
/// jawaban benar TIDAK selalu di index 0 (anak tak bisa lulus dgn tap kiri-atas).
void main() {
  test('Jawaban benar tidak selalu di posisi 0 (klik-gambar & pilihan ganda)',
      () {
    final positions = <int>{};
    var optionQuestions = 0;

    for (int seed = 0; seed < 40; seed++) {
      // Kelas 1 Matematika menyelipkan soal klik-gambar (imageChoice).
      final math = LevelService(seed)
          .buildQuestions(GameLevel.buildGrade(Subject.math, 1).first);
      // Bank mapel lain (mis. Bahasa Inggris) berisi pilihan ganda & menyimak.
      final eng = LevelService(seed)
          .buildQuestions(GameLevel.buildGrade(Subject.english, 1).first);

      for (final q in [...math, ...eng]) {
        if (q.type == QuestionType.imageChoice ||
            q.type == QuestionType.listening ||
            q.type == QuestionType.multipleChoice) {
          if (q.options.length >= 2) {
            optionQuestions++;
            positions.add(q.correctIndex);
          }
        }
      }
    }

    expect(optionQuestions, greaterThan(0),
        reason: 'harus ada soal beropsi untuk diuji');
    // Jika bug "selalu index 0" kambuh, set ini hanya berisi {0}.
    expect(positions.length, greaterThan(1),
        reason: 'posisi jawaban benar harus bervariasi, bukan selalu 0');
  });
}
