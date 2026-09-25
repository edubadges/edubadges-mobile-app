import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:edubadges/features/collections/data/datasources/collections_datasource.dart';
import 'package:edubadges/features/collections/data/models/collections_model.dart';
import 'package:edubadges/features/collections/data/models/create_collection_request.dart';
import 'package:edubadges/features/collections/data/repositories/collections_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingDataSource implements CollectionsDataSource {
  String? patchedEntityId;
  Map<String, dynamic>? patchedData;
  AppException? patchError;

  @override
  Future<void> patchCollection(
    String entityId,
    Map<String, dynamic> data,
  ) async {
    patchedEntityId = entityId;
    patchedData = data;
    final error = patchError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<List<CollectionsModel>> getCollections() => throw UnimplementedError();

  @override
  Future<void> deleteCollection(String entityId) => throw UnimplementedError();

  @override
  Future<void> updateCollection(String entityId, Map<String, dynamic> data) =>
      throw UnimplementedError();

  @override
  Future<CollectionsModel> createCollection(CreateCollectionRequest request) =>
      throw UnimplementedError();
}

void main() {
  late _RecordingDataSource dataSource;
  late CollectionsRepositoryImpl repository;

  setUp(() {
    dataSource = _RecordingDataSource();
    repository = CollectionsRepositoryImpl(dataSource);
  });

  group('CollectionsRepositoryImpl.patchCollection', () {
    test('sends the badge list as badge_instances', () async {
      final result = await repository.patchCollection(
        entityId: 'c1',
        name: 'Testcollectie 2',
        description: '',
        badgeInstanceIds: ['b1', 'b3'],
      );

      expect(result.isRight(), isTrue);
      expect(dataSource.patchedEntityId, 'c1');
      expect(dataSource.patchedData, {
        'name': 'Testcollectie 2',
        // An empty description is sent so a cleared description is cleared.
        'description': '',
        'badge_instances': ['b1', 'b3'],
      });
    });

    test('sends an empty badge list when every badge is removed', () async {
      await repository.patchCollection(
        entityId: 'c1',
        badgeInstanceIds: const [],
      );

      expect(dataSource.patchedData, {'badge_instances': <String>[]});
    });

    test('maps a server error to a ServerFailure', () async {
      dataSource.patchError = const ServerException(
        message: 'Boom',
        statusCode: 500,
      );

      final result = await repository.patchCollection(
        entityId: 'c1',
        badgeInstanceIds: const ['b1'],
      );

      expect(
        result.fold((failure) => failure, (_) => null),
        isA<ServerFailure>().having(
          (failure) => failure.statusCode,
          'statusCode',
          500,
        ),
      );
    });
  });
}
