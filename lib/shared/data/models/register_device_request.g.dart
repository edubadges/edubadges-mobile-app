// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_device_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterDeviceRequest _$RegisterDeviceRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'RegisterDeviceRequest',
  json,
  ($checkedConvert) {
    final val = RegisterDeviceRequest(
      registrationId: $checkedConvert('registration_id', (v) => v as String),
      type: $checkedConvert('type', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      deviceId: $checkedConvert('device_id', (v) => v as String),
      active: $checkedConvert('active', (v) => v as bool? ?? true),
    );
    return val;
  },
  fieldKeyMap: const {
    'registrationId': 'registration_id',
    'deviceId': 'device_id',
  },
);

Map<String, dynamic> _$RegisterDeviceRequestToJson(
  RegisterDeviceRequest instance,
) => <String, dynamic>{
  'registration_id': instance.registrationId,
  'type': instance.type,
  'name': instance.name,
  'device_id': instance.deviceId,
  'active': instance.active,
};
