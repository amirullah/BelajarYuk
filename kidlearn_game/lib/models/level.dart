import 'subject.dart';

/// Karakter tiap level dalam satu mata pelajaran (mengikuti rencana v2).
enum LevelKind { pengenalan, latihan, pendalaman, tantangan, review, boss }

/// Definisi satu level: 12 level per mapel per kelas.
class GameLevel {
  final Subject subject;
  final int grade; // 1..6
  final int index; // 1..12
  final LevelKind kind;
  final int questionCount;
  final int passPercent; // ambang lulus

  const GameLevel({
    required this.subject,
    required this.grade,
    required this.index,
    required this.kind,
    required this.questionCount,
    required this.passPercent,
  });

  /// ID unik & stabil untuk penyimpanan progres, mis. "math-1-07".
  String get id =>
      '${subject.name}-$grade-${index.toString().padLeft(2, '0')}';

  bool get isBoss => kind == LevelKind.boss;

  /// Bangun 12 level standar untuk satu (mapel, kelas).
  static List<GameLevel> buildGrade(Subject subject, int grade) {
    return List.generate(12, (i) {
      final int idx = i + 1;
      final LevelKind kind;
      final int qCount;
      final int pass;
      if (idx <= 2) {
        kind = LevelKind.pengenalan;
        qCount = 15;
        pass = 80;
      } else if (idx <= 5) {
        kind = LevelKind.latihan;
        qCount = 20;
        pass = 80;
      } else if (idx <= 8) {
        kind = LevelKind.pendalaman;
        qCount = 20;
        pass = 80;
      } else if (idx <= 10) {
        kind = LevelKind.tantangan;
        qCount = 25;
        pass = 80;
      } else if (idx == 11) {
        kind = LevelKind.review;
        qCount = 25;
        pass = 80;
      } else {
        kind = LevelKind.boss;
        qCount = 30;
        pass = 85; // Boss Level lebih ketat
      }
      return GameLevel(
        subject: subject,
        grade: grade,
        index: idx,
        kind: kind,
        questionCount: qCount,
        passPercent: pass,
      );
    });
  }

  static String kindLabel(LevelKind k) {
    switch (k) {
      case LevelKind.pengenalan:
        return 'Pengenalan';
      case LevelKind.latihan:
        return 'Latihan';
      case LevelKind.pendalaman:
        return 'Pendalaman';
      case LevelKind.tantangan:
        return 'Tantangan';
      case LevelKind.review:
        return 'Review';
      case LevelKind.boss:
        return 'Boss Level';
    }
  }
}

/// Hasil memainkan satu level.
class LevelResult {
  final int correct;
  final int total;

  const LevelResult({required this.correct, required this.total});

  double get percent => total == 0 ? 0 : correct / total * 100;

  bool passed(GameLevel level) => percent >= level.passPercent;

  /// Bintang: ≥80% = 1, ≥90% = 2, 100% = 3.
  int get stars {
    final p = percent;
    if (p >= 100) return 3;
    if (p >= 90) return 2;
    if (p >= 80) return 1;
    return 0;
  }
}
