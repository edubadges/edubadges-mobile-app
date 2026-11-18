import 'package:edubadges/features/login/data/models/login_user_status.dart';
import 'package:edubadges/features/login/presentation/providers/login_providers.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:edubadges/shared/presentation/providers/permission_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(this._ref) {
    _ref.listen<bool?>(
      authProvider.select((state) => state.asData?.value),
      (_, _) => notifyListeners(),
    );
    // After login the router waits on the login route until this status is
    // known, so it decides again once it loads (SURF-687). Listening also
    // keeps the status alive between that wait and the decision.
    _ref.listen<(bool, bool, LoginUserAuthStatus?)>(
      loginStatusProvider.select(
        (status) => (status.isLoading, status.hasError, status.asData?.value),
      ),
      (_, _) => notifyListeners(),
    );
    if (!kIsWeb) {
      _ref.listen<bool?>(
        shouldShowNotificationPermissionPromptProvider.select(
          (state) => state.asData?.value,
        ),
        (_, _) => notifyListeners(),
      );
    }
  }

  final Ref _ref;
}
