// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issuer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IssuerModel _$IssuerModelFromJson(Map<String, dynamic> json) => $checkedCreate(
  'IssuerModel',
  json,
  ($checkedConvert) {
    final val = IssuerModel(
      nameDutch: $checkedConvert('name_dutch', (v) => v as String?),
      nameEnglish: $checkedConvert('name_english', (v) => v as String?),
      imageDutch: $checkedConvert('image_dutch', (v) => v as String?),
      imageEnglish: $checkedConvert('image_english', (v) => v as String?),
      faculty: $checkedConvert(
        'faculty',
        (v) => IssuerModel._facultyFromJson(v as Map<String, dynamic>?),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'nameDutch': 'name_dutch',
    'nameEnglish': 'name_english',
    'imageDutch': 'image_dutch',
    'imageEnglish': 'image_english',
  },
);

Map<String, dynamic> _$IssuerModelToJson(IssuerModel instance) =>
    <String, dynamic>{
      'name_dutch': ?instance.nameDutch,
      'name_english': ?instance.nameEnglish,
      'image_dutch': ?instance.imageDutch,
      'image_english': ?instance.imageEnglish,
      'faculty': ?IssuerModel._facultyToJson(instance.faculty),
    };
