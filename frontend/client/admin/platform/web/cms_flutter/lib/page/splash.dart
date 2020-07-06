import 'dart:async';

import 'package:bloc/authentication/bloc.dart';
import 'package:cms/page/entity/add.dart';
import 'package:cms/page/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_framework/ioc/provider_locator.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  AuthenticationBloc _bloc;

  StreamSubscription<Object> _navigationSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = ProviderServiceLocator(context).get<AuthenticationBloc>();
    _navigationSubscription = _bloc.state.listen((state) {
      if (state.authStatus == AuthenticationStatus.authenticated) {
        Navigator.of(context).pushReplacementNamed(AddEntityPage.name);
      } else if (state.authStatus == AuthenticationStatus.notAuthenticated) {
        Navigator.of(context).pushReplacementNamed(SignInPage.name);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _navigationSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<AuthenticationState>(
          stream: _bloc.state,
          initialData: _bloc.currentState,
          builder: (ctx, snapshot) =>
              Center(child: _buildStateBasedTree(snapshot.data)),
        ),
      );

  Widget _buildStateBasedTree(AuthenticationState state) =>
      state.hasError ? _buildErrorTree(state.error) : _buildLoadingTree();

  Widget _buildErrorTree(Object error) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Error occurred, hit the bottom icon to retry'
              '\n${error.toString()}'),
          const SizedBox(height: 16),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _bloc.onAuthStateCheckEvent,
          ),
        ],
      );

  Widget _buildLoadingTree() => Column(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          Text('Checking auth status, just a sec...'),
          SizedBox(height: 16),
          CircularProgressIndicator(),
        ],
      );
}
