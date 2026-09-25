import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/features/login/domain/web_auto_login.dart';
import 'package:web/web.dart' as web;

/// Keeps the [AutoLoginSuppression] in `sessionStorage`.
///
/// That scope is deliberate: it survives a reload of the tab and the round trip
/// to eduID, but is gone in a new tab or once the browser is closed.
class AutoLoginSuppressionStorage {
  static const String _key = 'edubadges.autoLoginSuppression';

  AutoLoginSuppression? read() {
    try {
      final String? value = web.window.sessionStorage.getItem(_key);
      return AutoLoginSuppression.values
          .where((reason) => reason.name == value)
          .firstOrNull;
    } catch (e) {
      logger.w('Auth(web): could not read auto-login suppression', error: e);
      return null;
    }
  }

  void write(AutoLoginSuppression reason) {
    try {
      web.window.sessionStorage.setItem(_key, reason.name);
    } catch (e) {
      logger.w('Auth(web): could not store auto-login suppression', error: e);
    }
  }

  void clear() {
    try {
      web.window.sessionStorage.removeItem(_key);
    } catch (e) {
      logger.w('Auth(web): could not clear auto-login suppression', error: e);
    }
  }
}
