// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_details_route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BadgeDetailsRouteModel _$BadgeDetailsRouteModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('BadgeDetailsRouteModel', json, ($checkedConvert) {
  final val = BadgeDetailsRouteModel(
    id: $checkedConvert('id', (v) => v as String),
    scope: $checkedConvert(
      'scope',
      (v) => BadgeDetailsRouteModel._scopeFromJson(v as String),
    ),
    showClaimedGallery: $checkedConvert(
      'showClaimedGallery',
      (v) => v as bool? ?? false,
    ),
  );
  return val;
});

Map<String, dynamic> _$BadgeDetailsRouteModelToJson(
  BadgeDetailsRouteModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'scope': BadgeDetailsRouteModel._scopeToJson(instance.scope),
  'showClaimedGallery': instance.showClaimedGallery,
};
