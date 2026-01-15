import 'package:edubadges/features/login/domain/repositories/login_repository.dart';

class AuthRepositoryImpl {
  final LoginRepository loginRepository;

  AuthRepositoryImpl(this.loginRepository);

  Future<bool> isLoggedIn() => loginRepository.isLoggedIn().then((result) => result.getOrElse(() => false));

  Future<void> login() => loginRepository.login();

  Future<void> logout() => loginRepository.logout();
}