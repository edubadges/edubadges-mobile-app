import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';

class BadgeInstanceModel extends BadgeInstanceEntity {
  const BadgeInstanceModel({
    required super.id,
    required super.createdAt,
    required super.entityId,
    super.issuedOn,
    required super.awardType,
    required super.revoked,
    super.expiresAt,
    required super.acceptance,
    required super.public,
    required super.badgeclass,
    super.linkedinUrl,
    super.gradeAchieved,
    super.narrative,
    super.includeGradeAchieved,
    super.includeEvidence,
  });

  factory BadgeInstanceModel.fromJson(Map<String, dynamic> json) {
    return BadgeInstanceModel(
      id: json['id'] as int,
      createdAt: json['created_at'] is DateTime
          ? json['created_at'] as DateTime
          : DateTime.parse(json['created_at'] as String),
      entityId: json['entity_id'] as String,
      issuedOn: json['issued_on'] != null
          ? (json['issued_on'] is DateTime
                ? json['issued_on'] as DateTime
                : DateTime.parse(json['issued_on'] as String))
          : null,
      awardType: json['award_type'] as String,
      revoked: json['revoked'] as bool? ?? false,
      expiresAt: json['expires_at'] != null
          ? (json['expires_at'] is DateTime
                ? json['expires_at'] as DateTime
                : DateTime.parse(json['expires_at'] as String))
          : null,
      acceptance: BadgeAcceptance.fromString(json['acceptance'] as String),
      public: json['public'] as bool? ?? true,
      badgeclass: BadgeClassModel.fromJson(
        json['badgeclass'] as Map<String, dynamic>,
      ),
      linkedinUrl: json['linkedin_url'] as String?,
      gradeAchieved: json['grade_achieved'] as String?,
      narrative: json['narrative'] as String?,
      includeGradeAchieved: json['include_grade_achieved'] as bool? ?? false,
      includeEvidence: json['include_evidence'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'entity_id': entityId,
      if (issuedOn != null) 'issued_on': issuedOn!.toIso8601String(),
      'award_type': awardType,
      'revoked': revoked,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
      'acceptance': acceptance.value,
      'public': public,
      'badgeclass': (badgeclass as BadgeClassModel).toJson(),
      if (linkedinUrl != null) 'linkedin_url': linkedinUrl,
      if (gradeAchieved != null) 'grade_achieved': gradeAchieved,
      'include_grade_achieved': includeGradeAchieved,
      'include_evidence': includeEvidence,
    };
  }
}
