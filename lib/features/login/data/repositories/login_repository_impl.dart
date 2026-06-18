import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/errors/repository_guard.dart';
import 'package:edubadges/features/login/data/datasources/login_datasource.dart';
import 'package:edubadges/features/login/data/datasources/login_remote_datasource.dart';
import 'package:edubadges/features/login/data/models/login_user_status.dart';
import 'package:edubadges/features/login/domain/repositories/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginDataSource loginDataSource;
  final LoginRemoteDataSource remoteDataSource;

  LoginRepositoryImpl(this.loginDataSource, this.remoteDataSource);

  @override
  Future<Either<Failure, void>> login() async {
    return repositoryGuard<void>(
      () async {
        await loginDataSource.login();
        final status = await remoteDataSource.login();

        // If required, perform a second login with specific acr_values.
        // This should trigger the system to let the user complete the registration flow.
        if (status is LoginLinkAccountRequired ||
            status is LoginRevalidateNameRequired) {
          await loginDataSource.login(addAcrValues: true);
          await remoteDataSource.login();
        }

        return;
      },
      logMessage: 'Failed to login',
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return repositoryGuard<void>(
      () async {
        await loginDataSource.logout();
        return;
      },
      logMessage: 'Failed to logout',
    );
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    return repositoryGuard<bool>(
      () => loginDataSource.isLoggedIn(),
      logMessage: 'Failed to check login status',
    );
  }
}
