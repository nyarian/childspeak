import 'package:childspeak/i18n/registry.dart';
import 'package:intl/intl.dart';

class IntlRegistry implements MessageRegistry {
  const IntlRegistry();

  @override
  String splashPageAuthenticationError(String message) => Intl.message(
        'Error occurred during server initial interaction: $message.',
        name: 'splashPageAuthenticationError',
        desc: 'Splash page auth check or authentication error description',
        args: <Object>[message],
        examples: const <String, Object>{
          'message': 'Internet connection is unavailable',
        },
      );

  @override
  String splashPageLoadingLabel() => Intl.message(
        'Preparing things up...',
        name: 'splashPageLoadingLabel',
        desc: 'Label describing splash page loading state (encapsulated '
            'authentication)',
      );

  @override
  String entitiesNameSessionPageLabel() => Intl.message(
        'Name all you see!',
        name: 'entitiesNameSessionPageLabel',
        desc: 'Label for the entities naming page from which the user will '
            'understand the purpose of it',
      );

  @override
  String entitiesFetchError(String description) => Intl.message(
        'Error occurred during loading: $description',
        name: 'entitiesFetchError',
        desc: 'Informs the user about entities fetch exception',
        args: <Object>[description],
        examples: const <String, Object>{
          'description': 'Internet connection is unavailable'
        },
      );

  @override
  String entitiesLoadingLabel() => Intl.message(
        'Just a second...',
        name: 'entitiesLoadingLabel',
        desc: 'Informs the user that entities are loading',
      );

  @override
  String entitiesEmptyStateLabel() => Intl.message(
        'Strange, seems that there are no items to name. Please try '
        'again later or contact the developer (orkay255@gmail.com) '
        'if the issue persists',
        name: 'entitiesEmptyStateLabel',
        desc: 'Informs the user that no entities were received but the fetch '
            'operation itself was successful',
      );
}
