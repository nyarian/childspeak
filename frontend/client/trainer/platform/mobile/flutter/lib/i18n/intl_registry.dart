import 'package:childspeak/i18n/registry.dart';
import 'package:intl/intl.dart';

class IntlRegistry implements MessageRegistry {
  @override
  String testFun() => Intl.message(
        'Test',
        name: 'testFun',
        desc: 'test desc',
      );
}
