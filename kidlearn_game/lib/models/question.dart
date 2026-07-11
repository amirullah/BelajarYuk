/// Bentuk-bentuk soal yang didukung BelajarYuk! 2.0.
/// Aturan "tidak monoton": mesin level mencampur beberapa tipe per level.
enum QuestionType {
  multipleChoice, // 4 opsi
  trueFalse, // Benar / Salah (geser)
  fillBlank, // Ketik jawaban pendek
  matching, // Pasangkan dua kolom
  sequence, // Susun urutan yang benar
  listening, // Dengar audio (TTS) lalu jawab
  imageChoice, // Pilih gambar/emoji sebagai jawaban
}

/// Satu soal. Field lama (question/emoji/options/correctIndex/explanation)
/// tetap dipakai tipe pilihan ganda; field baru untuk tipe lain bersifat opsional.
class Question {
  final String question;
  final String emoji;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  // ── v2 ──
  final QuestionType type;

  /// Teks yang dibacakan TTS (listening / bantu-baca). Null = pakai [question].
  final String? audioText;

  /// Jawaban untuk tipe fillBlank (dibandingkan case-insensitive, trim).
  final String? answer;

  /// Pasangan benar untuk tipe matching: kiri -> kanan.
  final Map<String, String>? pairs;

  /// Urutan benar untuk tipe sequence.
  final List<String>? sequence;

  /// Kode objektif Cambridge (mis. "1Nc.01") untuk pelacakan cakupan.
  final String? objectiveCode;

  const Question({
    required this.question,
    this.emoji = '',
    this.options = const [],
    this.correctIndex = 0,
    this.explanation,
    this.type = QuestionType.multipleChoice,
    this.audioText,
    this.answer,
    this.pairs,
    this.sequence,
    this.objectiveCode,
  });

  /// Pintasan membuat soal Pasangkan (kiri → kanan).
  factory Question.matching({
    required String question,
    required Map<String, String> pairs,
    String emoji = '',
    String? objectiveCode,
  }) {
    return Question(
      question: question,
      emoji: emoji,
      type: QuestionType.matching,
      pairs: pairs,
      objectiveCode: objectiveCode,
    );
  }

  /// Pintasan membuat soal Benar/Salah.
  factory Question.trueFalse({
    required String statement,
    required bool isTrue,
    String emoji = '',
    String? explanation,
    String? objectiveCode,
  }) {
    return Question(
      question: statement,
      emoji: emoji,
      options: const ['Benar', 'Salah'],
      correctIndex: isTrue ? 0 : 1,
      explanation: explanation,
      type: QuestionType.trueFalse,
      objectiveCode: objectiveCode,
    );
  }
}
