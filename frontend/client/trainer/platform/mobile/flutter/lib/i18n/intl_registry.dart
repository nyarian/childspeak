import 'package:childspeak/i18n/registry.dart';
import 'package:intl/intl.dart';

class IntlRegistry implements MessageRegistry {
  const IntlRegistry();

  @override
  String unknownError() => Intl.message(
        'Unknown error',
        name: 'unknownError',
        desc: 'Used to inform the user that an unknown error occurred',
      );

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

  @override
  String entitiesSearchLabel() => Intl.message(
        "Please enter a category name (or it's part)",
        name: 'entitiesSearchLabel',
        desc: 'Informs user about entities search page intention',
      );

  @override
  String entitiesCategoriesSearchEmptyStateLabel(String query) => Intl.message(
        'Seems that there are no results for "$query"',
        name: 'entitiesCategoriesSearchEmptyStateLabel',
        desc: 'Informs user no results were received for a particular query',
        args: <Object>[query],
        examples: const <String, Object>{
          'query': '"asd"',
        },
      );

  @override
  String entitiesSearchError(String description) => Intl.message(
        'Error occurred during entities search: $description.',
        name: 'entitiesSearchError',
        desc: 'Splash page auth check or authentication error description',
        args: <Object>[description],
        examples: const <String, Object>{
          'description': 'Internet connection is unavailable',
        },
      );
}
