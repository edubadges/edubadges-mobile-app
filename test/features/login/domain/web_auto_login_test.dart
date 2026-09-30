import 'package:edubadges/features/login/domain/web_auto_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

LoginEntryMode _web(
  AsyncValue<bool> auth, {
  AutoLoginSuppression? suppression,
}) {
  return resolveLoginEntryMode(
    autoLoginSupported: true,
    auth: auth,
    suppression: suppression,
  );
}

LoginEntryMode _mobile(
  AsyncValue<bool> auth, {
  AutoLoginSuppression? suppression,
}) {
  return resolveLoginEntryMode(
    autoLoginSupported: false,
    auth: auth,
    suppression: suppression,
  );
}

void main() {
  const AsyncValue<bool> loggedOut = AsyncData(false);
  const AsyncValue<bool> loggedIn = AsyncData(true);
  const AsyncValue<bool> resolving = AsyncLoading();
  final AsyncValue<bool> failed = AsyncError(
    Exception('login failed'),
    StackTrace.empty,
  );

  group('web', () {
    test('a logged-out visitor goes straight to eduID', () {
      expect(_web(loggedOut), LoginEntryMode.startLogin);
    });

    test('waits for authentication instead of showing the landing page', () {
      expect(_web(resolving), LoginEntryMode.loading);
    });

    test('a logged-in visitor never starts a login', () {
      expect(_web(loggedIn), LoginEntryMode.loading);
      expect(
        _web(loggedIn, suppression: AutoLoginSuppression.loggedOut),
        LoginEntryMode.loading,
      );
    });

    test('after a cancelled or failed login shows the landing page with an '
        'error instead of retrying', () {
      expect(
        _web(loggedOut, suppression: AutoLoginSuppression.loginFailed),
        LoginEntryMode.landingWithError,
      );
      expect(
        _web(resolving, suppression: AutoLoginSuppression.loginFailed),
        LoginEntryMode.landingWithError,
      );
    });

    test('a login that fails before leaving the app does not loop', () {
      expect(_web(failed), LoginEntryMode.landingWithError);
    });

    test('after logout shows the landing page without an error', () {
      expect(
        _web(loggedOut, suppression: AutoLoginSuppression.loggedOut),
        LoginEntryMode.landing,
      );
      expect(
        _web(resolving, suppression: AutoLoginSuppression.loggedOut),
        LoginEntryMode.landing,
      );
    });

    test('shows a loader while the login the user asked for starts', () {
      // Clicking the button clears the suppression and puts auth in loading.
      expect(_web(resolving), LoginEntryMode.loading);
    });
  });

  group('mobile', () {
    test('always shows the landing page', () {
      expect(_mobile(loggedOut), LoginEntryMode.landing);
      expect(_mobile(resolving), LoginEntryMode.landing);
      expect(_mobile(failed), LoginEntryMode.landing);
      expect(
        _mobile(loggedOut, suppression: AutoLoginSuppression.loginFailed),
        LoginEntryMode.landing,
      );
      expect(
        _mobile(loggedOut, suppression: AutoLoginSuppression.loggedOut),
        LoginEntryMode.landing,
      );
    });
  });
}
