import 'package:bloc/authentication/bloc.dart';
import 'package:bloc/authentication/facade.dart';
import 'package:estd/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_framework/infrastructure/authentication/service.dart';
import 'package:estd/ioc/service_locator.dart';

class AuthenticationBlocFactory {
  factory AuthenticationBlocFactory() => const AuthenticationBlocFactory._();

  const AuthenticationBlocFactory._();

  AuthenticationBloc create(ServiceLocator locator) => AuthenticationBloc(
        AuthenticationFacade(
          FirebaseAuthenticationService(
            locator.get<FirebaseAuth>(),
          ),
        ),
        locator.get<Logger>(),
      );
}
