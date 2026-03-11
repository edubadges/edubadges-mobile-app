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

  Map<String, dynamic> toJson() {
    return {
      'registration_id': registrationId,
      'type': type,
      'name': name,
      'device_id': deviceId,
      'active': active,
    };
  }
}
