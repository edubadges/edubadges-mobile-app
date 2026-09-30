import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../collections_test_helpers.dart';

void main() {
  final b1 = testBadge('b1');
  final b2 = testBadge('b2');
  final b3 = testBadge('b3');

  late FakeCollectionsRepository repository;
  late ProviderContainer container;

  Future<void> setUpContainer(List<CollectionsEntity> collections) async {
    container = ProviderContainer(
      overrides: collectionsTestOverrides(
        repository: repository,
        collections: collections,
        claimedBadges: [b1, b2, b3],
      ),
    );
    addTearDown(container.dispose);
    await container.read(badgesOverviewProvider.future);
    await container.read(collectionsProvider.future);
  }

  CollectionsEntity collectionById(String entityId) {
    return container
        .read(collectionsProvider)
        .requireValue
        .firstWhere((c) => c.entityId == entityId);
  }

  TestCollectionsNotifier notifier() =>
      container.read(collectionsProvider.notifier) as TestCollectionsNotifier;

  setUp(() {
    repository = FakeCollectionsRepository();
  });

  group('CollectionsNotifier.patchCollection', () {
    test(
      'updates name, description and badges locally, then refreshes',
      () async {
        await setUpContainer([
          testCollection(badges: [b1, b2]),
          testCollection(entityId: 'c2', name: 'Andere', badges: [b1]),
        ]);

        final result = await notifier().patchCollection(
          entityId: 'c1',
          name: 'Nieuwe naam',
          description: 'Nieuwe omschrijving',
          badgeInstanceIds: ['b2', 'b3'],
        );

        expect(result.isRight(), isTrue);
        expect(repository.patchCalls.single.badgeInstanceIds, ['b2', 'b3']);

        final updated = collectionById('c1');
        expect(updated.name, 'Nieuwe naam');
        expect(updated.description, 'Nieuwe omschrijving');
        expect(updated.badgeInstanceIds, ['b2', 'b3']);
        expect(updated.badgeInstances, [b2, b3]);

        // Other collections are untouched.
        expect(collectionById('c2').badgeInstances, [b1]);
        expect(notifier().refreshCount, 1);
      },
    );

    test('removing every badge leaves the collection empty', () async {
      await setUpContainer([
        testCollection(badges: [b1, b2]),
      ]);

      final result = await notifier().patchCollection(
        entityId: 'c1',
        name: 'Testcollectie 2',
        description: '',
        badgeInstanceIds: const [],
      );

      expect(result.isRight(), isTrue);
      expect(repository.patchCalls.single.badgeInstanceIds, isEmpty);
      final updated = collectionById('c1');
      expect(updated.badgeInstanceIds, isEmpty);
      expect(updated.badgeInstances, isEmpty);
      expect(updated.description, isEmpty);
    });

    test(
      'keeps the resolved badges when the badge list is not patched',
      () async {
        await setUpContainer([
          testCollection(badges: [b1, b2]),
        ]);

        await notifier().patchCollection(entityId: 'c1', public: true);

        final updated = collectionById('c1');
        expect(updated.public, isTrue);
        expect(updated.badgeInstances, [b1, b2]);
      },
    );

    test('returns a failure and keeps the loaded collections', () async {
      final original = testCollection(badges: [b1, b2]);
      await setUpContainer([original]);
      repository.patchResult = const Left(ServerFailure('Boom', 500));

      final result = await notifier().patchCollection(
        entityId: 'c1',
        name: 'Nieuwe naam',
        badgeInstanceIds: const ['b3'],
      );

      expect(result.isLeft(), isTrue);
      final state = container.read(collectionsProvider);
      expect(state.hasError, isFalse);
      expect(state.requireValue.single, original);
      expect(notifier().refreshCount, 0);
    });

    test('rejects a blank name without calling the API', () async {
      await setUpContainer([
        testCollection(badges: [b1]),
      ]);

      final result = await notifier().patchCollection(
        entityId: 'c1',
        name: '  ',
        badgeInstanceIds: const ['b1'],
      );

      expect(
        result.fold((failure) => failure, (_) => null),
        isA<ValidationFailure>(),
      );
      expect(repository.patchCalls, isEmpty);
      expect(collectionById('c1').name, 'Testcollectie 2');
    });
  });
}
