import 'package:bloc/authentication/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/assembly/bloc/authentication.dart';
import 'package:cms/page/entity/add.dart';
import 'package:cms/page/sign_in.dart';
import 'package:cms/page/splash.dart';
import 'package:estd/type/lateinit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_framework/log/flutter.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const DependencyContainerWidget());
}

class DependencyContainerWidget extends StatefulWidget {
  const DependencyContainerWidget({Key key}) : super(key: key);

  @override
  _DependencyContainerWidgetState createState() =>
      _DependencyContainerWidgetState();
}

class _DependencyContainerWidgetState extends State<DependencyContainerWidget> {
  final ImmutableLateinit<AuthenticationBloc> _blocRef =
      ImmutableLateinit<AuthenticationBloc>.unset();

  @override
  void initState() {
    super.initState();
    _blocRef.value = AuthenticationBlocFactory()
        .create(FirebaseAuth.instance, const FlutterLogger());
  }

  @override
  void dispose() {
    super.dispose();
    _blocRef.value.close();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: <Provider<dynamic>>[
          Provider<Firestore>.value(value: Firestore.instance),
          Provider<AuthenticationBloc>.value(value: _blocRef.value),
        ],
        child: const ChildSpeakCMS(),
      );
}

class ChildSpeakCMS extends StatelessWidget {
  const ChildSpeakCMS({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ChildSpeak CMS',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue,
          accentColor: Colors.deepPurpleAccent,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: const <String, WidgetBuilder>{
          SignInPage.name: SignInPage.builder,
          AddEntityPage.name: AddEntityPage.builder,
        },
        home: const SplashPage(),
      );
}
