import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:childspeak/i18n/generated/messages_all.dart';

class IntlDelegate implements LocalizationsDelegate<bool> {
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  const IntlDelegate();

  @override
  bool isSupported(Locale locale) => supportedLocales.contains(locale);

  @override
  Future<bool> load(Locale locale) async {
    Intl.defaultLocale = locale.toString();
    return initializeMessages(locale.toString());
  }

  @override
  bool shouldReload(LocalizationsDelegate<dynamic> old) => true;

  @override
  Type get type => bool;
}
