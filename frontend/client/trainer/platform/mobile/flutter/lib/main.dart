import 'package:childspeak/firebase.dart';
import 'package:childspeak/i18n/intl_delegate.dart';
import 'package:childspeak/i18n/intl_registry.dart';
import 'package:childspeak/i18n/registry.dart';
import 'package:childspeak/ui/page/speaking_session.dart';
import 'package:childspeak/ui/page/splash.dart';
import 'package:childspeak/ui/theme/font.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estd/logger.dart';
import 'package:estd/type/lateinit.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  runApp(DependencyContainer(
    firestore: Firestore(app: firebaseApp),
    auth: FirebaseAuth.fromApp(firebaseApp),
  ));
}

class DependencyContainer extends StatefulWidget {
  final Firestore firestore;
  final FirebaseAuth auth;

  const DependencyContainer({
    @required this.firestore,
    @required this.auth,
    Key key,
  }) : super(key: key);

  @override
  _DependencyContainerState createState() => _DependencyContainerState();
}

class _DependencyContainerState extends State<DependencyContainer> {
  final ImmutableLateinit<FlutterTts> _flutterTtsRef =
      ImmutableLateinit<FlutterTts>.unset();

  @override
  void initState() {
    super.initState();
    _flutterTtsRef.value = FlutterTts();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: <Provider<dynamic>>[
          Provider<Firestore>.value(value: widget.firestore),
          Provider<FirebaseAuth>.value(value: widget.auth),
          Provider<FlutterTts>.value(value: _flutterTtsRef.value),
          Provider<Logger>.value(value: const FlutterLogger()),
          Provider<MessageRegistry>.value(value: const IntlRegistry()),
        ],
        child: const ChildSpeak(),
      );
}

class ChildSpeak extends StatelessWidget {
  const ChildSpeak({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ChildSpeak',
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          IntlDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: IntlDelegate.supportedLocales,
        color: Colors.blue,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue,
          accentColor: Colors.deepPurpleAccent,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: ChildSpeakFont.balsamiqSans.asFontFamilyAttribute,
        ),
        routes: const <String, WidgetBuilder>{
          SpeakingSessionPage.name: SpeakingSessionPage.builder,
        },
        home: const SplashPage(),
      );
}
