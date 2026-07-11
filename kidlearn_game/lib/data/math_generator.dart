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
  /// [level] (1..12) menaikkan tingkat kesulitan di dalam satu kelas — makin
  /// tinggi level, makin besar angka/kompleksitasnya. Soal juga di-<em>dedup</em>
  /// agar tidak berulang dalam satu sesi (selama ragamnya mencukupi).
  List<Question> generate(int grade, {int count = 15, int level = 6}) {
    final double d = ((level - 1) / 11).clamp(0.0, 1.0); // 0=level1 .. 1=level12
    final out = <Question>[];
    final seen = <String>{};
    int guard = 0;
    while (out.length < count && guard++ < count * 12) {
      final q = _one(grade, d);
      if (seen.add(q.question)) out.add(q);
    }
    // Bila ruang soal kecil sehingga unik tak cukup, izinkan pengulangan.
    while (out.length < count) {
      out.add(_one(grade, d));
    }
    return out;
  }

  /// Interpolasi bulat antara [a] (mudah) dan [b] (sulit) menurut [d] 0..1.
  int _lerp(int a, int b, double d) => (a + (b - a) * d).round();

  Question _one(int grade, double d) {
    switch (grade) {
      case 1:
        return _addSub(maxResult: _lerp(10, 20, d));
      case 2:
        return _addSub(maxResult: _lerp(30, 100, d));
      case 3:
        return _mulDiv(maxFactor: _lerp(5, 10, d));
      case 4:
        // Pecahan, KPK & FPB (sesuai rencana Kelas 4).
        return _rng.nextBool() ? _factors(d) : _fractionOf(d);
      case 5:
        // Desimal/persen, luas & volume (Kelas 5).
        return _rng.nextBool() ? _percentOf(d) : _areaSquare(d);
      case 6:
        // Rasio, statistik dasar (Kelas 6).
        return _rng.nextBool() ? _average(d) : _ratio(d);
      default:
        return _addSub(maxResult: _lerp(10, 20, d));
    }
  }

  // ── KPK & FPB (Kelas 4) ──
  Question _factors(double d) {
    final int r = _lerp(6, 12, d);
    final int a = _rng.nextInt(r) + 2;
    final int b = _rng.nextInt(r) + 2;
    if (_rng.nextBool()) {
      return _mc('FPB dari $a dan $b = ?', _gcd(a, b), spread: 2, emoji: '🔢');
    }
    final int lcm = a * b ~/ _gcd(a, b);
    return _mc('KPK dari $a dan $b = ?', lcm,
        spread: max(2, lcm ~/ 5), emoji: '🔢');
  }

  // ── Pecahan dari bilangan (Kelas 4) ──
  Question _fractionOf(double d) {
    // Level tinggi: penyebut lebih beragam & bilangan lebih besar.
    final denoms = d < 0.5 ? [2, 3, 4, 5] : [2, 3, 4, 5, 6, 8];
    final int denom = denoms[_rng.nextInt(denoms.length)];
    final int whole = (_rng.nextInt(_lerp(6, 12, d)) + 1) * denom;
    return _mc('1/$denom dari $whole = ?', whole ~/ denom,
        spread: 2, emoji: '🍰');
  }

  // ── Luas persegi (Kelas 5) ──
  Question _areaSquare(double d) {
    final int s = _rng.nextInt(_lerp(6, 14, d)) + 2;
    return _mc('Luas persegi sisi $s = ?', s * s, spread: max(2, s), emoji: '⬛');
  }

  // ── Rata-rata / statistik dasar (Kelas 6) ──
  Question _average(double d) {
    final int avg = _rng.nextInt(_lerp(6, 15, d)) + 2;
    return _mc('Rata-rata dari ${avg - 1}, $avg, ${avg + 1} = ?', avg,
        spread: 2, emoji: '📊');
  }

  // ── Rasio sederhana (Kelas 6) ──
  Question _ratio(double d) {
    final int k = _rng.nextInt(_lerp(3, 6, d)) + 2; // pengali
    final int a = _rng.nextInt(_lerp(4, 8, d)) + 1;
    final int b = _rng.nextInt(_lerp(4, 8, d)) + 1;
    return _mc('$a : $b sama dengan ${a * k} : ?', b * k,
        spread: max(2, b), emoji: '⚖️');
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
  Question _percentOf(double d) {
    final List<int> pcts =
        d < 0.5 ? [10, 20, 25, 50] : [10, 15, 20, 25, 40, 50, 75];
    final int pct = pcts[_rng.nextInt(pcts.length)];
    // pilih basis yang menghasilkan bilangan bulat
    final int base = (_rng.nextInt(_lerp(10, 20, d)) + 1) * (100 ~/ _gcd(pct, 100));
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
