import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/shared/data/models/badge_alignment_model.dart';
import 'package:edubadges/shared/data/models/badge_class_extension_model.dart';
import 'package:edubadges/shared/data/models/issuer_model.dart';
import 'package:edubadges/shared/domain/entities/badge_alignment_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_class_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_class_extension_entity.dart';
import 'package:edubadges/shared/domain/entities/issuer_entity.dart';
import 'package:edubadges/shared/domain/enums/assessment_type.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:edubadges/shared/domain/enums/participation_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'badge_class_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BadgeClassModel extends BadgeClassEntity {
  const BadgeClassModel({
    required super.id,
    required super.name,
    required super.entityId,
    @JsonKey(fromJson: _badgeClassTypeFromJson, toJson: _badgeClassTypeToJson)
    required super.badgeClassType,
    required super.image,
    super.description,
    super.formal,
    @JsonKey(fromJson: _participationFromJson, toJson: _participationToJson)
    super.participation,
    @JsonKey(fromJson: _assessmentTypeFromJson, toJson: _assessmentTypeToJson)
    super.assessmentType,
    super.assessmentIdVerified,
    super.assessmentSupervised,
    @JsonKey(
      readValue: _readSelfEnrollmentEnabled,
      fromJson: _parseBoolOrFalse,
      defaultValue: false,
    )
    super.selfEnrollmentEnabled,
    @JsonKey(fromJson: _parseBoolOrFalse, defaultValue: false)
    super.userMayEnroll,
    super.stackable,
    super.qualityAssuranceName,
    super.qualityAssuranceUrl,
    super.qualityAssuranceDescription,
    super.criteriaText,
    @JsonKey(fromJson: _parseBoolOrFalse, defaultValue: false)
    super.eqfNlqfLevelVerified,
    @JsonKey(
      name: 'badgeclassextension_set',
      fromJson: _extensionsFromJson,
      toJson: _extensionsToJson,
    )
    super.badgeclassextensionSet,
    @JsonKey(fromJson: _alignmentsFromJson, toJson: _alignmentsToJson)
    super.alignments,
    @JsonKey(fromJson: _issuerFromJson, toJson: _issuerToJson) super.issuer,
  });

  factory BadgeClassModel.fromJson(Map<String, dynamic> json) {
    if (!_hasEnrollmentFlag(json)) {
      logger.w(
        'Badge class ${json['entity_id'] ?? json['id']}: '
        'missing enrollment flags '
        '(self_enrollment_enabled, enrollment_enabled)',
      );
    }
    return _$BadgeClassModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$BadgeClassModelToJson(this);

  @override
  @JsonKey(fromJson: _badgeClassTypeFromJson, toJson: _badgeClassTypeToJson)
  BadgeClassType get badgeClassType => super.badgeClassType;

  @override
  @JsonKey(fromJson: _participationFromJson, toJson: _participationToJson)
  List<ParticipationType>? get participation => super.participation;

  @override
  @JsonKey(fromJson: _assessmentTypeFromJson, toJson: _assessmentTypeToJson)
  List<AssessmentType>? get assessmentType => super.assessmentType;

  @override
  @JsonKey(
    readValue: _readSelfEnrollmentEnabled,
    fromJson: _parseBoolOrFalse,
    defaultValue: false,
  )
  bool get selfEnrollmentEnabled => super.selfEnrollmentEnabled;

  @override
  @JsonKey(fromJson: _parseBoolOrFalse, defaultValue: false)
  bool get userMayEnroll => super.userMayEnroll;

  @override
  @JsonKey(fromJson: _parseBoolOrFalse, defaultValue: false)
  bool get eqfNlqfLevelVerified => super.eqfNlqfLevelVerified;

  @override
  @JsonKey(
    name: 'badgeclassextension_set',
    fromJson: _extensionsFromJson,
    toJson: _extensionsToJson,
  )
  List<BadgeClassExtensionEntity>? get badgeclassextensionSet =>
      super.badgeclassextensionSet;

  @override
  @JsonKey(fromJson: _alignmentsFromJson, toJson: _alignmentsToJson)
  List<BadgeAlignmentEntity>? get alignments => super.alignments;

  @override
  @JsonKey(fromJson: _issuerFromJson, toJson: _issuerToJson)
  IssuerEntity? get issuer => super.issuer;

  static BadgeClassType _badgeClassTypeFromJson(String? value) =>
      BadgeClassType.fromString(value) ?? BadgeClassType.regular;

  static String _badgeClassTypeToJson(BadgeClassType value) => value.value;

  static List<ParticipationType>? _participationFromJson(String? value) =>
      ParticipationType.fromCommaSeparatedString(value);

  static String? _participationToJson(List<ParticipationType>? value) =>
      (value == null || value.isEmpty)
      ? null
      : value.map((e) => e.value).join(',');

  static List<AssessmentType>? _assessmentTypeFromJson(String? value) =>
      AssessmentType.fromCommaSeparatedString(value);

  static String? _assessmentTypeToJson(List<AssessmentType>? value) =>
      (value == null || value.isEmpty)
      ? null
      : value.map((e) => e.value).join(',');

  static List<BadgeClassExtensionEntity>? _extensionsFromJson(
    List<dynamic>? value,
  ) => value
      ?.map(
        (item) =>
            BadgeClassExtensionModel.fromJson(item as Map<String, dynamic>),
      )
      .toList();

  static List<Map<String, dynamic>>? _extensionsToJson(
    List<BadgeClassExtensionEntity>? value,
  ) => value
      ?.map((item) => (item as BadgeClassExtensionModel).toJson())
      .toList();

  static List<BadgeAlignmentEntity>? _alignmentsFromJson(
    List<dynamic>? value,
  ) => value
      ?.map(
        (item) => BadgeAlignmentModel.fromJson(
          item as Map<String, dynamic>,
        ).toEntity(),
      )
      .toList();

  static List<Map<String, dynamic>>? _alignmentsToJson(
    List<BadgeAlignmentEntity>? value,
  ) => value?.map((e) => BadgeAlignmentModel.fromEntity(e).toJson()).toList();

  static IssuerEntity? _issuerFromJson(Map<String, dynamic>? value) =>
      value == null ? null : IssuerModel.fromJson(value);

  static Map<String, dynamic>? _issuerToJson(IssuerEntity? value) =>
      value == null ? null : (value as IssuerModel).toJson();

  static bool _hasEnrollmentFlag(Map<String, dynamic> json) =>
      json.containsKey('self_enrollment_enabled') ||
      json.containsKey('enrollment_enabled');

  static Object? _readSelfEnrollmentEnabled(
    Map<dynamic, dynamic> json,
    String key,
  ) {
    if (json.containsKey('self_enrollment_enabled')) {
      return json['self_enrollment_enabled'];
    }
    if (json.containsKey('enrollment_enabled')) {
      return json['enrollment_enabled'];
    }
    return json[key];
  }

  static bool _parseBoolOrFalse(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true') return true;
    }
    return false;
  }
}
