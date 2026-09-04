// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_alignment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BadgeAlignmentModel _$BadgeAlignmentModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'BadgeAlignmentModel',
      json,
      ($checkedConvert) {
        final val = BadgeAlignmentModel(
          targetName: $checkedConvert('target_name', (v) => v as String?),
          targetUrl: $checkedConvert('target_url', (v) => v as String?),
          targetDescription: $checkedConvert(
            'target_description',
            (v) => v as String?,
          ),
          targetFramework: $checkedConvert(
            'target_framework',
            (v) => v as String?,
          ),
          targetCode: $checkedConvert('target_code', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'targetName': 'target_name',
        'targetUrl': 'target_url',
        'targetDescription': 'target_description',
        'targetFramework': 'target_framework',
        'targetCode': 'target_code',
      },
    );

Map<String, dynamic> _$BadgeAlignmentModelToJson(
  BadgeAlignmentModel instance,
) => <String, dynamic>{
  'target_name': ?instance.targetName,
  'target_url': ?instance.targetUrl,
  'target_description': ?instance.targetDescription,
  'target_framework': ?instance.targetFramework,
  'target_code': ?instance.targetCode,
};
