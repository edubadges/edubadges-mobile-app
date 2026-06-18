import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/errors/repository_guard.dart';
import 'package:edubadges/features/account/data/datasources/account_datasource.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/account/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountDataSource accountDataSource;

  AccountRepositoryImpl(this.accountDataSource);

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    return repositoryGuard<ProfileEntity>(
      () => accountDataSource.getProfile(),
      logMessage: 'Failed to fetch profile',
    );
  }

  @override
  Future<Either<Failure, bool>> deleteProfile() async {
    return repositoryGuard<bool>(
      () async {
        await accountDataSource.deleteProfile();
        return true;
      },
      logMessage: 'Failed to delete profile',
    );
  }

  @override
  Future<Either<Failure, void>> acceptTerms(String termsEntityId) async {
    return repositoryGuard<void>(
      () async {
        await accountDataSource.acceptTerms(termsEntityId);
      },
      logMessage: 'Failed to accept terms',
    );
  }

  @override
  Future<Either<Failure, void>> rejectTerms(String entityId) async {
    return await repositoryGuard<void>(
      () async {
        await accountDataSource.rejectTerms(entityId);
        return;
      },
      logMessage: 'Failed to reject terms',
    );
  }
}
