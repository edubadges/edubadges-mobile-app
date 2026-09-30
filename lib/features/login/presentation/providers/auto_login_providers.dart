import 'package:edubadges/features/login/data/datasources/auto_login_suppression_storage.dart';
import 'package:edubadges/features/login/domain/web_auto_login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether a logged-out visitor is sent straight to eduID.
///
/// Web only: the mobile app keeps its landing page.
final autoLoginSupportedProvider = Provider<bool>((ref) => kIsWeb);

final autoLoginSuppressionStorageProvider =
    Provider<AutoLoginSuppressionStorage>((ref) {
      return AutoLoginSuppressionStorage();
    });

final autoLoginSuppressionProvider =
    NotifierProvider<AutoLoginSuppressionNotifier, AutoLoginSuppression?>(
      AutoLoginSuppressionNotifier.new,
    );

class AutoLoginSuppressionNotifier extends Notifier<AutoLoginSuppression?> {
  @override
  AutoLoginSuppression? build() {
    return ref.watch(autoLoginSuppressionStorageProvider).read();
  }

  void suppress(AutoLoginSuppression reason) {
    ref.read(autoLoginSuppressionStorageProvider).write(reason);
    state = reason;
  }

  void clear() {
    ref.read(autoLoginSuppressionStorageProvider).clear();
    state = null;
  }

  /// Records how the browser's return from eduID ended.
  ///
  /// A cancelled or failed login lands on the landing page instead of starting
  /// a new attempt straight away, which would loop.
  void recordLoginRedirect({required bool succeeded}) {
    if (succeeded) {
      clear();
    } else {
      suppress(AutoLoginSuppression.loginFailed);
    }
  }
}
