import 'package:estd/resource.dart';

abstract class EntitySpeaker implements Resource {
  bool get isPlaying;

  Future<void> speak(String text);

  Future<void> setLanguage(String languageCode);
}

class OneSpeechAtAMomentSpeakerDecorator implements EntitySpeaker {
  final EntitySpeaker _delegate;

  OneSpeechAtAMomentSpeakerDecorator(this._delegate);

  @override
  bool get isPlaying => _delegate.isPlaying;

  @override
  Future<void> speak(String text) async {
    if (!_delegate.isPlaying) return _delegate.speak(text);
  }

  @override
  Future<void> setLanguage(String languageCode) =>
      _delegate.setLanguage(languageCode);

  @override
  void close() => _delegate.close();
}
