import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/core/utils/platform_info.dart';
import 'package:flutter/material.dart';

/// Presentation mode for content shown via [showAppFormModal].
class AppFormModalPresentation extends InheritedWidget {
  final bool isDialog;

  const AppFormModalPresentation({
    super.key,
    required this.isDialog,
    required super.child,
  });

  static bool? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppFormModalPresentation>()
        ?.isDialog;
  }

  @override
  bool updateShouldNotify(AppFormModalPresentation oldWidget) {
    return isDialog != oldWidget.isDialog;
  }
}

/// Shows a modal form.
///
/// On web the content is presented as a centered [Dialog] (users expect
/// dialogs rather than bottom sheets on desktop). On mobile the existing
/// bottom-sheet presentation is preserved unchanged.
Future<T?> showAppFormModal<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isDismissible = true,
  /// No-op on web: the dialog branch does not use [enableDrag].
  bool enableDrag = true,
  bool useRootNavigator = false,
}) {
  Widget wrap(BuildContext context, {required bool isDialog}) {
    return AppFormModalPresentation(
      isDialog: isDialog,
      child: builder(context),
    );
  }

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
            maxWidth: LayoutConstants.webFormModalMaxWidth,
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: wrap(context, isDialog: true),
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
    builder: (context) => wrap(context, isDialog: false),
  );
}
