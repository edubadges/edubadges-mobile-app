// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_instance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BadgeInstanceModel _$BadgeInstanceModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'BadgeInstanceModel',
      json,
      ($checkedConvert) {
        final val = BadgeInstanceModel(
          id: $checkedConvert('id', (v) => (v as num).toInt()),
          createdAt: $checkedConvert(
            'created_at',
            (v) => DateTime.parse(v as String),
          ),
          entityId: $checkedConvert('entity_id', (v) => v as String),
          issuedOn: $checkedConvert(
            'issued_on',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          awardType: $checkedConvert('award_type', (v) => v as String),
          revoked: $checkedConvert('revoked', (v) => v as bool? ?? false),
          expiresAt: $checkedConvert(
            'expires_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          acceptance: $checkedConvert(
            'acceptance',
            (v) => BadgeInstanceModel._acceptanceFromJson(v as String),
          ),
          public: $checkedConvert('public', (v) => v as bool? ?? true),
          badgeclass: $checkedConvert(
            'badgeclass',
            (v) => BadgeInstanceModel._badgeClassFromJson(
              v as Map<String, dynamic>,
            ),
          ),
          linkedinUrl: $checkedConvert('linkedin_url', (v) => v as String?),
          gradeAchieved: $checkedConvert('grade_achieved', (v) => v as String?),
          includeGradeAchieved: $checkedConvert(
            'include_grade_achieved',
            (v) => v as bool? ?? false,
          ),
          includeEvidence: $checkedConvert(
            'include_evidence',
            (v) => v as bool? ?? false,
          ),
          evidences: $checkedConvert(
            'evidences',
            (v) => BadgeInstanceModel._evidencesFromJson(v as List?),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'createdAt': 'created_at',
        'entityId': 'entity_id',
        'issuedOn': 'issued_on',
        'awardType': 'award_type',
        'expiresAt': 'expires_at',
        'linkedinUrl': 'linkedin_url',
        'gradeAchieved': 'grade_achieved',
        'includeGradeAchieved': 'include_grade_achieved',
        'includeEvidence': 'include_evidence',
      },
    );

Map<String, dynamic> _$BadgeInstanceModelToJson(BadgeInstanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'entity_id': instance.entityId,
      'issued_on': ?instance.issuedOn?.toIso8601String(),
      'award_type': instance.awardType,
      'revoked': instance.revoked,
      'expires_at': ?instance.expiresAt?.toIso8601String(),
      'public': instance.public,
      'linkedin_url': ?instance.linkedinUrl,
      'grade_achieved': ?instance.gradeAchieved,
      'include_grade_achieved': instance.includeGradeAchieved,
      'include_evidence': instance.includeEvidence,
      'acceptance': BadgeInstanceModel._acceptanceToJson(instance.acceptance),
      'badgeclass': BadgeInstanceModel._badgeClassToJson(instance.badgeclass),
      'evidences': ?BadgeInstanceModel._evidencesToJson(instance.evidences),
    };
