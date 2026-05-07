// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_class_extension_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BadgeClassExtensionModel _$BadgeClassExtensionModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('BadgeClassExtensionModel', json, ($checkedConvert) {
  final val = BadgeClassExtensionModel(
    name: $checkedConvert('name', (v) => v as String),
    value: $checkedConvert('value', (v) => v),
  );
  return val;
});

Map<String, dynamic> _$BadgeClassExtensionModelToJson(
  BadgeClassExtensionModel instance,
) => <String, dynamic>{'name': instance.name, 'value': ?instance.value};
