import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';
import '../utils/app_logger.dart';

@lazySingleton
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

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
    if (isMuted || text.isEmpty) return;
    try {
      AppLogger.i('TTS Starting to speak: $text');
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
