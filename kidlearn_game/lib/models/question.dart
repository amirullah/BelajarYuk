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

  /// Tingkat kesulitan: 1 = mudah, 2 = sedang, 3 = sulit. Dipakai agar soal
  /// makin sulit di level yang lebih tinggi (untuk mapel non-Matematika).
  final int difficulty;

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
    this.difficulty = 2,
  });

  Question copyWith({List<String>? options, int? correctIndex}) => Question(
        question: question,
        emoji: emoji,
        options: options ?? this.options,
        correctIndex: correctIndex ?? this.correctIndex,
        explanation: explanation,
        type: type,
        audioText: audioText,
        answer: answer,
        pairs: pairs,
        sequence: sequence,
        objectiveCode: objectiveCode,
        difficulty: difficulty,
      );

  /// Serialisasi ke JSON (untuk konten soal yang bisa diperbarui dari server
  /// tanpa memasang ulang APK).
  Map<String, dynamic> toJson() => {
        'q': question,
        if (emoji.isNotEmpty) 'e': emoji,
        if (options.isNotEmpty) 'o': options,
        'c': correctIndex,
        if (explanation != null) 'x': explanation,
        't': type.name,
        if (audioText != null) 'a': audioText,
        if (answer != null) 'ans': answer,
        if (pairs != null) 'p': pairs,
        if (sequence != null) 'seq': sequence,
        if (objectiveCode != null) 'oc': objectiveCode,
        'd': difficulty,
      };

  /// Bangun dari JSON. Tahan-banting: tipe tak dikenal → multipleChoice.
  factory Question.fromJson(Map<String, dynamic> j) {
    QuestionType parseType(Object? v) {
      final name = '$v';
      for (final t in QuestionType.values) {
        if (t.name == name) return t;
      }
      return QuestionType.multipleChoice;
    }

    return Question(
      question: (j['q'] as String?) ?? '',
      emoji: (j['e'] as String?) ?? '',
      options: (j['o'] as List?)?.map((e) => '$e').toList() ?? const [],
      correctIndex: (j['c'] as num?)?.toInt() ?? 0,
      explanation: j['x'] as String?,
      type: parseType(j['t']),
      audioText: j['a'] as String?,
      answer: j['ans'] as String?,
      pairs: (j['p'] as Map?)
          ?.map((k, v) => MapEntry('$k', '$v')),
      sequence: (j['seq'] as List?)?.map((e) => '$e').toList(),
      objectiveCode: j['oc'] as String?,
      difficulty: (j['d'] as num?)?.toInt() ?? 2,
    );
  }

  /// Pintasan membuat soal Pasangkan (kiri → kanan).
  factory Question.matching({
    required String question,
    required Map<String, String> pairs,
    String emoji = '',
    String? objectiveCode,
    int difficulty = 2,
  }) {
    return Question(
      question: question,
      emoji: emoji,
      type: QuestionType.matching,
      pairs: pairs,
      objectiveCode: objectiveCode,
      difficulty: difficulty,
    );
  }

  /// Pintasan membuat soal Pilih Gambar (klik emoji/gambar yang benar).
  /// [imageOptions] berisi emoji/gambar; [correctIndex] menunjuk yang benar.
  factory Question.imageChoice({
    required String question,
    required List<String> imageOptions,
    required int correctIndex,
    String emoji = '',
    String? audioText,
    String? explanation,
    String? objectiveCode,
    int difficulty = 2,
  }) {
    return Question(
      question: question,
      emoji: emoji,
      options: imageOptions,
      correctIndex: correctIndex,
      explanation: explanation,
      type: QuestionType.imageChoice,
      audioText: audioText,
      objectiveCode: objectiveCode,
      difficulty: difficulty,
    );
  }

  /// Pintasan membuat soal Susun Urutan. [order] = urutan yang benar.
  factory Question.sequence({
    required String question,
    required List<String> order,
    String emoji = '🔢',
    String? objectiveCode,
    int difficulty = 2,
  }) {
    return Question(
      question: question,
      emoji: emoji,
      type: QuestionType.sequence,
      sequence: order,
      objectiveCode: objectiveCode,
      difficulty: difficulty,
    );
  }

  /// Pintasan membuat soal Dengar (TTS) lalu pilih jawaban.
  factory Question.listening({
    required String question,
    required List<String> options,
    required int correctIndex,
    required String audioText,
    String emoji = '🎧',
    String? objectiveCode,
    int difficulty = 2,
  }) {
    return Question(
      question: question,
      emoji: emoji,
      options: options,
      correctIndex: correctIndex,
      type: QuestionType.listening,
      audioText: audioText,
      objectiveCode: objectiveCode,
      difficulty: difficulty,
    );
  }

  /// Pintasan membuat soal Benar/Salah.
  factory Question.trueFalse({
    required String statement,
    required bool isTrue,
    String emoji = '',
    String? explanation,
    String? objectiveCode,
    int difficulty = 2,
  }) {
    return Question(
      question: statement,
      emoji: emoji,
      options: const ['Benar', 'Salah'],
      correctIndex: isTrue ? 0 : 1,
      explanation: explanation,
      type: QuestionType.trueFalse,
      objectiveCode: objectiveCode,
      difficulty: difficulty,
    );
  }
}
