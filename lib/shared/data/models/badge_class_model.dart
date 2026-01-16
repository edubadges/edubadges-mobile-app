import 'package:edubadges/shared/data/models/badge_class_extension_model.dart';
import 'package:edubadges/shared/data/models/issuer_model.dart';
import 'package:edubadges/shared/domain/entities/badge_class_entity.dart';

class BadgeClassModel extends BadgeClassEntity {
  const BadgeClassModel({
    required super.id,
    required super.name,
    required super.entityId,
    super.image,
    super.description,
    super.formal,
    super.participation,
    super.assessmentType,
    super.assessmentIdVerified,
    super.assessmentSupervised,
    super.qualityAssuranceName,
    super.badgeclassextensionSet,
    super.issuer,
  });

  factory BadgeClassModel.fromJson(Map<String, dynamic> json) {
    return BadgeClassModel(
      id: json['id'] as int,
      name: json['name'] as String,
      entityId: json['entity_id'] as String,
      image: json['image'] as String? ?? json['image_url'] as String?, // Depending on the endpoint called the field could be one or the other
      description: json['description'] as String?,
      formal: json['formal'] as bool?,
      participation: json['participation'] as String?,
      assessmentType: json['assessment_type'] as String?,
      assessmentIdVerified: json['assessment_id_verified'] as bool?,
      assessmentSupervised: json['assessment_supervised'] as bool?,
      qualityAssuranceName: json['quality_assurance_name'] as String?,
      badgeclassextensionSet: json['badgeclassextension_set'] != null
          ? (json['badgeclassextension_set'] as List)
              .map((item) => BadgeClassExtensionModel.fromJson(item as Map<String, dynamic>))
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
      if (image != null) 'image': image,
      if (description != null) 'description': description,
      if (formal != null) 'formal': formal,
      if (participation != null) 'participation': participation,
      if (assessmentType != null) 'assessment_type': assessmentType,
      if (assessmentIdVerified != null) 'assessment_id_verified': assessmentIdVerified,
      if (assessmentSupervised != null) 'assessment_supervised': assessmentSupervised,
      if (qualityAssuranceName != null) 'quality_assurance_name': qualityAssuranceName,
      if (badgeclassextensionSet != null)
        'badgeclassextension_set': badgeclassextensionSet!
            .map((item) => (item as BadgeClassExtensionModel).toJson())
            .toList(),
      if (issuer != null) 'issuer': (issuer as IssuerModel).toJson(),
    };
  }
}
