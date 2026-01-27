import 'package:collection/collection.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';

extension BadgeInstanceExtensions on BadgeInstanceEntity {
  T? getExtensionValue<T>(String extensionName) {
    final match = badgeclass.badgeclassextensionSet?.firstWhereOrNull(
      (element) => element.name == extensionName,
    );

    final value = match?.value;
    if (match?.value == null) return null;

    // Handle int to double conversion when T expects a double
    if (value is int && T.toString().contains('double')) {
      return value.toDouble() as T;
    }

    return value as T?;
  }
}
