import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/exceptions.dart';
import 'package:edubadges/core/errors/failures.dart';
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
    try {
      await loginDataSource.login();
      final status = await remoteDataSource.login();

      // If required, perform a second login with specific acr_values.
      // This should trigger the system to let the user complete the registration flow.
      // TODO: this doesnt work properly yet, we flagged it with the client and their backenders
      if (status is LoginLinkAccountRequired || status is LoginRevalidateNameRequired) {
        await loginDataSource.login(addAcrValues: true);
        await remoteDataSource.login();
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await loginDataSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await loginDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
