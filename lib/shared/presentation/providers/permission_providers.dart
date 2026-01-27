import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// A provider that asynchronously returns the current status of notification permissions.
final notificationPermissionStatusProvider = FutureProvider<PermissionStatus>((ref) async {
  return await Permission.notification.status;
});
