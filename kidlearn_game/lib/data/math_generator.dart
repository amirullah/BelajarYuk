import 'dart:math';
import '../models/question.dart';

/// Menghasilkan soal Matematika secara algoritmik sesuai kelas.
/// Tidak dari database — jadi soal tidak pernah habis dan (praktis) tidak
/// pernah sama persis. Opsi jawaban salah dibuat "cerdas" (dekat dengan
/// jawaban benar) agar tetap menantang.
class MathGenerator {
  final Random _rng;

  MathGenerator([int? seed]) : _rng = Random(seed);

  /// Hasilkan [count] soal untuk [grade] (1..6).
  List<Question> generate(int grade, {int count = 15}) {
    return List.generate(count, (_) => _one(grade));
  }

  Question _one(int grade) {
    switch (grade) {
      case 1:
        return _addSub(maxResult: 20);
      case 2:
        return _addSub(maxResult: 100);
      case 3:
        return _mulDiv(maxFactor: 10);
      case 4:
        return _rng.nextBool() ? _mulDiv(maxFactor: 12) : _addSub(maxResult: 1000);
      case 5:
        return _percentOf();
      case 6:
        return _rng.nextBool() ? _percentOf() : _mulDiv(maxFactor: 20);
      default:
        return _addSub(maxResult: 20);
    }
  }

  // ── Penjumlahan / pengurangan ──
  Question _addSub({required int maxResult}) {
    final bool add = _rng.nextBool();
    late int a, b, result;
    if (add) {
      a = _rng.nextInt(maxResult);
      b = _rng.nextInt(maxResult - a + 1);
      result = a + b;
      return _mc('$a + $b = ?', result, spread: max(2, maxResult ~/ 20),
          emoji: '➕', objectiveCode: _mathCode(maxResult));
    } else {
      a = _rng.nextInt(maxResult) + 1;
      b = _rng.nextInt(a + 1);
      result = a - b;
      return _mc('$a − $b = ?', result, spread: max(2, maxResult ~/ 20),
          emoji: '➖', objectiveCode: _mathCode(maxResult));
    }
  }

  // ── Perkalian / pembagian ──
  Question _mulDiv({required int maxFactor}) {
    final int a = _rng.nextInt(maxFactor) + 1;
    final int b = _rng.nextInt(maxFactor) + 1;
    if (_rng.nextBool()) {
      return _mc('$a × $b = ?', a * b, spread: max(2, a), emoji: '✖️');
    } else {
      final int product = a * b;
      return _mc('$product ÷ $a = ?', b, spread: 2, emoji: '➗');
    }
  }

  // ── Persen sederhana (kelas 5-6) ──
  Question _percentOf() {
    final List<int> pcts = [10, 20, 25, 50, 75];
    final int pct = pcts[_rng.nextInt(pcts.length)];
    // pilih basis yang menghasilkan bilangan bulat
    final int base = (_rng.nextInt(10) + 1) * (100 ~/ _gcd(pct, 100));
    final int result = base * pct ~/ 100;
    return _mc('$pct% dari $base = ?', result, spread: max(2, result ~/ 5),
        emoji: '％');
  }

  // ── Bangun soal (kadang isian, kadang pilihan ganda) ──
  Question _mc(String q, int answer, {int spread = 3, String emoji = '🔢',
      String? objectiveCode}) {
    // ~30% jadi soal isian agar bentuk soal bervariasi.
    if (_rng.nextInt(10) < 3) {
      return Question(
        question: q,
        emoji: emoji,
        type: QuestionType.fillBlank,
        answer: answer.toString(),
        objectiveCode: objectiveCode,
      );
    }
    final Set<int> opts = {answer};
    int guard = 0;
    while (opts.length < 4 && guard++ < 50) {
      final int delta = _rng.nextInt(spread) + 1;
      final int cand = _rng.nextBool() ? answer + delta : answer - delta;
      if (cand >= 0) opts.add(cand);
    }
    // fallback bila kurang dari 4 opsi
    int extra = answer + 1;
    while (opts.length < 4) {
      if (extra >= 0) opts.add(extra);
      extra++;
    }
    final List<int> shuffled = opts.toList()..shuffle(_rng);
    return Question(
      question: q,
      emoji: emoji,
      options: shuffled.map((e) => e.toString()).toList(),
      correctIndex: shuffled.indexOf(answer),
      objectiveCode: objectiveCode,
    );
  }

  String _mathCode(int maxResult) {
    if (maxResult <= 20) return '1Ni.01';
    if (maxResult <= 100) return '2Ni.01';
    return '3Ni.01';
  }

  int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
}
