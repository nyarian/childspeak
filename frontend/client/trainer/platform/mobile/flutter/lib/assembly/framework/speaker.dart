import 'package:estd/ioc/service_locator.dart';
import 'package:estd/logger.dart';
import 'package:flutter_framework/domain/entity/flutter_tts.dart';
import 'package:flutter_framework/domain/entity/speaker.dart';
import 'package:flutter_tts/flutter_tts.dart';

class EntitySpeakerFactory {
  factory EntitySpeakerFactory() => const EntitySpeakerFactory._();

  const EntitySpeakerFactory._();

  EntitySpeaker create(ServiceLocator locator) =>
      OneSpeechAtAMomentSpeakerDecorator(
        TtsPluginEntitySpeaker(
          locator.get<FlutterTts>(),
          locator.get<Logger>(),
        ),
      );
}
