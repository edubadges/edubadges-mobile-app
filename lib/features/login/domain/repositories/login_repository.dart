import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';

abstract class LoginRepository {
  Future<Either<Failure, void>> login();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> isLoggedIn();
}
