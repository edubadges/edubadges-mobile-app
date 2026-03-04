import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/account/data/datasources/account_datasource.dart';
import 'package:edubadges/features/account/data/datasources/account_remote_datasource.dart';
import 'package:edubadges/features/account/data/repositories/account_repository_impl.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/account/domain/repositories/account_repository.dart';
import 'package:edubadges/shared/presentation/providers/device_registration_providers.dart';
import 'package:edubadges/shared/presentation/providers/permission_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final accountRemoteDataSourceProvider = Provider<AccountRemoteDataSourceImpl>((
  ref,
) {
  final client = ref.watch(apiClientProvider);
  return AccountRemoteDataSourceImpl(client);
});

final accountDataSourceProvider = Provider<AccountDataSource>((ref) {
  return ref.watch(accountRemoteDataSourceProvider);
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final dataSource = ref.watch(accountDataSourceProvider);
  return AccountRepositoryImpl(dataSource);
});

final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfileEntity?>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<ProfileEntity?> {
  @override
  Future<ProfileEntity?> build() async {
    final accountRepository = ref.read(accountRepositoryProvider);
    final result = await accountRepository.getProfile();
    return result.fold((failure) => throw failure, (profile) => profile);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final accountRepository = ref.read(accountRepositoryProvider);
    final result = await accountRepository.getProfile();
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (profile) => AsyncData(profile),
    );
  }
}

/// Notification enabled state derived from OS permission
/// TODO: Replace with loading from the backend and OS once there is a way to get the backend status
final notificationEnabledProvider =
    AsyncNotifierProvider<NotificationEnabledNotifier, bool>(
  NotificationEnabledNotifier.new,
);

class NotificationEnabledNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final status = await ref.read(notificationPermissionStatusProvider.future);
    return status == PermissionStatus.granted;
  }

  /// Updates the toggle and sends the new [active] value to the backend.
  Future<void> setEnabled(bool enabled) async {
    await ref.read(deviceRegistrationServiceProvider).registerDevice(active: enabled);
    state = AsyncData(enabled);
  }
}
