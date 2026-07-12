import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/subject.dart';

/// Layanan Text-to-Speech BelajarYuk!.
///
/// Disetel agar terdengar ramah & khas anak (nada tinggi, ceria) — bukan robot.
/// Tiap mata pelajaran memakai nada berbeda sehingga terasa seperti "karakter"
/// yang berbeda. Juga menyediakan seruan pujian (yeay/mantap/keren) saat benar,
/// semangat saat salah, dan sorak saat merayakan.
class TtsService {
  static final TtsService instance = TtsService._();
  TtsService._();

  final FlutterTts _tts = FlutterTts();
  final Random _rng = Random();
  bool _init = false;
  String? _idVoice;
  String? _enVoice;
  String? _arabicLang; // kode bahasa Arab yang tersedia (mis. 'ar-SA'), bila ada

  // Nada tinggi khas anak, dibuat sedikit berbeda tiap mapel.
  static const Map<Subject, double> _subjectPitch = {
    Subject.math: 1.50,
    Subject.english: 1.42,
    Subject.indonesian: 1.55,
    Subject.science: 1.62,
    Subject.religion: 1.36,
    Subject.socialStudies: 1.46,
  };
  static const Map<Subject, double> _subjectRate = {
    Subject.math: 0.50,
    Subject.english: 0.46,
    Subject.indonesian: 0.50,
    Subject.science: 0.52,
    Subject.religion: 0.46,
    Subject.socialStudies: 0.49,
  };

  static const _praises = [
    'Hebat!', 'Mantap!', 'Keren!', 'Pintar!', 'Bagus sekali!', 'Hore, betul!',
    'Wah, jagoan!', 'Luar biasa!', 'Top banget!', 'Kamu pintar!', 'Asyik, benar!',
    'Wah, keren sekali!', 'Jenius!', 'Kereen!', 'Mantap jiwa!', 'Kamu hebat!',
    'Betul sekali!', 'Pintar banget!', 'Yeay, hebat!', 'Wow, jago!',
  ];
  static const _encourages = [
    'Coba lagi ya!', 'Hampir benar!', 'Ayo semangat!', 'Tidak apa-apa, coba lagi!',
  ];

  // Pujian KHAS mapel Agama Islam: diucapkan dalam bahasa Arab yang FASIH
  // (pakai voice Arab bila tersedia), dengan transliterasi Latin sebagai
  // cadangan. Frasa dipilih agar COCOK sebagai pujian atas jawaban benar.
  // ( Latin , teks Arab untuk pelafalan fasih ).
  static const List<List<String>> _religionPraises = [
    ['Alhamdulillah!', 'اَلْحَمْدُ لِلّٰهِ'],
    ['Masyaallah!', 'مَا شَاءَ اللّٰهُ'],
    ['Subhanallah!', 'سُبْحَانَ اللّٰهِ'],
    ['Baarakallahu fiik!', 'بَارَكَ اللّٰهُ فِيْكَ'],
    ['Ahsanta!', 'أَحْسَنْتَ'],
    ['Tabaarakallah!', 'تَبَارَكَ اللّٰهُ'],
  ];

  // Pujian khusus mapel Bahasa Inggris — diucapkan dalam bahasa Inggris.
  static const _englishPraises = [
    'Great job!', 'Excellent!', 'Well done!', 'Amazing!', 'Fantastic!',
    'You are so smart!', 'Perfect!', 'Brilliant!', 'Awesome!', 'Super!',
    'Correct! Good job!', 'Wonderful!', 'You did it!', 'Spectacular!',
  ];

  Future<void> _ensure() async {
    if (_init) return;
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    await _pickBestVoices();
    await _detectArabic();
    _init = true;
  }

  /// Cari bahasa Arab yang terpasang (untuk pelafalan pujian Agama yang fasih).
  Future<void> _detectArabic() async {
    try {
      final langs = (await _tts.getLanguages) as List?;
      if (langs == null) return;
      String? found;
      for (final l in langs) {
        final s = '$l'.toLowerCase();
        if (s.startsWith('ar-') || s == 'ar') {
          if (s == 'ar-sa') {
            found = '$l';
            break;
          }
          found ??= '$l';
        }
      }
      _arabicLang = found;
    } catch (_) {}
  }

  Future<void> _pickBestVoices() async {
    try {
      final voices = (await _tts.getVoices) as List?;
      if (voices == null) return;
      String? best(String langPrefix) {
        Map? chosen;
        int chosenScore = -1;
        for (final v in voices) {
          if (v is! Map) continue;
          final locale = '${v['locale'] ?? v['name'] ?? ''}'.toLowerCase();
          final name = '${v['name'] ?? ''}'.toLowerCase();
          if (!locale.startsWith(langPrefix) && !name.contains(langPrefix)) {
            continue;
          }
          int score = 0;
          // Hindari suara pria (nada rendah, kurang mirip anak). 'female'
          // memuat 'male', jadi kecualikan dulu.
          final isFemale = name.contains('female') || name.contains('wanita');
          if (name.contains('male') && !isFemale) score -= 6;
          if (isFemale) score += 3;
          // Suara berkualitas tinggi = artikulasi lebih jelas & natural.
          if (name.contains('network') || name.contains('wavenet') ||
              name.contains('neural')) score += 4;
          // Prioritaskan voice yang eksplisit anak/muda bila tersedia.
          if (name.contains('child') || name.contains('anak') ||
              name.contains('kid') || name.contains('young')) score += 6;
          if (name.contains('-x-') || name.contains('local')) score += 1;
          if (score > chosenScore) {
            chosenScore = score;
            chosen = v;
          }
        }
        return chosen?['name'] as String?;
      }

      _idVoice = best('id-id') ?? best('id');
      _enVoice = best('en-us') ?? best('en');
    } catch (_) {}
  }

  Future<void> _configure(
      {required bool english, required double pitch, required double rate}) async {
    await _tts.setLanguage(english ? 'en-US' : 'id-ID');
    final voice = english ? _enVoice : _idVoice;
    if (voice != null) {
      try {
        await _tts.setVoice(
            {'name': voice, 'locale': english ? 'en-US' : 'id-ID'});
      } catch (_) {}
    }
    await _tts.setPitch(pitch);
    await _tts.setSpeechRate(rate);
  }

  /// Bacakan teks. Nada & tempo mengikuti [subject] bila diberikan.
  Future<void> speak(String text, {Subject? subject, bool english = false}) async {
    if (text.trim().isEmpty) return;
    await _ensure();
    await _tts.stop();
    final pitch = subject != null
        ? (_subjectPitch[subject] ?? 1.45)
        : (english ? 1.35 : 1.45);
    final rate = subject != null ? (_subjectRate[subject] ?? 0.48) : 0.48;
    await _configure(english: english, pitch: pitch, rate: rate);
    await _tts.speak(text);
  }

  /// Seruan pujian singkat saat jawaban benar (nada anak yang ceria).
  /// Pitch di-acak tipis tiap kali agar terdengar bernada/melodius (tak monoton),
  /// tetap tinggi khas anak; tempo sedikit lebih lambat agar artikulasi jelas.
  ///
  /// Khusus mapel Agama Islam ([subject] == Subject.religion): pujian memakai
  /// frasa Islami (Alhamdulillah, Masyaallah, Subhanallah, …) yang diucapkan
  /// FASIH dalam bahasa Arab bila voice Arab tersedia; jika tidak, transliterasi
  /// Latin dibacakan dengan nada anak.
  Future<void> praise({Subject? subject}) async {
    await _ensure();
    await _tts.stop();
    if (subject == Subject.religion) {
      final pair = _religionPraises[_rng.nextInt(_religionPraises.length)];
      if (_arabicLang != null) {
        try {
          await _tts.setLanguage(_arabicLang!);
          await _tts.setPitch(1.42);
          await _tts.setSpeechRate(0.42);
          await _tts.speak(pair[1]);
          return;
        } catch (_) {}
      }
      await _configure(english: false, pitch: 1.6, rate: 0.44);
      await _tts.speak(pair[0]);
      return;
    }
    if (subject == Subject.english) {
      // Pitch lebih tinggi (1.85–2.0) & rate lebih pelan (0.44) agar terdengar
      // seperti anak dan setiap kata terucap jelas dalam bahasa Inggris.
      final pitch = 1.85 + _rng.nextInt(4) * 0.05;
      await _configure(english: true, pitch: pitch, rate: 0.44);
      await _tts.speak(_englishPraises[_rng.nextInt(_englishPraises.length)]);
      return;
    }
    final pitch = 1.68 + _rng.nextInt(5) * 0.045; // 1.68..1.86
    await _configure(english: false, pitch: pitch, rate: 0.50);
    await _tts.speak(_praises[_rng.nextInt(_praises.length)]);
  }

  /// Suara KHAS Uku — nada sangat tinggi & lucu (beda dari suara pujian biasa),
  /// dengan celetukan khas. Dipakai saat Uku "mengintip" menyemangati.
  static const _ukuLines = [
    'Huu-huu! Semangat ya!', 'Uku di sini! Kamu pasti bisa!',
    'Ayo, aku percaya padamu!', 'Huu! Keren sekali kamu!',
    'Jangan menyerah, hore!', 'Uku bangga padamu!',
    'Ayo terus, kamu hebat!', 'Huu-huu! Pintarnya!',
  ];
  Future<void> ukuSay([String? text]) async {
    await _ensure();
    await _tts.stop();
    // Pitch mentok tinggi + tempo lincah = karakter suara Uku yang lucu.
    await _configure(english: false, pitch: 2.0, rate: 0.53);
    await _tts.speak(text ?? _ukuLines[_rng.nextInt(_ukuLines.length)]);
  }

  /// Kata penyemangat lembut saat jawaban salah.
  Future<void> encourage() async {
    await _ensure();
    await _tts.stop();
    await _configure(english: false, pitch: 1.45, rate: 0.5);
    await _tts.speak(_encourages[_rng.nextInt(_encourages.length)]);
  }

  /// Sorak perayaan (naik level / naik kelas) — nada tinggi & bersemangat.
  Future<void> cheer(String phrase) async {
    await _ensure();
    await _tts.stop();
    await _configure(english: false, pitch: 1.6, rate: 0.52);
    await _tts.speak(phrase);
  }

  Future<void> stop() async => _tts.stop();
}
