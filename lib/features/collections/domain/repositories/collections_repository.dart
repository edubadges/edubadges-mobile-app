import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';

abstract class CollectionsRepository {
  Future<Either<Failure, List<CollectionsEntity>>> getCollectionss(
    List<BadgeInstanceModel> badgeInstances,
  );

  Future<Either<Failure, void>> deleteCollection(String entityId);

  Future<Either<Failure, void>> updateCollection({
    required String entityId,
    required String name,
    String? description,
    required bool public,
    required List<int> badgeInstanceIds,
  });

  Future<Either<Failure, CollectionsEntity>> createCollection({
    required String name,
    String? description,
    required bool public,
    required List<int> badgeInstanceIds,
  });
}
