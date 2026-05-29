import 'package:edubadges/core/storage/storage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class NotificationPermissionLocalDataSource {
  Future<bool> hasDeclinedPrompt();
  Future<void> setDeclinedPrompt();
  Future<void> clearDeclinedPrompt();
}

class NotificationPermissionLocalDataSourceImpl
    implements NotificationPermissionLocalDataSource {
  NotificationPermissionLocalDataSourceImpl(this.ref);

  final Ref ref;

  static const String _keyDeclined =
      'notification_permission_prompt_declined';

  @override
  Future<bool> hasDeclinedPrompt() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    return prefs.getBool(_keyDeclined) ?? false;
  }

  @override
  Future<void> setDeclinedPrompt() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(_keyDeclined, true);
  }

  @override
  Future<void> clearDeclinedPrompt() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.remove(_keyDeclined);
  }
}

final notificationPermissionLocalDataSourceProvider =
    Provider<NotificationPermissionLocalDataSource>((ref) {
  return NotificationPermissionLocalDataSourceImpl(ref);
});
