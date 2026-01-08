import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/login/domain/entities/login_entity.dart';

abstract class LoginRepository {
  Future<Either<Failure, List<LoginEntity>>> getLogins();
  Future<Either<Failure, LoginEntity>> getLoginById(String id);
}
