import 'package:device_info_plus/device_info_plus.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/core/utils/platform_info.dart';
import 'package:edubadges/shared/data/datasources/device_registration_datasource.dart';
import 'package:edubadges/shared/data/models/register_device_request.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceRegistrationService {
  DeviceRegistrationService(this._dataSource);

  final DeviceRegistrationDataSource _dataSource;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Fetches the current device registration from the backend and returns the [active] flag.
  /// Returns null if the device is not registered or the request fails.
  Future<bool?> getNotificationActive() async {
    if (PlatformInfo.isWeb) {
      return null;
    }
    final String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null || fcmToken.isEmpty) return null;
    try {
      final device = await _dataSource.getDeviceRegistration(fcmToken);
      return device?.active;
    } catch (e, st) {
      logger.w('Failed to get device registration', error: e, stackTrace: st);
      return null;
    }
  }

  /// Fetches FCM token and device info, then POSTs to the backend.
  /// [active] is sent in the request body so the backend can enable or disable push for this device.
  Future<void> registerDevice({bool active = true}) async {
    if (PlatformInfo.isWeb) {
      return;
    }
    final String? fcmToken =
        await FirebaseMessaging.instance.getToken();
    if (fcmToken == null || fcmToken.isEmpty) {
      return;
    }

    final String type = PlatformInfo.isIOS ? 'ios' : 'android';
    String name;
    String? deviceId;

    try {
      if (PlatformInfo.isIOS) {
        final info = await _deviceInfo.iosInfo;
        deviceId = info.identifierForVendor;
        name = info.name.isNotEmpty ? info.name : info.modelName;
      } else {
        final info = await _deviceInfo.androidInfo;
        deviceId = info.fingerprint;
        name = info.name.isNotEmpty ? info.name : '${info.brand} ${info.model}';
      }
    } catch (e, st) {
      logger.w('Failed to get device info for registration', error: e, stackTrace: st);
      return;
    }

    if (deviceId == null || deviceId.isEmpty) {
      logger.w('Skipping device registration: device_id not available (e.g. iOS simulator)');
      return;
    }

    try {
      await _dataSource.registerDevice(
        RegisterDeviceRequest(
          registrationId: fcmToken,
          type: type,
          name: name,
          deviceId: deviceId,
          active: active,
        ),
      );
    } catch (e, st) {
      logger.w('Device registration failed', error: e, stackTrace: st);
    }
  }
}
