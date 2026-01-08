import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/exceptions.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/login/data/datasources/login_datasource.dart';
import 'package:edubadges/features/login/domain/entities/login_entity.dart';
import 'package:edubadges/features/login/domain/repositories/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginDataSource loginDataSource;

  LoginRepositoryImpl(this.loginDataSource);

  @override
  Future<Either<Failure, List<LoginEntity>>> getLogins() async {
    try {
      final models = await loginDataSource.getLogins();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, LoginEntity>> getLoginById(String id) async {
    try {
      final model = await loginDataSource.getLoginById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
