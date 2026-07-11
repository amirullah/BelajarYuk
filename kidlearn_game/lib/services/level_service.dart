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

    // Bank soal per mapel (saat ini Kelas 1; kelas lain menyusul).
    final bank = List<Question>.from(_bankFor(level.subject, level.grade));
    if (bank.isEmpty) return const [];
    bank.shuffle(_rng);

    // Ambil sebanyak questionCount; bila bank kurang, ulang dengan acak lagi.
    final out = <Question>[];
    while (out.length < level.questionCount) {
      if (out.length % bank.length == 0) bank.shuffle(_rng);
      out.add(_shuffleOptions(bank[out.length % bank.length]));
    }
    return _avoidMonotony(out);
  }

  /// Beberapa soal "pasangkan" untuk menambah variasi tipe (Kelas 1-2).
  List<Question> _matchingExtras(Subject s) {
    switch (s) {
      case Subject.english:
        return [
          Question.matching(question: 'Match the animal to its sound', emoji: '🔗', pairs: {
            'Cat': 'Meow', 'Dog': 'Woof', 'Cow': 'Moo', 'Duck': 'Quack',
          }),
        ];
      case Subject.science:
        return [
          Question.matching(question: 'Pasangkan hewan dengan tempat hidupnya', emoji: '🔗', pairs: {
            'Ikan': 'Air', 'Burung': 'Udara', 'Cacing': 'Tanah',
          }),
        ];
      case Subject.indonesian:
        return [
          Question.matching(question: 'Pasangkan kata dengan lawan katanya', emoji: '🔗', pairs: {
            'Besar': 'Kecil', 'Panas': 'Dingin', 'Tinggi': 'Rendah',
          }),
        ];
      case Subject.socialStudies:
        return [
          Question.matching(question: 'Pasangkan profesi dengan tempat kerjanya', emoji: '🔗', pairs: {
            'Guru': 'Sekolah', 'Petani': 'Sawah', 'Nelayan': 'Laut',
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

  /// Soal "susun urutan" khas tiap mapel.
  List<Question> _sequenceExtras(Subject s) {
    switch (s) {
      case Subject.english:
        return [
          Question.sequence(
              question: 'Arrange the letters in order',
              order: const ['A', 'B', 'C', 'D'],
              emoji: '🔤'),
        ];
      case Subject.indonesian:
        return [
          Question.sequence(
              question: 'Urutkan huruf sesuai abjad',
              order: const ['A', 'B', 'C', 'D'],
              emoji: '🔤'),
        ];
      case Subject.science:
        return [
          Question.sequence(
              question: 'Urutkan tahap pertumbuhan kupu-kupu',
              order: const ['Telur', 'Ulat', 'Kepompong', 'Kupu-kupu'],
              emoji: '🦋'),
        ];
      case Subject.socialStudies:
        return [
          Question.sequence(
              question: 'Urutkan hari dalam seminggu',
              order: const ['Senin', 'Selasa', 'Rabu', 'Kamis'],
              emoji: '📅'),
        ];
      default:
        return const [];
    }
  }

  List<Question> _bankFor(Subject s, int grade) {
    final base = _rawBank(s, grade);
    final extras = <Question>[];
    if (grade <= 3) {
      extras.addAll(_matchingExtras(s));
      extras.addAll(_imageChoiceExtras(s));
      if (grade <= 2) extras.addAll(_listeningExtras(s));
    }
    extras.addAll(_sequenceExtras(s));
    return extras.isEmpty ? base : [...base, ...extras];
  }

  List<Question> _rawBank(Subject s, int grade) {
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
