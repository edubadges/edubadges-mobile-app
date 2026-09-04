import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/core/network/errors/error_codes.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/features/catalog/data/models/catalog_badge_model.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_badges_response.dart';
import 'package:edubadges/features/catalog/domain/enums/catalog_institution_type.dart';

abstract class CatalogDataSource {
  Future<CatalogBadgesResponse> getCatalogBadges({
    String? search,
    CatalogInstitutionType? institutionType,
    String? institutionId,
    int page = 1,
  });
}

class CatalogDataSourceImpl implements CatalogDataSource {
  final ApiClient apiClient;

  CatalogDataSourceImpl(this.apiClient);

  @override
  Future<CatalogBadgesResponse> getCatalogBadges({
    String? search,
    CatalogInstitutionType? institutionType,
    String? institutionId,
    int page = 1,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/catalog',
      queryParameters: {
        'page': page,
        'name': ?search,
        if (institutionType != null) 'institution_type': institutionType.name,
        'institution': ?institutionId,
      },
    );

    final data = response.data;
    if (data == null) {
      throw const ParsingException(
        message: 'No data returned from catalog API',
        code: ErrorCodes.parsingError,
      );
    }

    try {
      final count = data['count'] as int? ?? 0;
      final next = data['next'] as String?;
      final previous = data['previous'] as String?;
      final resultsData = data['results'] as List<dynamic>? ?? [];

      final badges = resultsData.map((json) {
        if (json is! Map<String, dynamic>) {
          throw const FormatException('Invalid catalog badge format');
        }
        return CatalogBadgeModel.fromJson(json);
      }).toList();

      return CatalogBadgesResponse(
        count: count,
        next: next,
        previous: previous,
        results: badges,
      );
    } catch (e, stackTrace) {
      logger.e('Failed to parse catalog badges', error: e, stackTrace: stackTrace);
      throw ParsingException(
        message: 'Failed to parse catalog badges: $e}',
        code: ErrorCodes.parsingError,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
