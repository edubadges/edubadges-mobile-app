import 'package:edubadges/shared/data/datasources/oidc_auth_datasource.dart';

abstract class LoginDataSource {
  Future<void> login();
  Future<void> logout();
  Future<bool> isLoggedIn();
}

class LoginDataSourceImpl implements LoginDataSource {
  final OidcAuthDataSource oidcAuthDataSource;

  LoginDataSourceImpl(this.oidcAuthDataSource);

  @override
  Future<void> login() async {
    await oidcAuthDataSource.login();
  }

  @override
  Future<void> logout() async {
    await oidcAuthDataSource.logout();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await oidcAuthDataSource.isAuthenticated();
  }
}