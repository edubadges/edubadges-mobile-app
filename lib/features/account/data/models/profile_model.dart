import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    @JsonKey(defaultValue: '') required super.firstName,
    @JsonKey(defaultValue: '') required super.lastName,
    @JsonKey(defaultValue: '') required super.email,
    @JsonKey(defaultValue: '') required super.entityId,
    @JsonKey(defaultValue: false) required super.marketingOptIn,
    super.institution,
    @JsonKey(defaultValue: false) required super.isSuperuser,
    @JsonKey(defaultValue: false) required super.termsAgreed,
    required super.termsagreementSet,
    @JsonKey(fromJson: _dateTimeFromJson) required super.dateJoined,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  @override
  @JsonKey(
    name: 'termsagreement_set',
    fromJson: _termsAgreementSetFromJson,
    toJson: _termsAgreementSetToJson,
  )
  List<TermsAgreementEntity> get termsagreementSet => super.termsagreementSet;

  static DateTime _dateTimeFromJson(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.parse(value as String);
  }

  static List<TermsAgreementEntity> _termsAgreementSetFromJson(
    List<dynamic>? value,
  ) =>
      value
          ?.map((e) => TermsAgreementModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      <TermsAgreementEntity>[];

  static List<Map<String, dynamic>> _termsAgreementSetToJson(
    List<TermsAgreementEntity> value,
  ) => value.map((e) => (e as TermsAgreementModel).toJson()).toList();
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TermsAgreementModel extends TermsAgreementEntity {
  const TermsAgreementModel({
    @JsonKey(defaultValue: '') required super.entityId,
    @JsonKey(defaultValue: false) required super.agreed,
    @JsonKey(defaultValue: 0) required super.agreedVersion,
    @JsonKey(fromJson: _nullableDateTimeFromJson) super.agreedAt,
    required super.terms,
  });

  factory TermsAgreementModel.fromJson(Map<String, dynamic> json) =>
      _$TermsAgreementModelFromJson(json);

  Map<String, dynamic> toJson() => _$TermsAgreementModelToJson(this);

  @override
  @JsonKey(fromJson: _termsFromJson, toJson: _termsToJson)
  TermsEntity get terms => super.terms;

  static DateTime? _nullableDateTimeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.parse(value as String);
  }

  static TermsEntity _termsFromJson(Map<String, dynamic> value) =>
      TermsModel.fromJson(value);

  static Map<String, dynamic> _termsToJson(TermsEntity value) =>
      (value as TermsModel).toJson();
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TermsModel extends TermsEntity {
  const TermsModel({
    @JsonKey(defaultValue: '') required super.entityId,
    @JsonKey(defaultValue: '') required super.termsType,
    @JsonKey(fromJson: _institutionFromJson, toJson: _institutionToJson)
    super.institution,
    required super.termsUrls,
  });

  factory TermsModel.fromJson(Map<String, dynamic> json) =>
      _$TermsModelFromJson(json);

  Map<String, dynamic> toJson() => _$TermsModelToJson(this);

  @override
  @JsonKey(fromJson: _institutionFromJson, toJson: _institutionToJson)
  InstitutionEntity? get institution => super.institution;

  @override
  @JsonKey(
    name: 'terms_urls',
    fromJson: _termsUrlsFromJson,
    toJson: _termsUrlsToJson,
  )
  List<TermsUrlEntity> get termsUrls => super.termsUrls;

  static InstitutionEntity? _institutionFromJson(Map<String, dynamic>? json) =>
      json == null ? null : InstitutionModel.fromJson(json);

  static Map<String, dynamic>? _institutionToJson(
    InstitutionEntity? institution,
  ) => institution == null ? null : (institution as InstitutionModel).toJson();

  static List<TermsUrlEntity> _termsUrlsFromJson(List<dynamic>? value) =>
      value
          ?.map((e) => TermsUrlModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      <TermsUrlEntity>[];

  static List<Map<String, dynamic>> _termsUrlsToJson(
    List<TermsUrlEntity> value,
  ) => value.map((e) => (e as TermsUrlModel).toJson()).toList();
}

@JsonSerializable(fieldRename: FieldRename.snake)
class InstitutionModel extends InstitutionEntity {
  const InstitutionModel({
    @JsonKey(defaultValue: '') required super.nameDutch,
    @JsonKey(defaultValue: '') required super.nameEnglish,
    @JsonKey(defaultValue: '') required super.imageDutch,
    @JsonKey(defaultValue: '') required super.imageEnglish,
    @JsonKey(defaultValue: '') required super.identifier,
    @JsonKey(defaultValue: '') required super.alternativeIdentifier,
    @JsonKey(name: 'grondslag_formeel', defaultValue: '')
    required super.legalBasisFormal,
    @JsonKey(name: 'grondslag_informeel', defaultValue: '')
    required super.legalBasisInformal,
  });

  factory InstitutionModel.fromJson(Map<String, dynamic> json) =>
      _$InstitutionModelFromJson(json);

  Map<String, dynamic> toJson() => _$InstitutionModelToJson(this);
}

@JsonSerializable()
class TermsUrlModel extends TermsUrlEntity {
  const TermsUrlModel({
    @JsonKey(defaultValue: '') required super.url,
    @JsonKey(defaultValue: '') required super.language,
    @JsonKey(defaultValue: false) required super.excerpt,
  });

  factory TermsUrlModel.fromJson(Map<String, dynamic> json) =>
      _$TermsUrlModelFromJson(json);

  Map<String, dynamic> toJson() => _$TermsUrlModelToJson(this);
}
