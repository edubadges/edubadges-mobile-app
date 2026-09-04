// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registered_device_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisteredDeviceModel _$RegisteredDeviceModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'RegisteredDeviceModel',
  json,
  ($checkedConvert) {
    final val = RegisteredDeviceModel(
      id: $checkedConvert('id', (v) => (v as num).toInt()),
      name: $checkedConvert('name', (v) => v as String),
      registrationId: $checkedConvert('registration_id', (v) => v as String),
      deviceId: $checkedConvert('device_id', (v) => v as String),
      active: $checkedConvert('active', (v) => v as bool),
      dateCreated: $checkedConvert('date_created', (v) => v as String),
      type: $checkedConvert('type', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'registrationId': 'registration_id',
    'deviceId': 'device_id',
    'dateCreated': 'date_created',
  },
);

Map<String, dynamic> _$RegisteredDeviceModelToJson(
  RegisteredDeviceModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'registration_id': instance.registrationId,
  'device_id': instance.deviceId,
  'active': instance.active,
  'date_created': instance.dateCreated,
  'type': instance.type,
};
