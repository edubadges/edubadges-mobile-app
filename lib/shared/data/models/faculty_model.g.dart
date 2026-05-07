// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faculty_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacultyModel _$FacultyModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'FacultyModel',
  json,
  ($checkedConvert) {
    final val = FacultyModel(
      nameDutch: $checkedConvert('name_dutch', (v) => v as String?),
      nameEnglish: $checkedConvert('name_english', (v) => v as String?),
      imageDutch: $checkedConvert('image_dutch', (v) => v as String?),
      imageEnglish: $checkedConvert('image_english', (v) => v as String?),
      onBehalfOf: $checkedConvert('on_behalf_of', (v) => v as bool? ?? false),
      onBehalfOfDisplayName: $checkedConvert(
        'on_behalf_of_display_name',
        (v) => v as String?,
      ),
      onBehalfOfUrl: $checkedConvert('on_behalf_of_url', (v) => v as String?),
      institution: $checkedConvert(
        'institution',
        (v) => FacultyModel._institutionFromJson(v as Map<String, dynamic>?),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'nameDutch': 'name_dutch',
    'nameEnglish': 'name_english',
    'imageDutch': 'image_dutch',
    'imageEnglish': 'image_english',
    'onBehalfOf': 'on_behalf_of',
    'onBehalfOfDisplayName': 'on_behalf_of_display_name',
    'onBehalfOfUrl': 'on_behalf_of_url',
  },
);

Map<String, dynamic> _$FacultyModelToJson(FacultyModel instance) =>
    <String, dynamic>{
      'name_dutch': ?instance.nameDutch,
      'name_english': ?instance.nameEnglish,
      'image_dutch': ?instance.imageDutch,
      'image_english': ?instance.imageEnglish,
      'on_behalf_of': instance.onBehalfOf,
      'on_behalf_of_display_name': ?instance.onBehalfOfDisplayName,
      'on_behalf_of_url': ?instance.onBehalfOfUrl,
      'institution': ?FacultyModel._institutionToJson(instance.institution),
    };
