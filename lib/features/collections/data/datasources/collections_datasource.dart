import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/core/network/errors/error_codes.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:edubadges/features/collections/data/models/collections_model.dart';

abstract class CollectionsDataSource {
  Future<List<CollectionsModel>> getCollectionss();
}

class CollectionsDataSourceImpl implements CollectionsDataSource {
  final ApiClient apiClient;

  CollectionsDataSourceImpl(this.apiClient);

  @override
  Future<List<CollectionsModel>> getCollectionss() async {
    final response = await apiClient.get<List<dynamic>>(
      '/badge-collections',
      queryParameters: {'format': 'json'},
    );
    final data = response.data ?? [];

    try {
      return data.map((json) {
        if (json is! Map<String, dynamic>) {
          throw FormatException('Invalid badge collection format');
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
}
