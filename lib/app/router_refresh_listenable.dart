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
