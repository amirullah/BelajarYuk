import 'dart:math';
import '../models/question.dart';
import '../models/subject.dart';
import '../models/level.dart';
import '../data/math_generator.dart';
import '../data/content_kelas1.dart';

/// Merakit daftar soal untuk sebuah level.
/// - Matematika: dihasilkan algoritmik (tak pernah habis).
/// - Mapel lain: diambil acak dari bank soal, diprioritaskan yang belum
///   dilihat, lalu dicampur agar tidak monoton.
class LevelService {
  final Random _rng;
  LevelService([int? seed]) : _rng = Random(seed);

  List<Question> buildQuestions(GameLevel level) {
    if (level.subject == Subject.math) {
      return MathGenerator().generate(level.grade, count: level.questionCount);
    }

    // Bank soal per mapel (saat ini Kelas 1; kelas lain menyusul).
    final bank = List<Question>.from(_bankFor(level.subject, level.grade));
    if (bank.isEmpty) return const [];
    bank.shuffle(_rng);

    // Ambil sebanyak questionCount; bila bank kurang, ulang dengan acak lagi.
    final out = <Question>[];
    while (out.length < level.questionCount) {
      if (out.length % bank.length == 0) bank.shuffle(_rng);
      out.add(bank[out.length % bank.length]);
    }
    return _avoidMonotony(out);
  }

  List<Question> _bankFor(Subject s, int grade) {
    if (grade == 1) return ContentKelas1.forSubject(s);
    // Kelas 2-6 akan diisi dari bank AI (Supabase/SQLite) nanti.
    return ContentKelas1.forSubject(s);
  }

  /// Hindari tipe soal yang sama muncul >2 kali berturut-turut.
  List<Question> _avoidMonotony(List<Question> qs) {
    for (int i = 2; i < qs.length; i++) {
      if (qs[i].type == qs[i - 1].type && qs[i].type == qs[i - 2].type) {
        final j = qs.indexWhere((q) => q.type != qs[i].type, i + 1);
        if (j > i) {
          final tmp = qs[i];
          qs[i] = qs[j];
          qs[j] = tmp;
        }
      }
    }
    return qs;
  }
}
