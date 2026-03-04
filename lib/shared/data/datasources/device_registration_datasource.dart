import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/shared/data/models/register_device_request.dart';

abstract class DeviceRegistrationDataSource {
  Future<void> registerDevice(RegisterDeviceRequest request);
}

class DeviceRegistrationDataSourceImpl implements DeviceRegistrationDataSource {
  final ApiClient apiClient;

  DeviceRegistrationDataSourceImpl(this.apiClient);

  static const String _path = '/register-device';

  @override
  Future<void> registerDevice(RegisterDeviceRequest request) async {
    await apiClient.post<void>(
      _path,
      data: request.toJson(),
    );
  }
}
