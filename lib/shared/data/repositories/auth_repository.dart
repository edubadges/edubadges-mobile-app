abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<void> login();
  Future<void> logout();
}