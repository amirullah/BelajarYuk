import 'package:flutter_tts/flutter_tts.dart';

/// Layanan Text-to-Speech untuk membacakan soal (read-aloud) & listening.
/// Bahasa Inggris → en-US; mapel lain → id-ID.
class TtsService {
  static final TtsService instance = TtsService._();
  TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _init = false;

  Future<void> _ensure() async {
    if (_init) return;
    await _tts.setSpeechRate(0.45); // agak pelan untuk anak
    await _tts.setPitch(1.05);
    await _tts.awaitSpeakCompletion(true);
    _init = true;
  }

  Future<void> speak(String text, {bool english = false}) async {
    if (text.trim().isEmpty) return;
    await _ensure();
    await _tts.stop();
    await _tts.setLanguage(english ? 'en-US' : 'id-ID');
    await _tts.speak(text);
  }

  Future<void> stop() async => _tts.stop();
}
