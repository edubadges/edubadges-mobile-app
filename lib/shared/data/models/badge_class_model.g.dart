// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BadgeClassModel _$BadgeClassModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'BadgeClassModel',
      json,
      ($checkedConvert) {
        final val = BadgeClassModel(
          id: $checkedConvert('id', (v) => (v as num).toInt()),
          name: $checkedConvert('name', (v) => v as String),
          entityId: $checkedConvert('entity_id', (v) => v as String),
          badgeClassType: $checkedConvert(
            'badge_class_type',
            (v) => BadgeClassModel._badgeClassTypeFromJson(v as String?),
          ),
          image: $checkedConvert('image', (v) => v as String),
          description: $checkedConvert('description', (v) => v as String?),
          formal: $checkedConvert('formal', (v) => v as bool?),
          participation: $checkedConvert(
            'participation',
            (v) => BadgeClassModel._participationFromJson(v as String?),
          ),
          assessmentType: $checkedConvert(
            'assessment_type',
            (v) => BadgeClassModel._assessmentTypeFromJson(v as String?),
          ),
          assessmentIdVerified: $checkedConvert(
            'assessment_id_verified',
            (v) => v as bool?,
          ),
          assessmentSupervised: $checkedConvert(
            'assessment_supervised',
            (v) => v as bool?,
          ),
          selfEnrollmentEnabled: $checkedConvert(
            'self_enrollment_enabled',
            (v) => v == null ? false : BadgeClassModel._parseBoolOrFalse(v),
            readValue: BadgeClassModel._readSelfEnrollmentEnabled,
          ),
          userMayEnroll: $checkedConvert(
            'user_may_enroll',
            (v) => v == null ? false : BadgeClassModel._parseBoolOrFalse(v),
          ),
          stackable: $checkedConvert('stackable', (v) => v as bool?),
          qualityAssuranceName: $checkedConvert(
            'quality_assurance_name',
            (v) => v as String?,
          ),
          qualityAssuranceUrl: $checkedConvert(
            'quality_assurance_url',
            (v) => v as String?,
          ),
          qualityAssuranceDescription: $checkedConvert(
            'quality_assurance_description',
            (v) => v as String?,
          ),
          criteriaText: $checkedConvert('criteria_text', (v) => v as String?),
          eqfNlqfLevelVerified: $checkedConvert(
            'eqf_nlqf_level_verified',
            (v) => v == null ? false : BadgeClassModel._parseBoolOrFalse(v),
          ),
          badgeclassextensionSet: $checkedConvert(
            'badgeclassextension_set',
            (v) => BadgeClassModel._extensionsFromJson(v as List?),
          ),
          alignments: $checkedConvert(
            'alignments',
            (v) => BadgeClassModel._alignmentsFromJson(v as List?),
          ),
          issuer: $checkedConvert(
            'issuer',
            (v) => BadgeClassModel._issuerFromJson(v as Map<String, dynamic>?),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'entityId': 'entity_id',
        'badgeClassType': 'badge_class_type',
        'assessmentType': 'assessment_type',
        'assessmentIdVerified': 'assessment_id_verified',
        'assessmentSupervised': 'assessment_supervised',
        'selfEnrollmentEnabled': 'self_enrollment_enabled',
        'userMayEnroll': 'user_may_enroll',
        'qualityAssuranceName': 'quality_assurance_name',
        'qualityAssuranceUrl': 'quality_assurance_url',
        'qualityAssuranceDescription': 'quality_assurance_description',
        'criteriaText': 'criteria_text',
        'eqfNlqfLevelVerified': 'eqf_nlqf_level_verified',
        'badgeclassextensionSet': 'badgeclassextension_set',
      },
    );

Map<String, dynamic> _$BadgeClassModelToJson(BadgeClassModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'entity_id': instance.entityId,
      'image': instance.image,
      'description': ?instance.description,
      'formal': ?instance.formal,
      'assessment_id_verified': ?instance.assessmentIdVerified,
      'assessment_supervised': ?instance.assessmentSupervised,
      'stackable': ?instance.stackable,
      'quality_assurance_name': ?instance.qualityAssuranceName,
      'quality_assurance_url': ?instance.qualityAssuranceUrl,
      'quality_assurance_description': ?instance.qualityAssuranceDescription,
      'criteria_text': ?instance.criteriaText,
      'badge_class_type': BadgeClassModel._badgeClassTypeToJson(
        instance.badgeClassType,
      ),
      'participation': ?BadgeClassModel._participationToJson(
        instance.participation,
      ),
      'assessment_type': ?BadgeClassModel._assessmentTypeToJson(
        instance.assessmentType,
      ),
      'self_enrollment_enabled': instance.selfEnrollmentEnabled,
      'user_may_enroll': instance.userMayEnroll,
      'eqf_nlqf_level_verified': instance.eqfNlqfLevelVerified,
      'badgeclassextension_set': ?BadgeClassModel._extensionsToJson(
        instance.badgeclassextensionSet,
      ),
      'alignments': ?BadgeClassModel._alignmentsToJson(instance.alignments),
      'issuer': ?BadgeClassModel._issuerToJson(instance.issuer),
    };
