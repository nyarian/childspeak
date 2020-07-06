import 'package:bloc/authentication/bloc.dart';
import 'package:bloc/authentication/facade.dart';
import 'package:estd/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_framework/infrastructure/authentication/service.dart';

class AuthenticationBlocFactory {
  factory AuthenticationBlocFactory() => const AuthenticationBlocFactory._();

  const AuthenticationBlocFactory._();

  AuthenticationBloc create(FirebaseAuth auth, Logger logger) =>
      AuthenticationBloc(
        AuthenticationFacade(
          FirebaseAuthenticationService(
            auth,
          ),
        ),
        logger,
      );
}
