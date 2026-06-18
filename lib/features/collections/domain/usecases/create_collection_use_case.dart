import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/collections/domain/repositories/collections_repository.dart';

class CreateCollectionUseCase {
  final CollectionsRepository _repository;

  const CreateCollectionUseCase({required CollectionsRepository repository})
    : _repository = repository;

  Future<Either<Failure, void>> call({
    required String name,
    String? description,
    required bool public,
    required List<String> badgeInstanceIds,
  }) async {
    if (name.trim().isEmpty) {
      return left(
        const ValidationFailure(
          'Collection name cannot be empty',
          code: 'invalid_collection_name',
        ),
      );
    }

    final result = await _repository.createCollection(
      name: name.trim(),
      description: description?.trim(),
      public: public,
      badgeInstanceIds: badgeInstanceIds,
    );

    return result.fold((failure) => left(failure), (_) => const Right(null));
  }
}
