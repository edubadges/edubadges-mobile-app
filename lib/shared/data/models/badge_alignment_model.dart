import 'package:edubadges/shared/domain/entities/badge_alignment_entity.dart';

class BadgeAlignmentModel extends BadgeAlignmentEntity {
  const BadgeAlignmentModel({
    super.targetName,
    super.targetUrl,
    super.targetDescription,
    super.targetFramework,
    super.targetCode,
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

  Map<String, dynamic> toJson() {
    return {
      if (targetName != null) 'target_name': targetName,
      if (targetUrl != null) 'target_url': targetUrl,
      if (targetDescription != null) 'target_description': targetDescription,
      if (targetFramework != null) 'target_framework': targetFramework,
      if (targetCode != null) 'target_code': targetCode,
    };
  }
}
