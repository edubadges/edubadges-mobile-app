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
    final response = await apiClient.get<List<dynamic>>('/badge-instances');
    final data = response.data;
    
    if (data == null) {
      return [];
    }
    
    return (data)
        .map((json) => BadgeInstanceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
