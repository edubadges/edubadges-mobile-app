import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/exceptions.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/account/data/datasources/account_datasource.dart';
import 'package:edubadges/features/account/domain/entities/account_entity.dart';
import 'package:edubadges/features/account/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountDataSource accountDataSource;

  AccountRepositoryImpl(this.accountDataSource);

  @override
  Future<Either<Failure, List<AccountEntity>>> getAccounts() async {
    try {
      final models = await accountDataSource.getAccounts();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> getAccountById(String id) async {
    try {
      final model = await accountDataSource.getAccountById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
