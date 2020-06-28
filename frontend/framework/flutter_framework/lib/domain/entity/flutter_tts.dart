import 'package:estd/logger.dart';
import 'package:flutter_framework/domain/entity/speaker.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsPluginEntitySpeaker implements EntitySpeaker {
  final FlutterTts _plugin;
  bool _isPlaying = false;

  TtsPluginEntitySpeaker(this._plugin, Logger logger) {
    _plugin
      ..setStartHandler(() => _isPlaying = true)
      ..setCompletionHandler(() => _isPlaying = false)
      ..setErrorHandler(logger.logError);
  }

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<void> speak(String text) => _plugin.speak(text);

  @override
  Future<void> setLanguage(String languageCode) =>
      _plugin.setLanguage(languageCode);

  @override
  void close() => _plugin
      ..setStartHandler(null)
      ..setCompletionHandler(null)
      ..setErrorHandler(null);
}
