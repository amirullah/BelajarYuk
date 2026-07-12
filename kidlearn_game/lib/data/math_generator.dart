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
    final topics = _topics(grade, d);
    // Kurikulum bertahap: hanya topik yang "terbuka" di level ini yang dipakai,
    // sehingga TIAP beberapa level ada TOPIK BARU (bukan sekadar angka membesar).
    final unlocked = topics.where((t) => level >= t.$1).toList();
    if (unlocked.isEmpty) unlocked.add(topics.first);
    // Kantong generator: tiap topik muncul; 2 topik TERBARU diberi bobot lebih
    // agar topik baru menonjol tiap naik level, tetapi soal tetap BERAGAM
    // (campur beberapa topik dalam satu level → tak monoton).
    final bag = <Question Function()>[];
    for (final t in unlocked) {
      bag.add(t.$2);
    }
    for (final t in unlocked.reversed.take(2)) {
      bag..add(t.$2)..add(t.$2);
    }
    bag.shuffle(_rng);

    final out = <Question>[];
    final seen = <String>{};
    int i = 0, guard = 0;
    while (out.length < count && guard++ < count * 25) {
      final q = bag[i++ % bag.length]();
      if (seen.add(q.question)) out.add(q);
    }
    // Bila ragam kurang, izinkan pengulangan agar level tetap terisi.
    while (out.length < count) {
      out.add(bag[_rng.nextInt(bag.length)]());
    }
    out.shuffle(_rng); // selang-seling jenis soal dalam satu level
    return out;
  }

  /// Interpolasi bulat antara [a] (mudah) dan [b] (sulit) menurut [d] 0..1.
  int _lerp(int a, int b, double d) => (a + (b - a) * d).round();

  /// Kurikulum topik per kelas: tiap entri = (level topik terbuka, generator).
  /// Topik dibuka bertahap (level 1,3,5,7,9) sehingga setiap beberapa level ada
  /// JENIS soal baru — bukan hanya angka yang berubah pada topik yang sama.
  List<(int, Question Function())> _topics(int grade, double d) {
    switch (grade) {
      case 1:
        return [
          (1, () => _addSub(maxResult: _lerp(10, 30, d), minResult: _lerp(0, 16, d))),
          (3, () => _compare(_lerp(5, 20, d))),
          (5, () => _pattern(grade, d)),
          (7, () => _missingOp(grade, d)),
          (9, () => _wordProblem(grade, d)),
        ];
      case 2:
        return [
          (1, () => _addSub(maxResult: _lerp(20, 100, d), minResult: _lerp(0, 55, d))),
          (3, () => _compare(_lerp(20, 100, d))),
          (5, () => _pattern(grade, d)),
          (7, () => _missingOp(grade, d)),
          (9, () => _wordProblem(grade, d)),
        ];
      case 3:
        return [
          (1, () => _mulDiv(maxFactor: _lerp(4, 12, d), minFactor: _lerp(1, 6, d))),
          (3, () => _addSub(maxResult: _lerp(50, 200, d), minResult: _lerp(0, 100, d))),
          (5, () => _pattern(grade, d)),
          (7, () => _missingOp(grade, d)),
          (9, () => _wordProblem(grade, d)),
        ];
      case 4:
        return [
          (1, () => _factors(d)),
          (3, () => _fractionOf(d)),
          (5, () => _missingOp(grade, d)),
          (7, () => _wordProblem(grade, d)),
          (9, () => _pattern(grade, d)),
        ];
      case 5:
        return [
          (1, () => _percentOf(d)),
          (3, () => _areaSquare(d)),
          (5, () => _fractionOf(d)),
          (7, () => _wordProblem(grade, d)),
          (9, () => _average(d)),
        ];
      case 6:
        return [
          (1, () => _ratio(d)),
          (3, () => _average(d)),
          (5, () => _percentOf(d)),
          (7, () => _wordProblem(grade, d)),
          (9, () => _pattern(grade, d)),
        ];
      default:
        return [(1, () => _addSub(maxResult: _lerp(10, 20, d)))];
    }
  }

  // ── Perbandingan bilangan (>, <, =) — pilih pernyataan yang BENAR ──
  Question _compare(int maxN) {
    final int a = _rng.nextInt(maxN) + 1;
    int b = _rng.nextInt(maxN) + 1;
    while (b == a) {
      b = _rng.nextInt(maxN) + 1; // pastikan berbeda → opsi tak kembar
    }
    final options = ['$a > $b', '$a < $b', '$a = $b', '$b > $a'];
    return Question(
      question: 'Manakah yang BENAR?',
      emoji: '⚖️',
      options: options,
      correctIndex: a > b ? 0 : 1,
      difficulty: 2,
    );
  }

  // ── Pola bilangan — lanjutkan barisan ──
  Question _pattern(int grade, double d) {
    final int step = _lerp(1, grade <= 2 ? 6 : 25, d).clamp(1, 999);
    final int start = _lerp(1, 20, d) + _rng.nextInt(5);
    final int t1 = start, t2 = start + step, t3 = start + 2 * step;
    return _mc('Lanjutkan pola: $t1, $t2, $t3, ...', start + 3 * step,
        spread: max(2, step), emoji: '🔢');
  }

  // ── Mencari bilangan yang hilang ──
  Question _missingOp(int grade, double d) {
    if (grade <= 2) {
      final int c = _lerp(10, 40, d) + _rng.nextInt(10);
      final int a = _rng.nextInt(c + 1);
      return _mc('$a + ? = $c', c - a, spread: 3, emoji: '➕');
    }
    final int a = _rng.nextInt(_lerp(4, 12, d)) + 2;
    final int b = _rng.nextInt(_lerp(4, 12, d)) + 2;
    return _mc('$a × ? = ${a * b}', b, spread: 2, emoji: '✖️');
  }

  // ── Soal cerita (kontekstual) ──
  static const _names = ['Andi', 'Siti', 'Budi', 'Rina', 'Doni', 'Lina'];
  static const _items = ['apel', 'kelereng', 'buku', 'permen', 'pensil', 'stiker'];
  Question _wordProblem(int grade, double d) {
    final n = _names[_rng.nextInt(_names.length)];
    final it = _items[_rng.nextInt(_items.length)];
    if (grade <= 2) {
      final int a = _lerp(3, 40, d) + _rng.nextInt(10);
      final int b = _rng.nextInt(a) + 1;
      if (_rng.nextBool()) {
        return _mc('$n punya $a $it, diberi $b lagi. Berapa $it $n sekarang?',
            a + b, spread: 3, emoji: '🧺');
      }
      return _mc('$n punya $a $it, $b diberikan ke teman. Sisa berapa?', a - b,
          spread: 3, emoji: '🧺');
    }
    final int a = _rng.nextInt(_lerp(4, 12, d)) + 2;
    final int b = _rng.nextInt(_lerp(4, 12, d)) + 2;
    if (_rng.nextBool()) {
      return _mc('Ada $a kotak, tiap kotak berisi $b $it. Berapa total $it?',
          a * b, spread: max(2, a), emoji: '📦');
    }
    return _mc('${a * b} $it dibagi rata ke $a anak. Tiap anak dapat berapa?',
        b, spread: 2, emoji: '📦');
  }

  // ── KPK & FPB (Kelas 4) ──
  // Lantai [lo] naik per level → faktor makin besar tiap naik level (band beda,
  // jarang berulang), konsisten dgn kelas 1-3.
  Question _factors(double d) {
    final int r = _lerp(6, 12, d);
    final int lo = _lerp(2, 6, d);
    final int a = lo + _rng.nextInt(max(1, r - lo + 1));
    final int b = lo + _rng.nextInt(max(1, r - lo + 1));
    if (_rng.nextBool()) {
      return _mc('FPB dari $a dan $b = ?', _gcd(a, b), spread: 2, emoji: '🔢');
    }
    final int lcm = a * b ~/ _gcd(a, b);
    return _mc('KPK dari $a dan $b = ?', lcm,
        spread: max(2, lcm ~/ 5), emoji: '🔢');
  }

  // ── Pecahan dari bilangan (Kelas 4) ──
  Question _fractionOf(double d) {
    // Level tinggi: penyebut lebih beragam & bilangan lebih besar (lantai naik).
    final denoms = d < 0.5 ? [2, 3, 4, 5] : [2, 3, 4, 5, 6, 8];
    final int denom = denoms[_rng.nextInt(denoms.length)];
    final int m = _lerp(1, 6, d) + _rng.nextInt(_lerp(5, 8, d));
    final int whole = m * denom;
    return _mc('1/$denom dari $whole = ?', whole ~/ denom,
        spread: 2, emoji: '🍰');
  }

  // ── Luas persegi (Kelas 5) ──
  Question _areaSquare(double d) {
    final int s = _lerp(2, 8, d) + _rng.nextInt(_lerp(4, 8, d));
    return _mc('Luas persegi sisi $s = ?', s * s, spread: max(2, s), emoji: '⬛');
  }

  // ── Rata-rata / statistik dasar (Kelas 6) ──
  Question _average(double d) {
    final int avg = _lerp(2, 10, d) + _rng.nextInt(_lerp(4, 8, d));
    return _mc('Rata-rata dari ${avg - 1}, $avg, ${avg + 1} = ?', avg,
        spread: 2, emoji: '📊');
  }

  // ── Rasio sederhana (Kelas 6) ──
  Question _ratio(double d) {
    final int k = _lerp(2, 6, d) + _rng.nextInt(3); // pengali (lantai naik)
    final int a = _lerp(1, 5, d) + _rng.nextInt(_lerp(3, 6, d));
    final int b = _lerp(1, 5, d) + _rng.nextInt(_lerp(3, 6, d));
    return _mc('$a : $b sama dengan ${a * k} : ?', b * k,
        spread: max(2, b), emoji: '⚖️');
  }

  // ── Penjumlahan / pengurangan ──
  // [minResult] adalah "lantai" hasil yang NAIK seiring level → tiap level
  // memakai rentang angka yang berbeda (band tak tumpang-tindih), sehingga
  // soal jarang berulang antar-level DAN tanjakan kesulitan terasa jelas.
  Question _addSub({required int maxResult, int minResult = 0}) {
    final bool add = _rng.nextBool();
    final int lo = minResult.clamp(0, maxResult);
    late int a, b, result;
    if (add) {
      // Jumlah (hasil) berada di [lo, maxResult] → level tinggi mulai lebih besar.
      result = lo + _rng.nextInt(maxResult - lo + 1);
      a = _rng.nextInt(result + 1);
      b = result - a;
      return _mc('$a + $b = ?', result, spread: max(2, maxResult ~/ 20),
          emoji: '➕', objectiveCode: _mathCode(maxResult));
    } else {
      // Bilangan yang dikurangi minimal [lo] → angka membesar tiap naik level.
      a = lo + _rng.nextInt(maxResult - lo + 1);
      if (a < 1) a = 1;
      b = _rng.nextInt(a + 1);
      result = a - b;
      return _mc('$a − $b = ?', result, spread: max(2, maxResult ~/ 20),
          emoji: '➖', objectiveCode: _mathCode(maxResult));
    }
  }

  // ── Perkalian / pembagian ──
  // [minFactor] naik seiring level → faktor makin besar tiap level (band beda).
  Question _mulDiv({required int maxFactor, int minFactor = 1}) {
    final int lo = minFactor.clamp(1, maxFactor);
    final int a = lo + _rng.nextInt(maxFactor - lo + 1);
    final int b = lo + _rng.nextInt(maxFactor - lo + 1);
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
    // Basis kelipatan yang menghasilkan bilangan bulat; lantai naik per level.
    final int unit = 100 ~/ _gcd(pct, 100);
    final int m = _lerp(1, 6, d) + _rng.nextInt(_lerp(6, 12, d));
    final int base = m * unit;
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
