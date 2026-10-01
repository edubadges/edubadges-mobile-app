import 'package:edubadges/features/login/domain/web_auto_login.dart';

/// The mobile app never starts the login on its own, so there is nothing to
/// persist.
class AutoLoginSuppressionStorage {
  AutoLoginSuppression? read() => null;

  void write(AutoLoginSuppression reason) {}

  void clear() {}
}
