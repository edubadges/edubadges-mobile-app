import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/features/login/data/datasources/auto_login_suppression_storage.dart';
import 'package:edubadges/features/login/domain/repositories/login_repository.dart';
import 'package:edubadges/features/login/domain/web_auto_login.dart';
import 'package:edubadges/features/login/presentation/providers/auto_login_providers.dart';
import 'package:edubadges/features/login/presentation/providers/login_providers.dart';
import 'package:edubadges/shared/data/datasources/notification_permission_local_datasource.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the tab's `sessionStorage`, which outlives a container just
/// like it outlives a page reload.
class _FakeSuppressionStorage implements AutoLoginSuppressionStorage {
  AutoLoginSuppression? stored;

  @override
  AutoLoginSuppression? read() => stored;

  @override
  void write(AutoLoginSuppression reason) => stored = reason;

  @override
  void clear() => stored = null;
}

class _FakeLoginRepository implements LoginRepository {
  bool loggedIn = true;

  @override
  Future<Either<Failure, bool>> isLoggedIn() async => Right(loggedIn);

  @override
  Future<Either<Failure, void>> login({bool replaceHistory = false}) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> logout() async {
    loggedIn = false;
    return const Right(null);
  }
}

class _FakeNotificationPermissionLocalDataSource
    implements NotificationPermissionLocalDataSource {
  @override
  Future<void> clearDeclinedPrompt() async {}

  @override
  Future<bool> hasDeclinedPrompt() async => false;

  @override
  Future<void> setDeclinedPrompt() async {}
}

void main() {
  late _FakeSuppressionStorage storage;

  ProviderContainer createContainer({List<Override> overrides = const []}) {
    final container = ProviderContainer(
      overrides: [
        autoLoginSuppressionStorageProvider.overrideWithValue(storage),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    storage = _FakeSuppressionStorage();
  });

  group('autoLoginSuppressionProvider', () {
    test('starts without suppression', () {
      final container = createContainer();

      expect(container.read(autoLoginSuppressionProvider), isNull);
    });

    test('a failed return from eduID suppresses the next automatic login', () {
      final container = createContainer();

      container
          .read(autoLoginSuppressionProvider.notifier)
          .recordLoginRedirect(succeeded: false);

      expect(
        container.read(autoLoginSuppressionProvider),
        AutoLoginSuppression.loginFailed,
      );
      expect(storage.stored, AutoLoginSuppression.loginFailed);
    });

    test('a successful return from eduID clears the suppression', () {
      storage.stored = AutoLoginSuppression.loggedOut;
      final container = createContainer();

      container
          .read(autoLoginSuppressionProvider.notifier)
          .recordLoginRedirect(succeeded: true);

      expect(container.read(autoLoginSuppressionProvider), isNull);
      expect(storage.stored, isNull);
    });

    test('survives a reload of the tab', () {
      createContainer()
          .read(autoLoginSuppressionProvider.notifier)
          .suppress(AutoLoginSuppression.loggedOut);

      final reloaded = createContainer();

      expect(
        reloaded.read(autoLoginSuppressionProvider),
        AutoLoginSuppression.loggedOut,
      );
    });

    test('clear lifts the suppression, also after a reload', () {
      storage.stored = AutoLoginSuppression.loginFailed;

      createContainer().read(autoLoginSuppressionProvider.notifier).clear();

      expect(createContainer().read(autoLoginSuppressionProvider), isNull);
    });
  });

  group('logout', () {
    test('keeps the web login page from logging the user back in', () async {
      final container = createContainer(
        overrides: [
          loginRepositoryProvider.overrideWithValue(_FakeLoginRepository()),
          notificationPermissionLocalDataSourceProvider.overrideWithValue(
            _FakeNotificationPermissionLocalDataSource(),
          ),
        ],
      );
      expect(await container.read(authProvider.future), isTrue);

      await container.read(authProvider.notifier).logout();

      expect(container.read(authProvider).asData?.value, isFalse);
      expect(
        container.read(autoLoginSuppressionProvider),
        AutoLoginSuppression.loggedOut,
      );
      expect(storage.stored, AutoLoginSuppression.loggedOut);
      expect(
        resolveLoginEntryMode(
          autoLoginSupported: true,
          auth: container.read(authProvider),
          suppression: container.read(autoLoginSuppressionProvider),
        ),
        LoginEntryMode.landing,
      );
    });
  });
}
