import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/core/network/errors/error_codes.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:edubadges/features/collections/data/models/collections_model.dart';
import 'package:edubadges/features/collections/data/models/create_collection_request.dart';

abstract class CollectionsDataSource {
  Future<List<CollectionsModel>> getCollections();
  Future<void> deleteCollection(String entityId);
  Future<void> updateCollection(String entityId, Map<String, dynamic> data);
  Future<CollectionsModel> createCollection(CreateCollectionRequest request);
}

class CollectionsDataSourceImpl implements CollectionsDataSource {
  final ApiClient apiClient;

  CollectionsDataSourceImpl(this.apiClient);

  @override
  Future<List<CollectionsModel>> getCollections() async {
    final response = await apiClient.get<List<dynamic>>('/badge-collections');
    final data = response.data ?? [];

    try {
      return data.map((json) {
        if (json is! Map<String, dynamic>) {
          throw const FormatException('Invalid badge collection format');
        }
        return CollectionsModel.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      throw ParsingException(
        message: 'Failed to parse badge collections: ${e.toString()}',
        code: ErrorCodes.parsingError,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteCollection(String entityId) async {
    await apiClient.delete<void>('/badge-collections/$entityId');
  }

  @override
  Future<void> updateCollection(
    String entityId,
    Map<String, dynamic> data,
  ) async {
    await apiClient.put<void>('/badge-collections/$entityId', data: data);
  }

  @override
  Future<CollectionsModel> createCollection(
    CreateCollectionRequest request,
  ) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/badge-collections',
      data: request.toJson(),
    );
    final json = response.data;
    if (json == null) {
      throw const FormatException('Invalid response from create collection');
    }
    return CollectionsModel.fromJson(json);
  }
}
