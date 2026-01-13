import 'package:edubadges/features/badges_overview/data/models/badges_overview_model.dart';

abstract class BadgesOverviewDataSource {
  Future<List<BadgesOverviewModel>> getBadgesOverviews();
  Future<BadgesOverviewModel> getBadgesOverviewById(String id);
}
