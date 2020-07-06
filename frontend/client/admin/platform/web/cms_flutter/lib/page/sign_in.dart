import 'dart:async';

import 'package:bloc/authentication/bloc.dart';
import 'package:cms/page/entity/add.dart';
import 'package:cms/widget/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_framework/ioc/provider_locator.dart';

class SignInPage extends StatefulWidget {
  static const String name = '/sign_in';

  static Widget builder(BuildContext context) => const SignInPage();

  const SignInPage({Key key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  StreamSubscription<Object> _navigationSubscription;
  AuthenticationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ProviderServiceLocator(context).get<AuthenticationBloc>();
    _navigationSubscription = _bloc.state.where(_isAuthenticated).listen(
        (_) => Navigator.of(context).pushReplacementNamed(AddEntityPage.name));
  }

  bool _isAuthenticated(AuthenticationState state) =>
      state.authStatus == AuthenticationStatus.authenticated;

  @override
  void dispose() {
    super.dispose();
    _navigationSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) => _SignInWidget(
        bloc: _bloc,
        emailController: _emailController,
        passwordController: _passwordController,
      );
}

class _SignInWidget extends StatelessWidget {
  final AuthenticationBloc bloc;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const _SignInWidget({
    @required this.bloc,
    @required this.emailController,
    @required this.passwordController,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<AuthenticationState>(
          stream: bloc.state,
          initialData: bloc.currentState,
          builder: (ctx, snapshot) => Center(
            child: _buildStateBasedTree(ctx, snapshot.data),
          ),
        ),
      );

  Widget _buildStateBasedTree(BuildContext context, AuthenticationState state) {
    if (state.hasError) {
      return _buildErrorTree(Theme.of(context), state.error);
    } else if (state.processStatus ==
        AuthenticationProcessStatus.authenticating) {
      return _buildAuthenticatedTree();
    } else {
      return _buildSignInForm(context);
    }
  }

  Widget _buildErrorTree(ThemeData theme, Object error) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Error occurred during authentication: ${error.toString()}'),
          RaisedButton(
            color: theme.accentColor,
            onPressed: bloc.onAuthenticationErrorProcessedEvent,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Understood', style: theme.accentTextTheme.button),
            ),
          )
        ],
      );

  Widget _buildAuthenticatedTree() => const CircularProgressIndicator();

  Widget _buildSignInForm(BuildContext context) => Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildEmailField(),
            _buildPasswordField(),
            _buildSignInButton(Theme.of(context))
          ],
        ),
      );

  Widget _buildEmailField() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ColoredTextFormField(
          controller: emailController,
          autoFocus: true,
          labelText: 'Email',
          hintText: 'Email...',
          keyboardType: TextInputType.emailAddress,
        ),
      );

  Widget _buildPasswordField() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ColoredTextFormField(
          controller: passwordController,
          labelText: 'Password',
          hintText: 'Password...',
          obscureText: true,
        ),
      );

  Widget _buildSignInButton(ThemeData theme) => Padding(
        padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
        child: SizedBox(
          child: RaisedButton(
            color: theme.accentColor,
            onPressed: () => bloc.onEmailPasswordSignInEvent(
              emailController.text,
              passwordController.text,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Sign in', style: theme.accentTextTheme.button),
            ),
          ),
        ),
      );
}
