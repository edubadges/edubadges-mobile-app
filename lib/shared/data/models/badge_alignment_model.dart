import 'package:edubadges/shared/domain/entities/badge_alignment_entity.dart';

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

  factory BadgeAlignmentModel.fromJson(Map<String, dynamic> json) {
    return BadgeAlignmentModel(
      targetName: json['target_name'] as String?,
      targetUrl: json['target_url'] as String?,
      targetDescription: json['target_description'] as String?,
      targetFramework: json['target_framework'] as String?,
      targetCode: json['target_code'] as String?,
    );
  }

  factory BadgeAlignmentModel.fromEntity(BadgeAlignmentEntity entity) {
    return BadgeAlignmentModel(
      targetName: entity.targetName,
      targetUrl: entity.targetUrl,
      targetDescription: entity.targetDescription,
      targetFramework: entity.targetFramework,
      targetCode: entity.targetCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (targetName != null) 'target_name': targetName,
      if (targetUrl != null) 'target_url': targetUrl,
      if (targetDescription != null) 'target_description': targetDescription,
      if (targetFramework != null) 'target_framework': targetFramework,
      if (targetCode != null) 'target_code': targetCode,
    };
  }

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
