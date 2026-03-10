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

  factory RegisteredDeviceModel.fromJson(Map<String, dynamic> json) {
    return RegisteredDeviceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      registrationId: json['registration_id'] as String,
      deviceId: json['device_id'] as String,
      active: json['active'] as bool,
      dateCreated: json['date_created'] as String,
      type: json['type'] as String,
    );
  }
}
