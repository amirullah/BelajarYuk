import 'dart:math';
import '../models/question.dart';
import '../models/subject.dart';
import '../models/level.dart';
import '../data/math_generator.dart';
import '../data/content_kelas1.dart';
import '../data/content_kelas2.dart';
import '../data/content_kelas3.dart';
import '../data/content_kelas4.dart';
import '../data/content_kelas5.dart';
import '../data/content_kelas6.dart';
import '../services/content_service.dart';

/// Merakit daftar soal untuk sebuah level.
/// - Matematika: dihasilkan algoritmik (tak pernah habis).
/// - Mapel lain: diambil acak dari bank soal, diprioritaskan yang belum
///   dilihat, lalu dicampur agar tidak monoton.
class LevelService {
  final Random _rng;
  final int? _seed;
  LevelService([int? seed])
      : _seed = seed,
        _rng = Random(seed);

  /// Acak posisi opsi + hitung ulang [correctIndex] agar jawaban benar tak
  /// selalu di posisi yang sama (mis. klik-gambar/menyimak yang selalu index 0).
  /// True/False & isian tak diacak (urutan/tak berlaku).
  Question _shuffleOptions(Question q) {
    if (q.options.length < 2 ||
        q.type == QuestionType.trueFalse ||
        q.type == QuestionType.fillBlank) {
      return q;
    }
    final idx = List<int>.generate(q.options.length, (i) => i)..shuffle(_rng);
    final opts = [for (final i in idx) q.options[i]];
    return q.copyWith(options: opts, correctIndex: idx.indexOf(q.correctIndex));
  }

  List<Question> buildQuestions(GameLevel level) {
    if (level.subject == Subject.math) {
      // Level makin tinggi → soal makin sulit (angka lebih besar).
      final qs = MathGenerator(_seed).generate(level.grade,
          count: level.questionCount, level: level.index);
      // Selipkan soal variatif (pilih gambar + susun urutan) agar lebih menarik.
      final extras = <Question>[];
      if (level.grade <= 2) extras.addAll(_imageChoiceExtras(Subject.math));
      extras.addAll(_mathSequences(level.grade));
      if (extras.isNotEmpty) {
        extras.shuffle(_rng);
        for (int k = 0; k < extras.length && k < 2; k++) {
          final pos = 1 + _rng.nextInt(qs.length);
          qs.insert(pos.clamp(0, qs.length), _shuffleOptions(extras[k]));
        }
        return _avoidMonotony(qs.take(level.questionCount).toList());
      }
      return qs;
    }

    // Kolam soal UNIK utuh untuk (mapel, kelas), diurutkan kesulitan MENAIK &
    // stabil (seed dari mapel+kelas). Urutan stabil ini dipakai untuk membagi
    // soal ke 12 level secara DISJOIN.
    final ordered = _orderedPool(level.subject, level.grade);
    if (ordered.isEmpty) return const [];

    // ── Pembagian DISJOIN + tanjakan kesulitan per level ──
    // Setiap level mengambil potongan LANJUTAN dari kolam terurut kesulitan.
    // Akibatnya: (a) TAK ADA soal yang sama muncul di dua level berbeda dalam
    // satu kelas (menghapus pengulangan antar-level yang dikeluhkan), dan
    // (b) makin tinggi level → potongannya dari bagian kolam yang lebih sulit,
    // jadi setiap naik level soalnya benar-benar lebih menantang.
    // Antar-kelas (B2) otomatis lebih sulit karena bank tiap kelas ditulis
    // sesuai jenjangnya (Kelas 2 lebih sulit dari Kelas 1, dst.).
    final levels = GameLevel.buildGrade(level.subject, level.grade);
    int start = 0;
    for (final l in levels) {
      if (l.index >= level.index) break;
      start += l.questionCount;
    }
    final want = level.questionCount;
    final n = ordered.length;

    final List<Question> slice;
    if (start < n) {
      final end = (start + want) <= n ? start + want : n;
      final chosen = ordered.sublist(start, end).toList();
      // Bila kolam habis sebelum level ini penuh (hanya mungkin di level akhir/
      // boss karena total slot ≈ ukuran bank), lengkapi dari EKOR TERSULIT.
      // Pengulangan — bila ada — hanya terjadi di sini, sebagai "review" boss.
      if (chosen.length < want) {
        final have = chosen.map((q) => q.question).toSet();
        for (final q in ordered.reversed) {
          if (chosen.length >= want) break;
          if (have.add(q.question)) chosen.add(q);
        }
      }
      slice = chosen;
    } else {
      // start di luar kolam (boss saat bank < total slot): ambil soal TERSULIT.
      slice = ordered.sublist((n - want).clamp(0, n)).toList();
    }

    // Seed untuk pengacakan opsi & urutan penyajian (deterministik bila diberi
    // seed eksplisit; acak alami saat bermain agar tiap main terasa segar).
    final rng = _seed != null ? _rng : Random(level.id.hashCode + 7);
    final out = [for (final q in slice) _shuffleOptionsWith(q, rng)];
    out.shuffle(rng); // acak URUTAN dalam level (soal tetap set yang sama)
    return _avoidMonotony(out);
  }

  /// Kolam soal UNIK utuh untuk (mapel, kelas), diurutkan kesulitan MENAIK.
  /// Diacak stabil (seed dari mapel+kelas) lebih dulu agar dalam tiap tingkat
  /// kesulitan yang sama, TIPE soal tetap bervariasi (tak menggerombol satu
  /// jenis). Urutan yang dihasilkan sama tiap kali → pembagian antar-level
  /// konsisten & disjoin.
  List<Question> _orderedPool(Subject s, int grade) {
    final pool = <Question>[];
    final seen = <String>{};
    for (final q in _bankFor(s, grade)) {
      if (seen.add(q.question)) pool.add(q);
    }
    if (pool.isEmpty) return const [];
    final r = Random('${s.name}-$grade'.hashCode);
    pool.shuffle(r);
    // Stable-sort manual (Dart List.sort tak dijamin stabil): dekorasi indeks
    // agar urutan hasil-acak DIPERTAHANKAN untuk kesulitan yang sama.
    final idx = List<int>.generate(pool.length, (i) => i);
    idx.sort((a, b) {
      final c = pool[a]
          .difficulty
          .clamp(1, 3)
          .compareTo(pool[b].difficulty.clamp(1, 3));
      return c != 0 ? c : a.compareTo(b);
    });
    return [for (final i in idx) pool[i]];
  }

  /// Seperti [_shuffleOptions] tetapi memakai [rng] yang diberikan.
  Question _shuffleOptionsWith(Question q, Random rng) {
    if (q.options.length < 2 ||
        q.type == QuestionType.trueFalse ||
        q.type == QuestionType.fillBlank) {
      return q;
    }
    final idx = List<int>.generate(q.options.length, (i) => i)..shuffle(rng);
    final opts = [for (final i in idx) q.options[i]];
    return q.copyWith(options: opts, correctIndex: idx.indexOf(q.correctIndex));
  }

  /// Beberapa soal "pasangkan" untuk menambah variasi tipe. Ditandai kesulitan
  /// beragam agar tersebar ke level-level berbeda.
  List<Question> _matchingExtras(Subject s) {
    switch (s) {
      case Subject.english:
        return [
          Question.matching(question: 'Match the animal to its sound', emoji: '🔗', difficulty: 1, pairs: {
            'Cat': 'Meow', 'Dog': 'Woof', 'Cow': 'Moo', 'Duck': 'Quack',
          }),
          Question.matching(question: 'Match the word to its opposite', emoji: '🔗', difficulty: 2, pairs: {
            'Big': 'Small', 'Hot': 'Cold', 'Up': 'Down', 'Day': 'Night',
          }),
          Question.matching(question: 'Match the number to the word', emoji: '🔗', difficulty: 3, pairs: {
            '1': 'One', '3': 'Three', '5': 'Five', '8': 'Eight',
          }),
        ];
      case Subject.science:
        return [
          Question.matching(question: 'Pasangkan hewan dengan tempat hidupnya', emoji: '🔗', difficulty: 1, pairs: {
            'Ikan': 'Air', 'Burung': 'Udara', 'Cacing': 'Tanah',
          }),
          Question.matching(question: 'Pasangkan bagian tubuh dengan fungsinya', emoji: '🔗', difficulty: 2, pairs: {
            'Mata': 'Melihat', 'Telinga': 'Mendengar', 'Hidung': 'Mencium', 'Lidah': 'Mengecap',
          }),
          Question.matching(question: 'Pasangkan hewan dengan jenis makanannya', emoji: '🔗', difficulty: 3, pairs: {
            'Sapi': 'Rumput', 'Singa': 'Daging', 'Ayam': 'Biji-bijian',
          }),
        ];
      case Subject.indonesian:
        return [
          Question.matching(question: 'Pasangkan kata dengan lawan katanya', emoji: '🔗', difficulty: 1, pairs: {
            'Besar': 'Kecil', 'Panas': 'Dingin', 'Tinggi': 'Rendah',
          }),
          Question.matching(question: 'Pasangkan benda dengan kegunaannya', emoji: '🔗', difficulty: 2, pairs: {
            'Sapu': 'Menyapu', 'Pensil': 'Menulis', 'Payung': 'Hujan',
          }),
          Question.matching(question: 'Pasangkan kata dengan jenisnya', emoji: '🔗', difficulty: 3, pairs: {
            'Lari': 'Kata kerja', 'Meja': 'Kata benda', 'Merah': 'Kata sifat',
          }),
        ];
      case Subject.socialStudies:
        return [
          Question.matching(question: 'Pasangkan profesi dengan tempat kerjanya', emoji: '🔗', difficulty: 1, pairs: {
            'Guru': 'Sekolah', 'Petani': 'Sawah', 'Nelayan': 'Laut',
          }),
          Question.matching(question: 'Pasangkan alat dengan penggunanya', emoji: '🔗', difficulty: 2, pairs: {
            'Cangkul': 'Petani', 'Jala': 'Nelayan', 'Papan tulis': 'Guru',
          }),
          Question.matching(question: 'Pasangkan pulau dengan ibu kotanya', emoji: '🔗', difficulty: 3, pairs: {
            'Jawa': 'Jakarta', 'Sumatra': 'Medan', 'Bali': 'Denpasar',
          }),
        ];
      case Subject.religion:
        return [
          Question.matching(question: 'Pasangkan waktu dengan salatnya', emoji: '🔗', difficulty: 2, pairs: {
            'Subuh': 'Pagi', 'Zuhur': 'Siang', 'Magrib': 'Senja',
          }),
          Question.matching(question: 'Pasangkan nabi dengan mukjizatnya', emoji: '🔗', difficulty: 3, pairs: {
            'Nabi Musa': 'Tongkat', 'Nabi Nuh': 'Bahtera', 'Nabi Sulaiman': 'Bahasa hewan',
          }),
        ];
      default:
        return const [];
    }
  }

  /// Soal "pilih gambar" (klik emoji) — cocok untuk anak yang belum lancar baca.
  List<Question> _imageChoiceExtras(Subject s) {
    switch (s) {
      case Subject.english:
        return [
          Question.imageChoice(
              question: 'Which one is an apple?',
              imageOptions: ['🍎', '🍌', '🐶', '🚗'],
              correctIndex: 0,
              audioText: 'apple'),
          Question.imageChoice(
              question: 'Which one is a cat?',
              imageOptions: ['🐱', '🐘', '🍇', '⚽'],
              correctIndex: 0,
              audioText: 'cat'),
          Question.imageChoice(
              question: 'Which one can fly?',
              imageOptions: ['🐦', '🐟', '🐢', '🚲'],
              correctIndex: 0),
        ];
      case Subject.math:
        return [
          Question.imageChoice(
              question: 'Mana yang berjumlah 3?',
              imageOptions: ['🍎🍎🍎', '🍎', '🍎🍎', '🍎🍎🍎🍎'],
              correctIndex: 0),
          Question.imageChoice(
              question: 'Mana kelompok yang paling banyak?',
              imageOptions: ['⭐⭐⭐⭐', '⭐', '⭐⭐', '⭐⭐⭐'],
              correctIndex: 0),
        ];
      case Subject.science:
        return [
          Question.imageChoice(
              question: 'Mana yang termasuk hewan?',
              imageOptions: ['🐘', '🌳', '🚗', '⛰️'],
              correctIndex: 0),
          Question.imageChoice(
              question: 'Mana yang tumbuh di pohon?',
              imageOptions: ['🍎', '🐟', '🚙', '👟'],
              correctIndex: 0),
          Question.imageChoice(
              question: 'Mana yang hidup di air?',
              imageOptions: ['🐠', '🐒', '🦅', '🐛'],
              correctIndex: 0),
          Question.imageChoice(
              question: 'Mana sumber cahaya di siang hari?',
              imageOptions: ['☀️', '🌙', '💡', '🔦'],
              correctIndex: 0),
          Question.imageChoice(
              question: 'Mana bunga?',
              imageOptions: ['🌸', '🍃', '🍎', '🌱'],
              correctIndex: 0),
          Question.imageChoice(
              question: 'Mana benda yang bisa terbang?',
              imageOptions: ['🦋', '🐢', '🐌', '🐜'],
              correctIndex: 0),
        ];
      case Subject.indonesian:
        return [
          Question.imageChoice(
              question: 'Mana yang termasuk buah?',
              imageOptions: ['🍌', '🪑', '👕', '⚽'],
              correctIndex: 0),
        ];
      case Subject.socialStudies:
        return [
          Question.imageChoice(
              question: 'Mana alat transportasi?',
              imageOptions: ['🚌', '🍎', '📚', '🌻'],
              correctIndex: 0),
          Question.imageChoice(
              question: 'Mana yang bekerja memadamkan api?',
              imageOptions: ['🚒', '🚜', '🚓', '🚑'],
              correctIndex: 0),
          Question.imageChoice(
              question: 'Mana tempat untuk belajar?',
              imageOptions: ['🏫', '🏥', '🏪', '🏭'],
              correctIndex: 0),
          Question.imageChoice(
              question: 'Mana alat transportasi laut?',
              imageOptions: ['⛴️', '🚁', '🚗', '🚲'],
              correctIndex: 0),
          Question.imageChoice(
              question: 'Mana bendera Indonesia?',
              imageOptions: ['🇮🇩', '🇯🇵', '🇸🇬', '🇲🇾'],
              correctIndex: 0),
        ];
      case Subject.religion:
        return [
          Question.imageChoice(
              question: 'Mana tempat ibadah umat Islam?',
              imageOptions: ['🕌', '⛪', '🏫', '🏥'],
              correctIndex: 0),
        ];
    }
  }

  /// Soal "dengar" (TTS auto) — latih menyimak; pilih jawaban yang benar.
  List<Question> _listeningExtras(Subject s) {
    switch (s) {
      case Subject.english:
        return [
          Question.listening(
              question: '🎧 Dengar, lalu pilih kata yang benar',
              audioText: 'banana',
              options: ['banana', 'apple', 'orange', 'grape'],
              correctIndex: 0),
          Question.listening(
              question: '🎧 Listen and choose the animal you hear',
              audioText: 'elephant',
              options: ['elephant', 'tiger', 'rabbit', 'monkey'],
              correctIndex: 0),
        ];
      case Subject.indonesian:
        return [
          Question.listening(
              question: '🎧 Dengar, lalu pilih kata yang benar',
              audioText: 'kucing',
              options: ['kucing', 'anjing', 'burung', 'ikan'],
              correctIndex: 0),
        ];
      default:
        return const [];
    }
  }

  /// Soal "susun urutan" untuk Matematika (urutkan angka kecil→besar).
  List<Question> _mathSequences(int grade) {
    final maxN = grade <= 1 ? 9 : grade <= 2 ? 20 : grade <= 3 ? 50 : 100;
    final nums = <int>{};
    while (nums.length < 4) {
      nums.add(1 + _rng.nextInt(maxN));
    }
    final sorted = nums.toList()..sort();
    return [
      Question.sequence(
          question: 'Urutkan dari kecil ke besar',
          order: sorted.map((e) => '$e').toList(),
          emoji: '🔢'),
    ];
  }

  /// Soal "susun urutan" khas tiap mapel — kesulitan beragam agar tersebar.
  List<Question> _sequenceExtras(Subject s) {
    switch (s) {
      case Subject.english:
        return [
          Question.sequence(
              question: 'Arrange the letters in order',
              order: const ['A', 'B', 'C', 'D'],
              difficulty: 1,
              emoji: '🔤'),
          Question.sequence(
              question: 'Arrange the words alphabetically',
              order: const ['Apple', 'Ball', 'Cat', 'Dog'],
              difficulty: 3,
              emoji: '🔤'),
        ];
      case Subject.indonesian:
        return [
          Question.sequence(
              question: 'Urutkan huruf sesuai abjad',
              order: const ['A', 'B', 'C', 'D'],
              difficulty: 1,
              emoji: '🔤'),
          Question.sequence(
              question: 'Susun kata jadi kalimat yang benar',
              order: const ['Saya', 'suka', 'membaca', 'buku'],
              difficulty: 3,
              emoji: '📝'),
        ];
      case Subject.science:
        return [
          Question.sequence(
              question: 'Urutkan tahap pertumbuhan kupu-kupu',
              order: const ['Telur', 'Ulat', 'Kepompong', 'Kupu-kupu'],
              difficulty: 2,
              emoji: '🦋'),
          Question.sequence(
              question: 'Urutkan daur air',
              order: const ['Menguap', 'Awan', 'Hujan', 'Sungai'],
              difficulty: 3,
              emoji: '💧'),
        ];
      case Subject.socialStudies:
        return [
          Question.sequence(
              question: 'Urutkan hari dalam seminggu',
              order: const ['Senin', 'Selasa', 'Rabu', 'Kamis'],
              difficulty: 1,
              emoji: '📅'),
          Question.sequence(
              question: 'Urutkan tingkatan wilayah dari kecil',
              order: const ['RT', 'Desa', 'Kecamatan', 'Kabupaten'],
              difficulty: 3,
              emoji: '🗺️'),
        ];
      case Subject.religion:
        return [
          Question.sequence(
              question: 'Urutkan gerakan salat',
              order: const ['Takbir', 'Rukuk', 'Sujud', 'Salam'],
              difficulty: 2,
              emoji: '🕌'),
          Question.sequence(
              question: 'Urutkan wudu dengan benar',
              order: const ['Tangan', 'Kumur', 'Muka', 'Kaki'],
              difficulty: 3,
              emoji: '💧'),
        ];
      default:
        return const [];
    }
  }

  List<Question> _bankFor(Subject s, int grade) {
    final base = _rawBank(s, grade);
    final extras = <Question>[];
    // Soal berformat-beda (pasangkan/susun-urutan) disertakan di SEMUA kelas
    // agar tiap kelas punya variasi bentuk — bukan hanya pilihan ganda. Karena
    // ditandai kesulitan yang beragam, format-format ini tersebar ke banyak
    // level (tidak menggerombol di satu level).
    extras.addAll(_matchingExtras(s));
    extras.addAll(_sequenceExtras(s));
    // Pilih-gambar & menyimak bersifat bantu-baca → untuk kelas awal saja.
    if (grade <= 3) extras.addAll(_imageChoiceExtras(s));
    if (grade <= 2) extras.addAll(_listeningExtras(s));
    return extras.isEmpty ? base : [...base, ...extras];
  }

  List<Question> _rawBank(Subject s, int grade) {
    // Bila ada bank dari server (update tanpa APK), pakai itu; jika tidak, bank
    // BAWAAN aplikasi (selalu tersedia, bahkan offline / sebelum sempat unduh).
    final override = ContentService.instance.forSubject(s, grade);
    if (override != null && override.isNotEmpty) return override;
    switch (grade) {
      case 1:
        return ContentKelas1.forSubject(s);
      case 2:
        return ContentKelas2.forSubject(s);
      case 3:
        return ContentKelas3.forSubject(s);
      case 4:
        return ContentKelas4.forSubject(s);
      case 5:
        return ContentKelas5.forSubject(s);
      case 6:
        return ContentKelas6.forSubject(s);
      default:
        return ContentKelas1.forSubject(s);
    }
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
