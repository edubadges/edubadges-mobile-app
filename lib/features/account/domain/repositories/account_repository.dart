import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';

abstract class AccountRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
}
