// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collections_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectionsModel _$CollectionsModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CollectionsModel',
      json,
      ($checkedConvert) {
        final val = CollectionsModel(
          id: $checkedConvert(
            'id',
            (v) => CollectionsModel._stringFromDynamic(v),
          ),
          entityId: $checkedConvert(
            'entity_id',
            (v) => CollectionsModel._stringFromDynamic(v),
          ),
          name: $checkedConvert('name', (v) => v as String),
          description: $checkedConvert('description', (v) => v as String?),
          badgeInstanceIds: $checkedConvert(
            'badge_instances',
            (v) => CollectionsModel._badgeInstanceIdsFromJson(v as List?),
          ),
          public: $checkedConvert('public', (v) => v as bool? ?? false),
        );
        return val;
      },
      fieldKeyMap: const {
        'entityId': 'entity_id',
        'badgeInstanceIds': 'badge_instances',
      },
    );

Map<String, dynamic> _$CollectionsModelToJson(CollectionsModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': ?instance.description,
      'public': instance.public,
      'id': instance.id,
      'badge_instances': instance.badgeInstanceIds,
    };
