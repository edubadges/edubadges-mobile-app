import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:edubadges/features/collections/data/datasources/collections_datasource.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/features/collections/domain/repositories/collections_repository.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';

class CollectionsRepositoryImpl implements CollectionsRepository {
  final CollectionsDataSource collectionsDataSource;

  CollectionsRepositoryImpl(this.collectionsDataSource);

  @override
  Future<Either<Failure, List<CollectionsEntity>>> getCollectionss(
    List<BadgeInstanceModel> badgeInstances,
  ) async {
    try {
      final collections = await collectionsDataSource.getCollectionss();

      final badgeInstanceMap = {
        for (var instance in badgeInstances) instance.id: instance,
      };

      final collectionsWithBadges = collections.map((collection) {
        final matchedBadges = collection.badgeInstanceIds
            .map((id) => badgeInstanceMap[id])
            .whereType<BadgeInstanceModel>()
            .toList();

        return (collection).copyWith(badgeInstances: matchedBadges);
      }).toList();

      return Right(collectionsWithBadges);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ParsingException catch (e) {
      return Left(ServerFailure(e.message, 0));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCollection(String entityId) async {
    try {
      await collectionsDataSource.deleteCollection(entityId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on AppException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateCollection({
    required String entityId,
    required String name,
    String? description,
    required bool public,
    required List<int> badgeInstanceIds,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'public': public,
        'badge_instances': badgeInstanceIds,
      };
      if (description != null && description.isNotEmpty) {
        data['description'] = description;
      }
      await collectionsDataSource.updateCollection(entityId, data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on AppException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
