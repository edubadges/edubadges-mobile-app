import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';

abstract class CollectionsRepository {
  Future<Either<Failure, List<CollectionsEntity>>> getCollectionss();
  Future<Either<Failure, CollectionsEntity>> getCollectionsById(String id);
}
