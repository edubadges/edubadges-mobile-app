import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/core/network/errors/error_codes.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/features/catalog/data/models/catalog_institution_model.dart';

abstract class CatalogInstitutionDataSource {
  Future<List<CatalogInstitutionModel>> getCatalogInstitutions();
}

class CatalogInstitutionDataSourceImpl implements CatalogInstitutionDataSource {
  final ApiClient apiClient;

  CatalogInstitutionDataSourceImpl(this.apiClient);

  @override
  Future<List<CatalogInstitutionModel>> getCatalogInstitutions() async {
    final response = await apiClient.get<List<dynamic>>(
      '/institutions',
    );

    final data = response.data;
    if (data == null) {
      throw const ParsingException(
        message: 'No data returned from institutions API',
        code: ErrorCodes.parsingError,
      );
    }

    try {
      final institutions = data.map((json) {
        if (json is! Map<String, dynamic>) {
          throw const FormatException('Invalid catalog institution format');
        }
        return CatalogInstitutionModel.fromJson(json);
      }).toList();

      return institutions;
    } catch (e, stackTrace) {
      logger.e('Failed to parse catalog institutions', error: e, stackTrace: stackTrace);
      throw ParsingException(
        message: 'Failed to parse catalog institutions: ${e.toString()}',
        code: ErrorCodes.parsingError,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
