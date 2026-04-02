import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/collections/domain/repositories/collections_repository.dart';

class UpdateCollectionUseCase {
  final CollectionsRepository _repository;

  const UpdateCollectionUseCase({required CollectionsRepository repository})
    : _repository = repository;

  Future<Either<Failure, void>> call({
    required String entityId,
    required String name,
    String? description,
    required bool public,
    required List<String> badgeInstanceIds,
  }) async {
    if (entityId.isEmpty) {
      return left(
        const ValidationFailure(
          'Collection ID cannot be empty',
          code: 'invalid_collection_id',
        ),
      );
    }

    if (name.trim().isEmpty) {
      return left(
        const ValidationFailure(
          'Collection name is required',
          code: 'name_required',
        ),
      );
    }

    return await _repository.updateCollection(
      entityId: entityId,
      name: name,
      description: description,
      public: public,
      badgeInstanceIds: badgeInstanceIds,
    );
  }

  Future<Either<Failure, void>> patch({
    required String entityId,
    String? name,
    String? description,
    bool? public,
    List<String>? badgeInstanceIds,
  }) async {
    if (entityId.isEmpty) {
      return left(
        const ValidationFailure(
          'Collection ID cannot be empty',
          code: 'invalid_collection_id',
        ),
      );
    }

    if (name == null &&
        description == null &&
        public == null &&
        badgeInstanceIds == null) {
      return left(
        const ValidationFailure(
          'No fields to update',
          code: 'patch_empty',
        ),
      );
    }

    if (name != null && name.trim().isEmpty) {
      return left(
        const ValidationFailure(
          'Collection name cannot be empty',
          code: 'name_required',
        ),
      );
    }

    return await _repository.patchCollection(
      entityId: entityId,
      name: name?.trim(),
      description: description,
      public: public,
      badgeInstanceIds: badgeInstanceIds,
    );
  }
}
