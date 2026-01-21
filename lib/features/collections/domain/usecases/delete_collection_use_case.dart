import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/collections/domain/repositories/collections_repository.dart';

class DeleteCollectionUseCase {
  final CollectionsRepository _repository;

  const DeleteCollectionUseCase({required CollectionsRepository repository})
    : _repository = repository;

  Future<Either<Failure, void>> call({required String entityId}) async {
    if (entityId.isEmpty) {
      return left(
        const ValidationFailure(
          'Collection ID cannot be empty',
          code: 'invalid_collection_id',
        ),
      );
    }

    return await _repository.deleteCollection(entityId);
  }
}
