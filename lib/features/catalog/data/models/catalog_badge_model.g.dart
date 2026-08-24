// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_badge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatalogBadgeModel _$CatalogBadgeModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CatalogBadgeModel',
  json,
  ($checkedConvert) {
    final val = CatalogBadgeModel(
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
      name: $checkedConvert('name', (v) => v as String),
      image: $checkedConvert('image', (v) => v as String?),
      archived: $checkedConvert('archived', (v) => v as bool),
      entityId: $checkedConvert('entity_id', (v) => v as String),
      isPrivate: $checkedConvert('is_private', (v) => v as bool),
      isMicroCredentials: $checkedConvert(
        'is_micro_credentials',
        (v) => v as bool,
      ),
      badgeClassType: $checkedConvert(
        'badge_class_type',
        (v) => CatalogBadgeModel._badgeClassTypeFromJson(v as String?),
      ),
      issuerNameEnglish: $checkedConvert(
        'issuer_name_english',
        (v) => v as String?,
      ),
      issuerNameDutch: $checkedConvert(
        'issuer_name_dutch',
        (v) => v as String?,
      ),
      issuerEntityId: $checkedConvert('issuer_entity_id', (v) => v as String),
      issuerImageDutch: $checkedConvert(
        'issuer_image_dutch',
        (v) => v as String?,
      ),
      issuerImageEnglish: $checkedConvert(
        'issuer_image_english',
        (v) => v as String?,
      ),
      facultyNameEnglish: $checkedConvert(
        'faculty_name_english',
        (v) => v as String?,
      ),
      facultyNameDutch: $checkedConvert(
        'faculty_name_dutch',
        (v) => v as String?,
      ),
      facultyEntityId: $checkedConvert('faculty_entity_id', (v) => v as String),
      facultyImageDutch: $checkedConvert(
        'faculty_image_dutch',
        (v) => v as String?,
      ),
      facultyImageEnglish: $checkedConvert(
        'faculty_image_english',
        (v) => v as String?,
      ),
      facultyOnBehalfOf: $checkedConvert(
        'faculty_on_behalf_of',
        (v) => v as bool,
      ),
      facultyType: $checkedConvert('faculty_type', (v) => v as String?),
      institutionNameEnglish: $checkedConvert(
        'institution_name_english',
        (v) => v as String?,
      ),
      institutionNameDutch: $checkedConvert(
        'institution_name_dutch',
        (v) => v as String?,
      ),
      institutionEntityId: $checkedConvert(
        'institution_entity_id',
        (v) => v as String,
      ),
      institutionImageDutch: $checkedConvert(
        'institution_image_dutch',
        (v) => v as String?,
      ),
      institutionImageEnglish: $checkedConvert(
        'institution_image_english',
        (v) => v as String?,
      ),
      institutionType: $checkedConvert('institution_type', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'createdAt': 'created_at',
    'entityId': 'entity_id',
    'isPrivate': 'is_private',
    'isMicroCredentials': 'is_micro_credentials',
    'badgeClassType': 'badge_class_type',
    'issuerNameEnglish': 'issuer_name_english',
    'issuerNameDutch': 'issuer_name_dutch',
    'issuerEntityId': 'issuer_entity_id',
    'issuerImageDutch': 'issuer_image_dutch',
    'issuerImageEnglish': 'issuer_image_english',
    'facultyNameEnglish': 'faculty_name_english',
    'facultyNameDutch': 'faculty_name_dutch',
    'facultyEntityId': 'faculty_entity_id',
    'facultyImageDutch': 'faculty_image_dutch',
    'facultyImageEnglish': 'faculty_image_english',
    'facultyOnBehalfOf': 'faculty_on_behalf_of',
    'facultyType': 'faculty_type',
    'institutionNameEnglish': 'institution_name_english',
    'institutionNameDutch': 'institution_name_dutch',
    'institutionEntityId': 'institution_entity_id',
    'institutionImageDutch': 'institution_image_dutch',
    'institutionImageEnglish': 'institution_image_english',
    'institutionType': 'institution_type',
  },
);

Map<String, dynamic> _$CatalogBadgeModelToJson(CatalogBadgeModel instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt.toIso8601String(),
      'name': instance.name,
      'image': ?instance.image,
      'archived': instance.archived,
      'entity_id': instance.entityId,
      'is_private': instance.isPrivate,
      'is_micro_credentials': instance.isMicroCredentials,
      'issuer_name_english': ?instance.issuerNameEnglish,
      'issuer_name_dutch': ?instance.issuerNameDutch,
      'issuer_entity_id': instance.issuerEntityId,
      'issuer_image_dutch': ?instance.issuerImageDutch,
      'issuer_image_english': ?instance.issuerImageEnglish,
      'faculty_name_english': ?instance.facultyNameEnglish,
      'faculty_name_dutch': ?instance.facultyNameDutch,
      'faculty_entity_id': instance.facultyEntityId,
      'faculty_image_dutch': ?instance.facultyImageDutch,
      'faculty_image_english': ?instance.facultyImageEnglish,
      'faculty_on_behalf_of': instance.facultyOnBehalfOf,
      'faculty_type': ?instance.facultyType,
      'institution_name_english': ?instance.institutionNameEnglish,
      'institution_name_dutch': ?instance.institutionNameDutch,
      'institution_entity_id': instance.institutionEntityId,
      'institution_image_dutch': ?instance.institutionImageDutch,
      'institution_image_english': ?instance.institutionImageEnglish,
      'institution_type': ?instance.institutionType,
      'badge_class_type': CatalogBadgeModel._badgeClassTypeToJson(
        instance.badgeClassType,
      ),
    };
