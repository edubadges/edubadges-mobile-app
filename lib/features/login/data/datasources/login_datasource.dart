import 'package:edubadges/shared/data/datasources/oidc_auth_datasource.dart';

abstract class LoginDataSource {
  Future<void> login({bool addAcrValues = false});
  Future<void> logout();
  Future<bool> isLoggedIn();
}

class LoginDataSourceImpl implements LoginDataSource {
  final OidcAuthDataSource oidcAuthDataSource;

  LoginDataSourceImpl(this.oidcAuthDataSource);

  @override
  Future<void> login({bool addAcrValues = false}) async {
    await oidcAuthDataSource.login(addAcrValues: addAcrValues);
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
