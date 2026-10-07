import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';
import '../utils/app_logger.dart';

@lazySingleton
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  String? _lastSpokenText;
  DateTime? _lastSpokenTime;

  TtsService() {
    _init();
  }

  Future<void> _init() async {
    await _flutterTts.setLanguage("es-PE");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }

  Future<void> speak(String text, {bool isMuted = false}) async {
    if (isMuted || text.trim().isEmpty) return;

    final now = DateTime.now();
    if (_lastSpokenText == text &&
        _lastSpokenTime != null &&
        now.difference(_lastSpokenTime!).inSeconds < 5) {
      AppLogger.w('TTS: Ignorando llamada duplicada en menos de 5s: "$text"');
      return;
    }

    _lastSpokenText = text;
    _lastSpokenTime = now;

    try {
      AppLogger.i('TTS Starting to speak: $text');
      await _flutterTts.stop();
      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.speak(text);
    } catch (e) {
      AppLogger.e('TTS Error: $e');
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
