import 'dart:async';

import 'package:bloc/authentication/bloc.dart';
import 'package:childspeak/assembly/bloc/authentication.dart';
import 'package:childspeak/i18n/registry.dart';
import 'package:childspeak/ui/page/speaking_session.dart';
import 'package:estd/type/lateinit.dart';
import 'package:flutter_framework/ioc/provider_locator.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final ImmutableLateinit<AuthenticationBloc> _blocRef =
      ImmutableLateinit<AuthenticationBloc>.unset();
  final ImmutableLateinit<MessageRegistry> _messagesRef =
      ImmutableLateinit<MessageRegistry>.unset();
  final ImmutableLateinit<StreamSubscription<Object>>
      _autoAuthenticatingSubscriptionRef =
      ImmutableLateinit<StreamSubscription<Object>>.unset();
  final ImmutableLateinit<StreamSubscription<Object>>
      _navigationSubscriptionRef =
      ImmutableLateinit<StreamSubscription<Object>>.unset();

  AuthenticationBloc get _bloc => _blocRef.value;

  MessageRegistry get _messages => _messagesRef.value;

  @override
  void initState() {
    super.initState();
    final locator = ProviderServiceLocator(context);
    _blocRef.value = AuthenticationBlocFactory().create(locator);
    _messagesRef.value = locator.get<MessageRegistry>();
    _autoAuthenticatingSubscriptionRef.value = _bloc.state
        .where((state) =>
            state.processStatus == AuthenticationProcessStatus.idle &&
            state.authStatus == AuthenticationStatus.notAuthenticated)
        .listen((_) => _bloc.onAnonymousSignInEvent());
    _navigationSubscriptionRef.value = _bloc.state
        .where(
            (state) => state.authStatus == AuthenticationStatus.authenticated)
        .listen((_) => Navigator.of(context)
            .pushReplacementNamed(SpeakingSessionPage.name));
  }

  @override
  void dispose() {
    super.dispose();
    _autoAuthenticatingSubscriptionRef.value.cancel();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<AuthenticationState>(
          stream: _bloc.state,
          initialData: _bloc.currentState,
          builder: (ctx, snapshot) => Center(
            child: _buildStateBasedTree(snapshot.data),
          ),
        ),
      );

  Widget _buildStateBasedTree(AuthenticationState state) {
    if (state.hasError) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(_messages.splashPageAuthenticationError(state.error.toString())),
          const SizedBox(height: 16),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: state.processStatus ==
                    AuthenticationProcessStatus.authenticating
                ? _bloc.onAnonymousSignInEvent
                : _bloc.onAuthStateCheckEvent,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(_messages.splashPageLoadingLabel()),
        ],
      );
    }
  }
}
