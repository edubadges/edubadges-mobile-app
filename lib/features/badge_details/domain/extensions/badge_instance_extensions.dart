import 'package:edubadges/shared/domain/entities/badge_class_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';

extension BadgeInstanceExtensions on BadgeInstanceEntity {
  T? getExtensionValue<T>(String extensionName) =>
      badgeclass.getExtensionValue<T>(extensionName);
}
