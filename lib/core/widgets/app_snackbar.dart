import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/utils/platform_info.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Fixed width for the floating snackbar on web so it stays compact instead of
/// stretching nearly full-width on wide viewports.
const double _webSnackBarWidth = 420;

/// Distance the web snackbar keeps from the viewport edges.
const double _webSnackBarEdgeInset = 16;

void showAppSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  // On web, pin the snackbar to the bottom-right corner. A floating SnackBar
  // with `width` set is always centered, so we instead use `margin` and push it
  // to the right by making the left margin fill the remaining space.
  // Flutter forbids setting both `width` and `margin` on a floating SnackBar.
  EdgeInsets? snackBarMargin = const EdgeInsets.all(16);
  if (PlatformInfo.isWeb) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double leftMargin =
        (screenWidth - _webSnackBarWidth - _webSnackBarEdgeInset).clamp(
          _webSnackBarEdgeInset,
          double.infinity,
        );
    snackBarMargin = EdgeInsets.only(
      left: leftMargin,
      right: _webSnackBarEdgeInset,
      bottom: _webSnackBarEdgeInset,
    );
  }

  SemanticsService.sendAnnouncement(
    View.of(context),
    message,
    Directionality.of(context),
  );
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.inverseOnSurface,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 24,
              color: AppColors.inverseOnSurface,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            tooltip: AppLocalizations.of(context).semanticsClose,
          ),
        ],
      ),
      backgroundColor: colorScheme.inverseSurface,
      behavior: SnackBarBehavior.floating,
      margin: snackBarMargin,
      padding: const EdgeInsets.only(left: 16, right: 4, top: 4, bottom: 4),
      duration: duration,
    ),
  );
}
