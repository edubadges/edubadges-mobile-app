// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_institution_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatalogInstitutionModel _$CatalogInstitutionModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CatalogInstitutionModel',
  json,
  ($checkedConvert) {
    final val = CatalogInstitutionModel(
      entityId: $checkedConvert('entity_id', (v) => v as String),
      nameDutch: $checkedConvert('name_dutch', (v) => v as String?),
      nameEnglish: $checkedConvert('name_english', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'entityId': 'entity_id',
    'nameDutch': 'name_dutch',
    'nameEnglish': 'name_english',
  },
);

Map<String, dynamic> _$CatalogInstitutionModelToJson(
  CatalogInstitutionModel instance,
) => <String, dynamic>{
  'entity_id': instance.entityId,
  'name_dutch': ?instance.nameDutch,
  'name_english': ?instance.nameEnglish,
};
