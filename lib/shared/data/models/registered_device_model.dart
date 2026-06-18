import 'package:json_annotation/json_annotation.dart';

part 'registered_device_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RegisteredDeviceModel {
  final int id;
  final String name;
  final String registrationId;
  final String deviceId;
  final bool active;
  final String dateCreated;
  final String type;

  const RegisteredDeviceModel({
    required this.id,
    required this.name,
    required this.registrationId,
    required this.deviceId,
    required this.active,
    required this.dateCreated,
    required this.type,
  });

  factory RegisteredDeviceModel.fromJson(Map<String, dynamic> json) =>
      _$RegisteredDeviceModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisteredDeviceModelToJson(this);
}
