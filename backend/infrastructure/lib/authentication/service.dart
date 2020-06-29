abstract class AuthenticationService {

  Future<bool> isAuthenticated();

  Future<void> authenticateAnonymously();

}
