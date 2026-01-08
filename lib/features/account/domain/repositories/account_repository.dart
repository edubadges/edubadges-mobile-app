import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/account/domain/entities/account_entity.dart';

abstract class AccountRepository {
  Future<Either<Failure, List<AccountEntity>>> getAccounts();
  Future<Either<Failure, AccountEntity>> getAccountById(String id);
}
