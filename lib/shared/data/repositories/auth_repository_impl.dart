import 'package:edubadges/shared/data/datasources/auth_local_datasource.dart';
import 'package:edubadges/shared/data/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Ref ref;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.ref, this.localDataSource);

  @override
  Future<bool> isLoggedIn() => localDataSource.isLoggedIn();

  @override
  Future<void> login() => localDataSource.login();

  @override
  Future<void> logout() => localDataSource.logout();
}