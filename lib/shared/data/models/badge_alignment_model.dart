import 'package:edubadges/shared/domain/entities/badge_alignment_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'badge_alignment_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BadgeAlignmentModel {
  final String? targetName;
  final String? targetUrl;
  final String? targetDescription;
  final String? targetFramework;
  final String? targetCode;

  const BadgeAlignmentModel({
    this.targetName,
    this.targetUrl,
    this.targetDescription,
    this.targetFramework,
    this.targetCode,
  });

  factory BadgeAlignmentModel.fromJson(Map<String, dynamic> json) =>
      _$BadgeAlignmentModelFromJson(json);

  factory BadgeAlignmentModel.fromEntity(BadgeAlignmentEntity entity) {
    return BadgeAlignmentModel(
      targetName: entity.targetName,
      targetUrl: entity.targetUrl,
      targetDescription: entity.targetDescription,
      targetFramework: entity.targetFramework,
      targetCode: entity.targetCode,
    );
  }

  Map<String, dynamic> toJson() => _$BadgeAlignmentModelToJson(this);

  BadgeAlignmentEntity toEntity() {
    return BadgeAlignmentEntity(
      targetName: targetName,
      targetUrl: targetUrl,
      targetDescription: targetDescription,
      targetFramework: targetFramework,
      targetCode: targetCode,
    );
  }
}
