import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/collections/domain/usecases/update_collection_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../collections_test_helpers.dart';

void main() {
  late FakeCollectionsRepository repository;
  late UpdateCollectionUseCase useCase;

  setUp(() {
    repository = FakeCollectionsRepository();
    useCase = UpdateCollectionUseCase(repository: repository);
  });

  group('UpdateCollectionUseCase.patch', () {
    test(
      'sends name, description and the new badge list in one call',
      () async {
        final result = await useCase.patch(
          entityId: 'c1',
          name: '  Testcollectie 2  ',
          description: 'Omschrijving',
          badgeInstanceIds: ['b2', 'b3'],
        );

        expect(result.isRight(), isTrue);
        expect(repository.patchCalls, hasLength(1));
        final call = repository.patchCalls.single;
        expect(call.entityId, 'c1');
        expect(call.name, 'Testcollectie 2');
        expect(call.description, 'Omschrijving');
        expect(call.badgeInstanceIds, ['b2', 'b3']);
        expect(call.public, isNull);
      },
    );

    test('allows removing every badge (empty list)', () async {
      final result = await useCase.patch(
        entityId: 'c1',
        name: 'Testcollectie 2',
        badgeInstanceIds: const [],
      );

      expect(result.isRight(), isTrue);
      expect(repository.patchCalls.single.badgeInstanceIds, isEmpty);
    });

    test('rejects a blank name without calling the repository', () async {
      final result = await useCase.patch(
        entityId: 'c1',
        name: '   ',
        badgeInstanceIds: const ['b1'],
      );

      expect(
        result.fold((failure) => failure, (_) => null),
        isA<ValidationFailure>().having(
          (failure) => failure.code,
          'code',
          'name_required',
        ),
      );
      expect(repository.patchCalls, isEmpty);
    });

    test('rejects a missing collection id', () async {
      final result = await useCase.patch(entityId: '', name: 'Naam');

      expect(
        result.fold((failure) => failure.code, (_) => null),
        'invalid_collection_id',
      );
      expect(repository.patchCalls, isEmpty);
    });

    test('rejects a call without fields', () async {
      final result = await useCase.patch(entityId: 'c1');

      expect(
        result.fold((failure) => failure.code, (_) => null),
        'patch_empty',
      );
      expect(repository.patchCalls, isEmpty);
    });
  });
}
