import 'package:infrastructure/authentication/service.dart';

class AuthenticationFacade {

  final AuthenticationService _service;

  AuthenticationFacade(this._service);

  Future<bool> isAuthenticated() => _service.isAuthenticated();

  Future<void> authenticateAnonymously() => _service.authenticateAnonymously();
}
