// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ProfileModel',
  json,
  ($checkedConvert) {
    final val = ProfileModel(
      firstName: $checkedConvert('first_name', (v) => v as String? ?? ''),
      lastName: $checkedConvert('last_name', (v) => v as String? ?? ''),
      email: $checkedConvert('email', (v) => v as String? ?? ''),
      entityId: $checkedConvert('entity_id', (v) => v as String? ?? ''),
      marketingOptIn: $checkedConvert(
        'marketing_opt_in',
        (v) => v as bool? ?? false,
      ),
      institution: $checkedConvert('institution', (v) => v as String?),
      isSuperuser: $checkedConvert('is_superuser', (v) => v as bool? ?? false),
      termsAgreed: $checkedConvert('terms_agreed', (v) => v as bool? ?? false),
      termsagreementSet: $checkedConvert(
        'termsagreement_set',
        (v) => ProfileModel._termsAgreementSetFromJson(v as List?),
      ),
      dateJoined: $checkedConvert(
        'date_joined',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'firstName': 'first_name',
    'lastName': 'last_name',
    'entityId': 'entity_id',
    'marketingOptIn': 'marketing_opt_in',
    'isSuperuser': 'is_superuser',
    'termsAgreed': 'terms_agreed',
    'termsagreementSet': 'termsagreement_set',
    'dateJoined': 'date_joined',
  },
);

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'entity_id': instance.entityId,
      'marketing_opt_in': instance.marketingOptIn,
      'institution': ?instance.institution,
      'is_superuser': instance.isSuperuser,
      'terms_agreed': instance.termsAgreed,
      'date_joined': instance.dateJoined.toIso8601String(),
      'termsagreement_set': ProfileModel._termsAgreementSetToJson(
        instance.termsagreementSet,
      ),
    };

TermsAgreementModel _$TermsAgreementModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'TermsAgreementModel',
      json,
      ($checkedConvert) {
        final val = TermsAgreementModel(
          entityId: $checkedConvert('entity_id', (v) => v as String? ?? ''),
          agreed: $checkedConvert('agreed', (v) => v as bool? ?? false),
          agreedVersion: $checkedConvert(
            'agreed_version',
            (v) => (v as num?)?.toInt() ?? 0,
          ),
          agreedAt: $checkedConvert(
            'agreed_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          terms: $checkedConvert(
            'terms',
            (v) =>
                TermsAgreementModel._termsFromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'entityId': 'entity_id',
        'agreedVersion': 'agreed_version',
        'agreedAt': 'agreed_at',
      },
    );

Map<String, dynamic> _$TermsAgreementModelToJson(
  TermsAgreementModel instance,
) => <String, dynamic>{
  'entity_id': instance.entityId,
  'agreed': instance.agreed,
  'agreed_version': instance.agreedVersion,
  'agreed_at': ?instance.agreedAt?.toIso8601String(),
  'terms': TermsAgreementModel._termsToJson(instance.terms),
};

TermsModel _$TermsModelFromJson(Map<String, dynamic> json) => $checkedCreate(
  'TermsModel',
  json,
  ($checkedConvert) {
    final val = TermsModel(
      entityId: $checkedConvert('entity_id', (v) => v as String? ?? ''),
      termsType: $checkedConvert('terms_type', (v) => v as String? ?? ''),
      institution: $checkedConvert(
        'institution',
        (v) => TermsModel._institutionFromJson(v as Map<String, dynamic>?),
      ),
      termsUrls: $checkedConvert(
        'terms_urls',
        (v) => TermsModel._termsUrlsFromJson(v as List?),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'entityId': 'entity_id',
    'termsType': 'terms_type',
    'termsUrls': 'terms_urls',
  },
);

Map<String, dynamic> _$TermsModelToJson(TermsModel instance) =>
    <String, dynamic>{
      'entity_id': instance.entityId,
      'terms_type': instance.termsType,
      'institution': ?TermsModel._institutionToJson(instance.institution),
      'terms_urls': TermsModel._termsUrlsToJson(instance.termsUrls),
    };

InstitutionModel _$InstitutionModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'InstitutionModel',
  json,
  ($checkedConvert) {
    final val = InstitutionModel(
      nameDutch: $checkedConvert('name_dutch', (v) => v as String? ?? ''),
      nameEnglish: $checkedConvert('name_english', (v) => v as String? ?? ''),
      imageDutch: $checkedConvert('image_dutch', (v) => v as String? ?? ''),
      imageEnglish: $checkedConvert('image_english', (v) => v as String? ?? ''),
      identifier: $checkedConvert('identifier', (v) => v as String? ?? ''),
      alternativeIdentifier: $checkedConvert(
        'alternative_identifier',
        (v) => v as String? ?? '',
      ),
      legalBasisFormal: $checkedConvert(
        'grondslag_formeel',
        (v) => v as String? ?? '',
      ),
      legalBasisInformal: $checkedConvert(
        'grondslag_informeel',
        (v) => v as String? ?? '',
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'nameDutch': 'name_dutch',
    'nameEnglish': 'name_english',
    'imageDutch': 'image_dutch',
    'imageEnglish': 'image_english',
    'alternativeIdentifier': 'alternative_identifier',
    'legalBasisFormal': 'grondslag_formeel',
    'legalBasisInformal': 'grondslag_informeel',
  },
);

Map<String, dynamic> _$InstitutionModelToJson(InstitutionModel instance) =>
    <String, dynamic>{
      'name_dutch': instance.nameDutch,
      'name_english': instance.nameEnglish,
      'image_dutch': instance.imageDutch,
      'image_english': instance.imageEnglish,
      'identifier': instance.identifier,
      'alternative_identifier': instance.alternativeIdentifier,
      'grondslag_formeel': instance.legalBasisFormal,
      'grondslag_informeel': instance.legalBasisInformal,
    };

TermsUrlModel _$TermsUrlModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TermsUrlModel', json, ($checkedConvert) {
      final val = TermsUrlModel(
        url: $checkedConvert('url', (v) => v as String? ?? ''),
        language: $checkedConvert('language', (v) => v as String? ?? ''),
        excerpt: $checkedConvert('excerpt', (v) => v as bool? ?? false),
      );
      return val;
    });

Map<String, dynamic> _$TermsUrlModelToJson(TermsUrlModel instance) =>
    <String, dynamic>{
      'url': instance.url,
      'language': instance.language,
      'excerpt': instance.excerpt,
    };
