import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/data/models/badge_evidence_model.dart';
import 'package:edubadges/shared/domain/entities/badge_class_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_evidence_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'badge_instance_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BadgeInstanceModel extends BadgeInstanceEntity {
  const BadgeInstanceModel({
    required super.id,
    @JsonKey(fromJson: _dateTimeFromJson) required super.createdAt,
    required super.entityId,
    @JsonKey(fromJson: _nullableDateTimeFromJson) super.issuedOn,
    required super.awardType,
    @JsonKey(defaultValue: false) required super.revoked,
    @JsonKey(fromJson: _nullableDateTimeFromJson) super.expiresAt,
    @JsonKey(fromJson: _acceptanceFromJson, toJson: _acceptanceToJson)
    required super.acceptance,
    @JsonKey(defaultValue: true) required super.public,
    @JsonKey(fromJson: _badgeClassFromJson, toJson: _badgeClassToJson)
    required super.badgeclass,
    super.linkedinUrl,
    super.gradeAchieved,
    @JsonKey(fromJson: _parseBoolOrFalse, defaultValue: false)
    super.includeGradeAchieved,
    @JsonKey(fromJson: _parseBoolOrFalse, defaultValue: false)
    super.includeEvidence,
    @JsonKey(fromJson: _evidencesFromJson, toJson: _evidencesToJson)
    super.evidences,
    super.eppn,
    super.recipientEmail,
    super.recipientFirstName,
    super.recipientSurname,
  });

  factory BadgeInstanceModel.fromJson(Map<String, dynamic> json) =>
      _$BadgeInstanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$BadgeInstanceModelToJson(this);

  @override
  @JsonKey(fromJson: _acceptanceFromJson, toJson: _acceptanceToJson)
  BadgeAcceptance get acceptance => super.acceptance;

  @override
  @JsonKey(fromJson: _badgeClassFromJson, toJson: _badgeClassToJson)
  BadgeClassEntity get badgeclass => super.badgeclass;

  @override
  @JsonKey(fromJson: _evidencesFromJson, toJson: _evidencesToJson)
  List<BadgeEvidenceEntity>? get evidences => super.evidences;

  static DateTime _dateTimeFromJson(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.parse(value as String);
  }

  static DateTime? _nullableDateTimeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.parse(value as String);
  }

  static BadgeAcceptance _acceptanceFromJson(String value) {
    switch (value.toLowerCase()) {
      case 'accepted':
        return BadgeAcceptance.accepted;
      case 'rejected':
        return BadgeAcceptance.rejected;
      case 'unaccepted':
      default:
        return BadgeAcceptance.unaccepted;
    }
  }

  static String _acceptanceToJson(BadgeAcceptance value) => value.value;

  static BadgeClassEntity _badgeClassFromJson(Map<String, dynamic> value) =>
      BadgeClassModel.fromJson(value);

  static Map<String, dynamic> _badgeClassToJson(BadgeClassEntity value) =>
      (value as BadgeClassModel).toJson();

  static List<BadgeEvidenceEntity>? _evidencesFromJson(List<dynamic>? value) =>
      value
          ?.map(
            (item) => BadgeEvidenceModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();

  static List<Map<String, dynamic>>? _evidencesToJson(
    List<BadgeEvidenceEntity>? value,
  ) => value?.map((item) => (item as BadgeEvidenceModel).toJson()).toList();

  static bool _parseBoolOrFalse(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true') return true;
    }
    return false;
  }
}
