import 'package:edubadges/core/utils/platform_info.dart';
import 'package:flutter/material.dart';

/// Maximum width of the dialog variant shown on web.
const double _webModalMaxWidth = 480;

/// Shows a modal form.
///
/// On web the content is presented as a centered [Dialog] (users expect
/// dialogs rather than bottom sheets on desktop). On mobile the existing
/// bottom-sheet presentation is preserved unchanged.
Future<T?> showAppFormModal<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = false,
}) {
  if (PlatformInfo.isWeb) {
    return showDialog<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      barrierDismissible: isDismissible,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _webModalMaxWidth,
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: builder(context),
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: true,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    builder: builder,
  );
}
