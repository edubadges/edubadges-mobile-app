import 'dart:async';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:edubadges/core/utils/logger.dart';

class AppBadgeService {
  Future<void> syncUnclaimedCount(int unclaimedCount) async {
    try {
      final supported = await Future<bool>.value(AppBadgePlus.isSupported());
      if (!supported) return;
      final badgeValue = unclaimedCount.clamp(0, 999999);
      await Future<void>.value(AppBadgePlus.updateBadge(badgeValue));
    } catch (error, stackTrace) {
      logger.w(
        'Failed to update app badge',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> clear() => syncUnclaimedCount(0);
}
