import 'package:infrastructure/authentication/service.dart';
import 'package:meta/meta.dart';

class AuthenticationFacade {
  final AuthenticationService _service;

  AuthenticationFacade(this._service);

  Future<bool> isAuthenticated() => _service.isAuthenticated();

  Future<void> authenticateAnonymously() => _service.authenticateAnonymously();

  Future<void> authenticateWithEmailAndPassword({
    @required String email,
    @required String password,
  }) =>
      _service.authenticateWithEmailAndPassword(
        email: email,
        password: password,
      );
}
