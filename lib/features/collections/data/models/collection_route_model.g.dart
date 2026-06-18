// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectionRouteModel _$CollectionRouteModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CollectionRouteModel', json, ($checkedConvert) {
  final val = CollectionRouteModel(
    id: $checkedConvert('id', (v) => v as String),
    title: $checkedConvert('title', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$CollectionRouteModelToJson(
  CollectionRouteModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': ?instance.description,
};
