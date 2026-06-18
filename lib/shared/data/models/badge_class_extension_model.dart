import 'package:edubadges/shared/domain/entities/badge_class_extension_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'badge_class_extension_model.g.dart';

@JsonSerializable()
class BadgeClassExtensionModel extends BadgeClassExtensionEntity {
  const BadgeClassExtensionModel({required super.name, required super.value});

  factory BadgeClassExtensionModel.fromJson(Map<String, dynamic> json) =>
      _$BadgeClassExtensionModelFromJson(json);

  Map<String, dynamic> toJson() => _$BadgeClassExtensionModelToJson(this);
}
