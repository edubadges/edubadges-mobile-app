import 'package:edubadges/shared/data/services/app_badge_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appBadgeServiceProvider = Provider<AppBadgeService>((ref) {
  return AppBadgeService();
});
