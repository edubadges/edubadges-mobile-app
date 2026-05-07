import 'package:edubadges/shared/domain/entities/badge_evidence_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'badge_evidence_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BadgeEvidenceModel extends BadgeEvidenceEntity {
  const BadgeEvidenceModel({
    super.evidenceUrl,
    super.narrative,
    super.name,
    super.description,
  });

  factory BadgeEvidenceModel.fromJson(Map<String, dynamic> json) =>
      _$BadgeEvidenceModelFromJson(json);

  Map<String, dynamic> toJson() => _$BadgeEvidenceModelToJson(this);
}
