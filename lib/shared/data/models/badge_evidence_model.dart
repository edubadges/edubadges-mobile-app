import 'package:edubadges/shared/domain/entities/badge_evidence_entity.dart';

class BadgeEvidenceModel extends BadgeEvidenceEntity {
  const BadgeEvidenceModel({
    super.evidenceUrl,
    super.narrative,
    super.name,
    super.description,
  });

  factory BadgeEvidenceModel.fromJson(Map<String, dynamic> json) {
    return BadgeEvidenceModel(
      evidenceUrl: json['evidence_url'] as String?,
      narrative: json['narrative'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (evidenceUrl != null) 'evidence_url': evidenceUrl,
      if (narrative != null) 'narrative': narrative,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
    };
  }
}
