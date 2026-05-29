// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_evidence_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BadgeEvidenceModel _$BadgeEvidenceModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BadgeEvidenceModel', json, ($checkedConvert) {
      final val = BadgeEvidenceModel(
        evidenceUrl: $checkedConvert('evidence_url', (v) => v as String?),
        narrative: $checkedConvert('narrative', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String?),
        description: $checkedConvert('description', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'evidenceUrl': 'evidence_url'});

Map<String, dynamic> _$BadgeEvidenceModelToJson(BadgeEvidenceModel instance) =>
    <String, dynamic>{
      'evidence_url': ?instance.evidenceUrl,
      'narrative': ?instance.narrative,
      'name': ?instance.name,
      'description': ?instance.description,
    };
