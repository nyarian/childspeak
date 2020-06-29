import 'package:meta/meta.dart';

abstract class AuthenticationService {
  Future<bool> isAuthenticated();

  Future<void> authenticateAnonymously();

  Future<void> authenticateWithEmailAndPassword({
    @required String email,
    @required String password,
  });
}
