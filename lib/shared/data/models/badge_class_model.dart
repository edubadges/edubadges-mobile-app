import 'package:edubadges/shared/data/models/badge_alignment_model.dart';
import 'package:edubadges/shared/data/models/badge_class_extension_model.dart';
import 'package:edubadges/shared/data/models/issuer_model.dart';
import 'package:edubadges/shared/domain/entities/badge_class_entity.dart';
import 'package:edubadges/shared/domain/enums/assessment_type.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:edubadges/shared/domain/enums/participation_type.dart';

class BadgeClassModel extends BadgeClassEntity {
  BadgeClassModel({
    required super.id,
    required super.name,
    required super.entityId,
    required super.badgeClassType,
    required super.image,
    super.description,
    super.formal,
    super.participation,
    super.assessmentType,
    super.assessmentIdVerified,
    super.assessmentSupervised,
    super.selfEnrollmentEnabled,
    super.userMayEnroll,
    super.stackable,
    super.qualityAssuranceName,
    super.qualityAssuranceUrl,
    super.qualityAssuranceDescription,
    super.criteriaText,
    super.eqfNlqfLevelVerified,
    super.badgeclassextensionSet,
    List<BadgeAlignmentModel>? alignments,
    super.issuer,
  }) : super(
          alignments: alignments?.map((m) => m.toEntity()).toList(),
        );

  factory BadgeClassModel.fromJson(Map<String, dynamic> json) {
    return BadgeClassModel(
      id: json['id'] as int,
      name: json['name'] as String,
      entityId: json['entity_id'] as String,
      badgeClassType: BadgeClassType.fromString(json['badge_class_type'] as String?) ?? BadgeClassType.regular,
      image: json['image'] as String,
      description: json['description'] as String?,
      formal: json['formal'] as bool?,
      participation: ParticipationType.fromCommaSeparatedString(
        json['participation'] as String?,
      ),
      assessmentType: AssessmentType.fromCommaSeparatedString(
        json['assessment_type'] as String?,
      ),
      assessmentIdVerified: json['assessment_id_verified'] as bool?,
      assessmentSupervised: json['assessment_supervised'] as bool?,
      selfEnrollmentEnabled: (json['self_enrollment_enabled'] as bool?) ?? false,
      userMayEnroll: (json['user_may_enroll'] as bool?) ?? false,
      stackable: json['stackable'] as bool?,
      qualityAssuranceName: json['quality_assurance_name'] as String?,
      qualityAssuranceUrl: json['quality_assurance_url'] as String?,
      qualityAssuranceDescription:
          json['quality_assurance_description'] as String?,
      criteriaText: json['criteria_text'] as String?,
      eqfNlqfLevelVerified: _parseBool(json['eqf_nlqf_level_verified']) ?? false,
      badgeclassextensionSet: json['badgeclassextension_set'] != null
          ? (json['badgeclassextension_set'] as List)
              .map((item) => BadgeClassExtensionModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      alignments: json['alignments'] != null
          ? (json['alignments'] as List)
              .map(
                (item) =>
                    BadgeAlignmentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList()
          : null,
      issuer: json['issuer'] != null
          ? IssuerModel.fromJson(json['issuer'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'entity_id': entityId,
      'badge_class_type': badgeClassType.value,
      'image': image,
      if (description != null) 'description': description,
      if (formal != null) 'formal': formal,
      if (participation != null && participation!.isNotEmpty)
        'participation': participation!.map((e) => e.value).join(','),
      if (assessmentType != null && assessmentType!.isNotEmpty)
        'assessment_type': assessmentType!.map((e) => e.value).join(','),
      if (assessmentIdVerified != null) 'assessment_id_verified': assessmentIdVerified,
      if (assessmentSupervised != null) 'assessment_supervised': assessmentSupervised,
      'self_enrollment_enabled': selfEnrollmentEnabled,
      'user_may_enroll': userMayEnroll,
      if (qualityAssuranceName != null) 'quality_assurance_name': qualityAssuranceName,
      if (qualityAssuranceUrl != null) 'quality_assurance_url': qualityAssuranceUrl,
      if (qualityAssuranceDescription != null)
        'quality_assurance_description': qualityAssuranceDescription,
      if (criteriaText != null) 'criteria_text': criteriaText,
      'eqf_nlqf_level_verified': eqfNlqfLevelVerified,
      if (badgeclassextensionSet != null)
        'badgeclassextension_set': badgeclassextensionSet!
            .map((item) => (item as BadgeClassExtensionModel).toJson())
            .toList(),
      if (alignments != null)
        'alignments': alignments!
            .map((e) => BadgeAlignmentModel.fromEntity(e).toJson())
            .toList(),
      if (issuer != null) 'issuer': (issuer as IssuerModel).toJson(),
    };
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return null;
  }
}
