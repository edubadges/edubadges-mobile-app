import 'package:collection/collection.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';

extension BadgeInstanceExtensions on BadgeInstanceModel {
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
