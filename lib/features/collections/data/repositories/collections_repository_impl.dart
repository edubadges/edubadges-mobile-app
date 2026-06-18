import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:edubadges/features/collections/data/datasources/collections_datasource.dart';
import 'package:edubadges/features/collections/data/models/create_collection_request.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/features/collections/domain/repositories/collections_repository.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';

class CollectionsRepositoryImpl implements CollectionsRepository {
  final CollectionsDataSource collectionsDataSource;

  CollectionsRepositoryImpl(this.collectionsDataSource);

  @override
  Future<Either<Failure, List<CollectionsEntity>>> getCollections(
    List<BadgeInstanceEntity> badgeInstances,
  ) async {
    try {
      final collections = await collectionsDataSource.getCollections();

      final badgeInstanceMap = {
        for (var instance in badgeInstances) instance.entityId: instance,
      };

      final collectionsWithBadges = collections.map((collection) {
        final matchedBadges = collection.badgeInstanceIds
            .map((id) => badgeInstanceMap[id])
            .whereType<BadgeInstanceEntity>()
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
      return Left(ValidationFailure(e.message, code: e.code, apiErrorCode: e.apiErrorCode));
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
    required List<String> badgeInstanceIds,
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
      return Left(ValidationFailure(e.message, code: e.code, apiErrorCode: e.apiErrorCode));
    } on AppException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> patchCollection({
    required String entityId,
    String? name,
    String? description,
    bool? public,
    List<String>? badgeInstanceIds,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (public != null) data['public'] = public;
      if (badgeInstanceIds != null) {
        data['badge_instances'] = badgeInstanceIds;
      }
      if (data.isEmpty) {
        return const Left(
          ValidationFailure(
            'No fields to update',
            code: 'patch_empty',
          ),
        );
      }
      await collectionsDataSource.patchCollection(entityId, data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, code: e.code, apiErrorCode: e.apiErrorCode));
    } on AppException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CollectionsEntity>> createCollection({
    required String name,
    String? description,
    required bool public,
    required List<String> badgeInstanceIds,
  }) async {
    try {
      final request = CreateCollectionRequest(
        name: name,
        description: description,
        public: public,
        badgeInstances: badgeInstanceIds,
      );
      final collection = await collectionsDataSource.createCollection(request);
      return Right(collection);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, code: e.code, apiErrorCode: e.apiErrorCode));
    } on AppException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
