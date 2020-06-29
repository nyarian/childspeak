import 'package:firebase_auth/firebase_auth.dart';
import 'package:infrastructure/authentication/service.dart';

class FirebaseAuthenticationService implements AuthenticationService {
  final FirebaseAuth _auth;

  FirebaseAuthenticationService(this._auth);

  @override
  Future<bool> isAuthenticated() async => (await _auth.currentUser()) != null;

  @override
  Future<void> authenticateAnonymously() => _auth.signInAnonymously();

  @override
  Future<void> authenticateWithEmailAndPassword({
    String email,
    String password,
  }) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);
}
