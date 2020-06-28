import 'package:childspeak/firebase.dart';
import 'package:childspeak/i18n/intl_delegate.dart';
import 'package:childspeak/i18n/intl_registry.dart';
import 'package:childspeak/i18n/registry.dart';
import 'package:childspeak/ui/page/speaking_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estd/logger.dart';
import 'package:estd/type/lateinit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_framework/log/flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp firebaseApp = await FirebaseApp.configure(
    name: 'ChildSpeak',
    options: firebaseOptions,
  );
  runApp(DependencyContainer(firestore: Firestore(app: firebaseApp)));
}

class DependencyContainer extends StatefulWidget {
  final Firestore firestore;

  const DependencyContainer({
    @required this.firestore,
    Key key,
  }) : super(key: key);

  @override
  _DependencyContainerState createState() => _DependencyContainerState();
}

class _DependencyContainerState extends State<DependencyContainer> {

  final ImmutableLateinit<FlutterTts> _flutterTtsRef = ImmutableLateinit<
      FlutterTts>.unset();

  @override
  void initState() {
    super.initState();
    _flutterTtsRef.value = FlutterTts();
  }

  @override
  Widget build(BuildContext context) =>
      MultiProvider(
        providers: <Provider<dynamic>>[
          Provider<Logger>.value(value: const FlutterLogger()),
          Provider<Firestore>.value(value: widget.firestore),
          Provider<MessageRegistry>.value(value: IntlRegistry()),
          Provider<FlutterTts>.value(value: _flutterTtsRef.value),
        ],
        child: const ChildSpeak(),
      );
}

class ChildSpeak extends StatelessWidget {
  const ChildSpeak({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      MaterialApp(
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
