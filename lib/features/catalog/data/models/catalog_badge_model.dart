import 'package:edubadges/features/catalog/domain/entities/catalog_badge.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'catalog_badge_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CatalogBadgeModel extends CatalogBadge {
  const CatalogBadgeModel({
    required super.createdAt,
    required super.name,
    super.image,
    required super.archived,
    required super.entityId,
    required super.isPrivate,
    required super.isMicroCredentials,
    @JsonKey(fromJson: _badgeClassTypeFromJson, toJson: _badgeClassTypeToJson)
    required super.badgeClassType,
    super.issuerNameEnglish,
    super.issuerNameDutch,
    required super.issuerEntityId,
    super.issuerImageDutch,
    super.issuerImageEnglish,
    super.facultyNameEnglish,
    super.facultyNameDutch,
    required super.facultyEntityId,
    super.facultyImageDutch,
    super.facultyImageEnglish,
    required super.facultyOnBehalfOf,
    super.facultyType,
    super.institutionNameEnglish,
    super.institutionNameDutch,
    required super.institutionEntityId,
    super.institutionImageDutch,
    super.institutionImageEnglish,
    super.institutionType,
    required super.selfRequestedAssertionsCount,
    required super.directAwardedAssertionsCount,
  });

  factory CatalogBadgeModel.fromJson(Map<String, dynamic> json) =>
      _$CatalogBadgeModelFromJson(json);

  Map<String, dynamic> toJson() => _$CatalogBadgeModelToJson(this);

  @override
  @JsonKey(fromJson: _badgeClassTypeFromJson, toJson: _badgeClassTypeToJson)
  BadgeClassType get badgeClassType => super.badgeClassType;

  static BadgeClassType _badgeClassTypeFromJson(String? value) =>
      BadgeClassType.fromString(value) ?? BadgeClassType.regular;

  static String _badgeClassTypeToJson(BadgeClassType badgeClassType) =>
      badgeClassType.value;
}
