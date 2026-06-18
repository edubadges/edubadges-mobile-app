import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';

abstract class CollectionsRepository {
  Future<Either<Failure, List<CollectionsEntity>>> getCollections(
    List<BadgeInstanceEntity> badgeInstances,
  );

  Future<Either<Failure, void>> deleteCollection(String entityId);

  Future<Either<Failure, void>> updateCollection({
    required String entityId,
    required String name,
    String? description,
    required bool public,
    required List<String> badgeInstanceIds,
  });

  /// Partial update: only non-null arguments are sent in the PATCH body.
  Future<Either<Failure, void>> patchCollection({
    required String entityId,
    String? name,
    String? description,
    bool? public,
    List<String>? badgeInstanceIds,
  });

  Future<Either<Failure, CollectionsEntity>> createCollection({
    required String name,
    String? description,
    required bool public,
    required List<String> badgeInstanceIds,
  });
}
