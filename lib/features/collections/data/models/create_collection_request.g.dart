// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_collection_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCollectionRequest _$CreateCollectionRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateCollectionRequest',
  json,
  ($checkedConvert) {
    final val = CreateCollectionRequest(
      name: $checkedConvert('name', (v) => v as String),
      description: $checkedConvert('description', (v) => v as String?),
      public: $checkedConvert('public', (v) => v as bool),
      badgeInstances: $checkedConvert(
        'badge_instances',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'badgeInstances': 'badge_instances'},
);

Map<String, dynamic> _$CreateCollectionRequestToJson(
  CreateCollectionRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': ?CreateCollectionRequest._descriptionToJson(
    instance.description,
  ),
  'public': instance.public,
  'badge_instances': instance.badgeInstances,
};
