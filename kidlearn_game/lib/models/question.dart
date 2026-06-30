class Question {
  final String question;
  final String emoji;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const Question({
    required this.question,
    required this.emoji,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });
}
