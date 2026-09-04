import 'package:edubadges/shared/data/datasources/notification_permission_local_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// A provider that asynchronously returns the current status of notification permissions.
final notificationPermissionStatusProvider =
    FutureProvider.autoDispose<PermissionStatus>((ref) async {
  return await Permission.notification.status;
});

final notificationPermissionPromptDeclinedProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final dataSource = ref.watch(notificationPermissionLocalDataSourceProvider);
  return dataSource.hasDeclinedPrompt();
});

final shouldShowNotificationPermissionPromptProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  if (kIsWeb) {
    return false;
  }
  final hasDeclined = await ref.watch(
    notificationPermissionPromptDeclinedProvider.future,
  );
  if (hasDeclined) {
    return false;
  }
  final status = await ref.watch(
    notificationPermissionStatusProvider.future,
  );
  return status == PermissionStatus.denied;
});
