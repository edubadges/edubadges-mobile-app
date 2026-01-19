import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/core/network/errors/error_codes.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';

abstract class BadgesOverviewDataSource {
  Future<List<BadgeInstanceModel>> getBadgeInstances();
}

class BadgesOverviewDataSourceImpl implements BadgesOverviewDataSource {
  final ApiClient apiClient;

  BadgesOverviewDataSourceImpl(this.apiClient);

  @override
  Future<List<BadgeInstanceModel>> getBadgeInstances() async {
    final response = await apiClient.get<List<dynamic>>('/badge-instances');
    final data = response.data ?? [];

    try {
      return data.map((json) {
        if (json is! Map<String, dynamic>) {
          throw FormatException('Invalid badge instance format');
        }
        return BadgeInstanceModel.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      throw ParsingException(
        message: 'Failed to parse badge instances: ${e.toString()}',
        code: ErrorCodes.parsingError,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
