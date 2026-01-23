import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/general_terms/domain/entities/general_terms_entity.dart';

abstract class GeneralTermsRepository {
  Future<Either<Failure, List<GeneralTermsEntity>>> getGeneralTermss();
  Future<Either<Failure, GeneralTermsEntity>> getGeneralTermsById(String id);
}
