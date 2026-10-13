import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';
import '../utils/app_logger.dart';

@lazySingleton
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  String? _lastSpokenText;
  DateTime? _lastSpokenTime;
  bool _isInitialized = false;

  TtsService() {
    _init();
  }

  Future<void> _init() async {
    try {
      await _flutterTts.setLanguage("es-PE");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);
      _isInitialized = true;
      AppLogger.i('TTS Service initialized for es-PE');
    } catch (e) {
      AppLogger.e('TTS Init Error: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }

  Future<void> speak(String text, {bool isMuted = false}) async {
    if (isMuted || text.trim().isEmpty) return;

    final now = DateTime.now();
    // Filtro anti-duplicado ajustado a 1.5s para no ignorar pagos legítimos seguidos
    if (_lastSpokenText == text &&
        _lastSpokenTime != null &&
        now.difference(_lastSpokenTime!).inMilliseconds < 1500) {
      AppLogger.w('TTS: Ignorando llamada duplicada inmediata (<1.5s): "$text"');
      return;
    }

    _lastSpokenText = text;
    _lastSpokenTime = now;

    try {
      if (!_isInitialized) {
        await _init();
      }
      AppLogger.i('TTS Executing speak: "$text"');
      final result = await _flutterTts.speak(text);
      AppLogger.d('TTS Speak Result: $result');
    } catch (e) {
      AppLogger.e('TTS Error: $e');
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
