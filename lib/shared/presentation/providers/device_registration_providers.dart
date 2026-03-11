import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/shared/data/datasources/device_registration_datasource.dart';
import 'package:edubadges/shared/data/services/device_registration_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceRegistrationDataSourceProvider =
    Provider<DeviceRegistrationDataSource>((ref) {
  final client = ref.read(apiClientProvider);
  return DeviceRegistrationDataSourceImpl(client);
});

final deviceRegistrationServiceProvider = Provider<DeviceRegistrationService>((ref) {
  final dataSource = ref.read(deviceRegistrationDataSourceProvider);
  return DeviceRegistrationService(dataSource);
});
