import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/shared/data/models/register_device_request.dart';
import 'package:edubadges/shared/data/models/registered_device_model.dart';

abstract class DeviceRegistrationDataSource {
  Future<void> registerDevice(RegisterDeviceRequest request);
  Future<RegisteredDeviceModel?> getDeviceRegistration(String registrationId);
}

class DeviceRegistrationDataSourceImpl implements DeviceRegistrationDataSource {
  final ApiClient apiClient;

  DeviceRegistrationDataSourceImpl(this.apiClient);

  static const String _devicesPath = '/register-devices';

  @override
  Future<void> registerDevice(RegisterDeviceRequest request) async {
    await apiClient.post<void>(
      _devicesPath,
      data: request.toJson(),
    );
  }

  @override
  Future<RegisteredDeviceModel?> getDeviceRegistration(String registrationId) async {
    final encodedId = Uri.encodeComponent(registrationId);
    final response = await apiClient.get<Map<String, dynamic>>(
      '$_devicesPath/$encodedId',
    );
    final data = response.data;
    if (data == null) return null;
    return RegisteredDeviceModel.fromJson(data);
  }
}
