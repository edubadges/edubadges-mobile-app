import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/login/domain/repositories/login_repository.dart';
import 'package:edubadges/features/login/presentation/providers/login_providers.dart';
import 'package:edubadges/shared/data/datasources/notification_permission_local_datasource.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLoginRepository implements LoginRepository {
  _FakeLoginRepository({required this.loggedIn, this.onIsLoggedIn});

  bool loggedIn;

  /// Runs while the session is being checked, like a token refresh would.
  final void Function()? onIsLoggedIn;

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    onIsLoggedIn?.call();
    return Right(loggedIn);
  }

  @override
  Future<Either<Failure, void>> login({bool replaceHistory = false}) async {
    loggedIn = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    loggedIn = false;
    return const Right(null);
  }
}

class _FakeNotificationPermissionLocalDataSource
    implements NotificationPermissionLocalDataSource {
  _FakeNotificationPermissionLocalDataSource({this.failToClear = false});

  /// Makes clearing fail, as a storage error would.
  final bool failToClear;

  @override
  Future<void> clearDeclinedPrompt() async {
    if (failToClear) {
      throw Exception('storage unavailable');
    }
  }

  @override
  Future<bool> hasDeclinedPrompt() async => false;

  @override
  Future<void> setDeclinedPrompt() async {}
}

/// Lets the notifier's async listener and state updates run.
Future<void> _settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late StreamController<void> sessionExpired;

  ProviderContainer createContainer(
    _FakeLoginRepository repository, {
    bool failToClearLocalState = false,
  }) {
    final container = ProviderContainer(
      overrides: [
        loginRepositoryProvider.overrideWithValue(repository),
        sessionExpiredEventsProvider.overrideWithValue(sessionExpired.stream),
        notificationPermissionLocalDataSourceProvider.overrideWithValue(
          _FakeNotificationPermissionLocalDataSource(
            failToClear: failToClearLocalState,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    sessionExpired = StreamController<void>.broadcast();
    addTearDown(sessionExpired.close);
  });

  test('returns to the login screen when the session expires', () async {
    final container = createContainer(_FakeLoginRepository(loggedIn: true));
    expect(await container.read(authProvider.future), isTrue);

    sessionExpired.add(null);
    await _settle();

    expect(container.read(authProvider).value, isFalse);
    expect(container.read(sessionExpiredNoticeProvider), isTrue);
  });

  test(
    'still returns to the login screen when clearing local state fails',
    () async {
      final container = createContainer(
        _FakeLoginRepository(loggedIn: true),
        failToClearLocalState: true,
      );
      expect(await container.read(authProvider.future), isTrue);

      sessionExpired.add(null);
      await _settle();

      expect(container.read(authProvider).value, isFalse);
      expect(container.read(sessionExpiredNoticeProvider), isTrue);
    },
  );

  test('explains an expired session found while starting up', () async {
    final container = createContainer(
      _FakeLoginRepository(
        loggedIn: false,
        onIsLoggedIn: () => sessionExpired.add(null),
      ),
    );

    expect(await container.read(authProvider.future), isFalse);
    await _settle();

    expect(container.read(authProvider).value, isFalse);
    expect(container.read(sessionExpiredNoticeProvider), isTrue);
  });

  test('does not claim the session expired after a normal logout', () async {
    final container = createContainer(_FakeLoginRepository(loggedIn: true));
    await container.read(authProvider.future);

    await container.read(authProvider.notifier).logout();
    await _settle();

    expect(container.read(authProvider).value, isFalse);
    expect(container.read(sessionExpiredNoticeProvider), isFalse);
  });

  test('logging in again clears the notice', () async {
    final container = createContainer(_FakeLoginRepository(loggedIn: true));
    await container.read(authProvider.future);
    sessionExpired.add(null);
    await _settle();

    expect(await container.read(authProvider.notifier).login(), isTrue);

    expect(container.read(authProvider).value, isTrue);
    expect(container.read(sessionExpiredNoticeProvider), isFalse);
  });
}
