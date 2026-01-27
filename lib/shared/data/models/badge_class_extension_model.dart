import 'package:edubadges/shared/domain/entities/badge_class_extension_entity.dart';

class BadgeClassExtensionModel extends BadgeClassExtensionEntity {
  const BadgeClassExtensionModel({
    required super.name,
    required super.value,
  });

  factory BadgeClassExtensionModel.fromJson(Map<String, dynamic> json) {
    return BadgeClassExtensionModel(
      name: json['name'] as String,
      value: json['value'] as dynamic,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}
