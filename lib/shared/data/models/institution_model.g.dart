// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'institution_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstitutionModel _$InstitutionModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'InstitutionModel',
      json,
      ($checkedConvert) {
        final val = InstitutionModel(
          nameDutch: $checkedConvert('name_dutch', (v) => v as String?),
          nameEnglish: $checkedConvert('name_english', (v) => v as String?),
          imageDutch: $checkedConvert('image_dutch', (v) => v as String?),
          imageEnglish: $checkedConvert('image_english', (v) => v as String?),
          identifier: $checkedConvert('identifier', (v) => v as String?),
          alternativeIdentifier: $checkedConvert(
            'alternative_identifier',
            (v) => v as String?,
          ),
          grondslagFormeel: $checkedConvert(
            'grondslag_formeel',
            (v) => v as String?,
          ),
          grondslagInformeel: $checkedConvert(
            'grondslag_informeel',
            (v) => v as String?,
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
        'grondslagFormeel': 'grondslag_formeel',
        'grondslagInformeel': 'grondslag_informeel',
      },
    );

Map<String, dynamic> _$InstitutionModelToJson(InstitutionModel instance) =>
    <String, dynamic>{
      'name_dutch': ?instance.nameDutch,
      'name_english': ?instance.nameEnglish,
      'image_dutch': ?instance.imageDutch,
      'image_english': ?instance.imageEnglish,
      'identifier': ?instance.identifier,
      'alternative_identifier': ?instance.alternativeIdentifier,
      'grondslag_formeel': ?instance.grondslagFormeel,
      'grondslag_informeel': ?instance.grondslagInformeel,
    };
