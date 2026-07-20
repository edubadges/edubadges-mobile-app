// ignore_for_file: avoid_positional_boolean_parameters

import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/account/data/datasources/account_datasource.dart';
import 'package:edubadges/features/account/data/datasources/account_remote_datasource.dart';
import 'package:edubadges/features/account/data/repositories/account_repository_impl.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/account/domain/repositories/account_repository.dart';
import 'package:edubadges/shared/presentation/providers/device_registration_providers.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> refresh({bool silent = true}) async {
    if (!silent) {
      state = const AsyncLoading();
    }
    final accountRepository = ref.read(accountRepositoryProvider);
    final result = await accountRepository.getProfile();
    result.fold((failure) {
      if (!silent || !state.hasValue) {
        state = AsyncError(failure, StackTrace.current);
      }
    }, (profile) {
      state = AsyncData(profile);
    });
  }
}

class NotificationPermissionDeniedException implements Exception {}

final notificationEnabledProvider =
    AsyncNotifierProvider<NotificationEnabledNotifier, bool>(
      NotificationEnabledNotifier.new,
    );

class NotificationEnabledNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    if (kIsWeb) {
      return false;
    }
    final active = await ref
        .read(deviceRegistrationServiceProvider)
        .getNotificationActive();
    if (active != null) return active;
    return false;
  }

  /// Updates the toggle and sends the new [active] value to the backend.
  Future<void> setEnabled(bool enabled) async {
    if (kIsWeb) {
      return;
    }
    final PermissionStatus notification = await Permission.notification.request();

    if (notification == PermissionStatus.granted ||
        notification == PermissionStatus.limited) {
      await ref
          .read(deviceRegistrationServiceProvider)
          .registerDevice(active: enabled);
      state = AsyncData(enabled);
    } else {
      throw NotificationPermissionDeniedException();
    }
  }

  Future<void> refresh({bool silent = true}) async {
    if (!silent) {
      state = const AsyncLoading();
    }
    try {
      final active = await ref
          .read(deviceRegistrationServiceProvider)
          .getNotificationActive();
      state = AsyncData(active ?? false);
    } catch (error, stackTrace) {
      if (!silent || !state.hasValue) {
        state = AsyncError(error, stackTrace);
      }
    }
  }
}
