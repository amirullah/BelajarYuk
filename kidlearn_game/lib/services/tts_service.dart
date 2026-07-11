import 'package:flutter_tts/flutter_tts.dart';

/// Layanan Text-to-Speech untuk membacakan soal (read-aloud) & listening.
/// Bahasa Inggris → en-US; mapel lain → id-ID.
///
/// Disetel agar terdengar ramah anak (bukan robot): nada lebih tinggi,
/// tempo agak pelan, dan memilih suara berkualitas terbaik yang tersedia
/// di perangkat (mis. suara jaringan Google TTS).
class TtsService {
  static final TtsService instance = TtsService._();
  TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _init = false;
  String? _idVoice; // nama voice id-ID terbaik
  String? _enVoice; // nama voice en-US terbaik

  Future<void> _ensure() async {
    if (_init) return;
    await _tts.setSpeechRate(0.48); // agak pelan untuk anak
    await _tts.setPitch(1.4); // nada lebih tinggi → terkesan ceria/muda
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    await _pickBestVoices();
    _init = true;
  }

  /// Cari suara terbaik untuk id-ID & en-US.
  /// Prioritas: suara perempuan / jaringan (biasanya lebih halus & ramah).
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
          if (name.contains('female') || name.contains('wanita')) score += 3;
          if (name.contains('network') || name.contains('wavenet') ||
              name.contains('neural')) score += 4;
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
    } catch (_) {
      // Beberapa perangkat tak mendukung getVoices — abaikan, pakai default.
    }
  }

  Future<void> speak(String text, {bool english = false}) async {
    if (text.trim().isEmpty) return;
    await _ensure();
    await _tts.stop();
    await _tts.setLanguage(english ? 'en-US' : 'id-ID');
    final voice = english ? _enVoice : _idVoice;
    if (voice != null) {
      try {
        await _tts.setVoice({'name': voice, 'locale': english ? 'en-US' : 'id-ID'});
      } catch (_) {}
    }
    // Nada sedikit lebih tinggi lagi untuk bahasa → kesan suara anak.
    await _tts.setPitch(english ? 1.35 : 1.45);
    await _tts.speak(text);
  }

  Future<void> stop() async => _tts.stop();
}
