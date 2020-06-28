import 'package:childspeak/i18n/intl_delegate.dart';
import 'package:childspeak/ui/page/speaking_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const ChildSpeak());

class ChildSpeak extends StatelessWidget {
  const ChildSpeak({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ChildSpeak',
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          const IntlDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: IntlDelegate.supportedLocales,
        color: Colors.blue,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue,
          accentColor: Colors.yellowAccent,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SpeakingSessionPage(),
      );
}
