import 'package:collection/collection.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';

extension BadgeInstanceExtensions on BadgeInstanceModel {
  T? getExtensionValue<T>(String extensionName) {
    final match = badgeclass.badgeclassextensionSet?.firstWhereOrNull(
      (element) => element.name == extensionName,
    );
    return match?.value as T?;
  }
}