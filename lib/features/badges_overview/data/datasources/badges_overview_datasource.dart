import 'package:edubadges/core/errors/exceptions.dart';
import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';

abstract class BadgesOverviewDataSource {
  Future<List<BadgeInstanceModel>> getBadgeInstances();
}

class BadgesOverviewDataSourceImpl implements BadgesOverviewDataSource {
  final ApiClient apiClient;

  BadgesOverviewDataSourceImpl(this.apiClient);

  @override
  Future<List<BadgeInstanceModel>> getBadgeInstances() async {
    try {
      final response = await apiClient.get<List<dynamic>>('/badge-instances');
      final data = response.data;
      
      if (data == null) {
        return [];
      }
      
      try {
        return data
            .map((json) {
              if (json is! Map<String, dynamic>) {
                throw FormatException('Invalid badge instance format');
              }
              return BadgeInstanceModel.fromJson(json);
            })
            .toList();
      } catch (e) {
        throw ServerException(
          'Failed to parse badge instances: ${e.toString()}',
          500,
        );
      }
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unexpected error loading badge instances: ${e.toString()}',
        500,
      );
    }
  }
}
