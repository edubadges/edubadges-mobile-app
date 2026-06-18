import 'package:json_annotation/json_annotation.dart';

part 'register_device_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RegisterDeviceRequest {
  final String registrationId;
  final String type;
  final String name;
  final String deviceId;
  final bool active;

  const RegisterDeviceRequest({
    required this.registrationId,
    required this.type,
    required this.name,
    required this.deviceId,
    this.active = true,
  });

  factory RegisterDeviceRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterDeviceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterDeviceRequestToJson(this);
}
