import 'dart:math' as math;
import 'dart:ui' show SemanticsRole;

import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/utils/platform_info.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveDialogConfig {
  final String title;
  final String? description;
  final Widget? body;
  final String? firstButtonText;
  final String secondButtonText;
  final VoidCallback onFirstButtonPressed;
  final VoidCallback onSecondButtonPressed;
  final bool isFirstButtonDefaultAction;

  /// Colours the second button as destructive (error colour).
  final bool isDestructiveAction;

  /// Colours the first button as destructive (error colour), e.g. a
  /// "Don't save" action next to a primary "Save".
  final bool isFirstButtonDestructive;

  const AdaptiveDialogConfig({
    required this.title,
    this.description,
    this.body,
    this.firstButtonText,
    required this.secondButtonText,
    required this.onFirstButtonPressed,
    required this.onSecondButtonPressed,
    this.isFirstButtonDefaultAction = false,
    this.isDestructiveAction = false,
    this.isFirstButtonDestructive = false,
  });
}

class AdaptiveDialog extends StatelessWidget {
  final String title;

  final String? description;

  final Widget? body;

  final String? firstButtonText;

  final String secondButtonText;

  final VoidCallback onFirstButtonPressed;

  final VoidCallback onSecondButtonPressed;

  final bool isFirstButtonDefaultAction;
  final bool isDestructiveAction;
  final bool isFirstButtonDestructive;

  const AdaptiveDialog({
    super.key,
    required this.title,
    this.description,
    this.body,
    this.firstButtonText,
    required this.secondButtonText,
    required this.onFirstButtonPressed,
    required this.onSecondButtonPressed,
    this.isFirstButtonDefaultAction = false,
    this.isDestructiveAction = false,
    this.isFirstButtonDestructive = false,
  });

  static Future<void> show({
    required BuildContext context,
    required AdaptiveDialogConfig config,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AdaptiveDialog(
        title: config.title,
        description: config.description,
        body: config.body,
        firstButtonText: config.firstButtonText,
        secondButtonText: config.secondButtonText,
        onFirstButtonPressed: config.onFirstButtonPressed,
        onSecondButtonPressed: config.onSecondButtonPressed,
        isFirstButtonDefaultAction: config.isFirstButtonDefaultAction,
        isDestructiveAction: config.isDestructiveAction,
        isFirstButtonDestructive: config.isFirstButtonDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformInfo.useCupertinoDialog
        ? _buildCupertinoDialog(context)
        : _buildMaterialDialog(context);
  }

  Widget? _buildContent(BuildContext context) {
    if (description != null && body != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description!, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          body!,
        ],
      );
    } else if (description != null) {
      return Text(description!, style: Theme.of(context).textTheme.bodyMedium);
    } else if (body != null) {
      return body;
    }
    return null;
  }

  Widget _buildCupertinoDialog(BuildContext context) {
    final localizedFirstButtonText =
        firstButtonText ?? AppLocalizations.of(context).cancel;
    final secondButtonColor = isDestructiveAction
        ? AppColors.error
        : AppColors.primary;
    final firstButtonColor = isFirstButtonDestructive
        ? AppColors.error
        : AppColors.iosBlue;

    return CupertinoAlertDialog(
      title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      content: _buildContent(context),

      actions: [
        CupertinoDialogAction(
          isDefaultAction: isFirstButtonDefaultAction,
          isDestructiveAction: isFirstButtonDestructive,
          textStyle: isFirstButtonDefaultAction
              ? Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: firstButtonColor,
                  fontWeight: FontWeight.w600,
                )
              : Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: firstButtonColor),
          onPressed: () {
            Navigator.of(context).pop();
            onFirstButtonPressed();
          },
          child: Text(
            localizedFirstButtonText,
            style: isFirstButtonDestructive
                ? Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: AppColors.error)
                : Theme.of(context).textTheme.labelLarge,
          ),
        ),
        CupertinoDialogAction(
          isDefaultAction: !isFirstButtonDefaultAction,
          isDestructiveAction: isDestructiveAction,
          textStyle: !isFirstButtonDefaultAction
              ? Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: secondButtonColor,
                  fontWeight: FontWeight.w600,
                )
              : Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: secondButtonColor),
          onPressed: () {
            Navigator.of(context).pop();
            onSecondButtonPressed();
          },
          child: Text(
            secondButtonText,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialDialog(BuildContext context) {
    final theme = Theme.of(context);
    final dialogTheme = DialogTheme.of(context);
    final localizedFirstButtonText =
        firstButtonText ?? AppLocalizations.of(context).cancel;
    final contentWidget = _buildContent(context);
    final size = MediaQuery.sizeOf(context);
    final titleTextStyle =
        dialogTheme.titleTextStyle ?? theme.textTheme.headlineSmall!;
    final bodyTextStyle =
        dialogTheme.contentTextStyle ?? theme.textTheme.bodyMedium!;
    const spacing = 8.0;
    final actionsPadding = dialogTheme.actionsPadding ??
        const EdgeInsets.only(left: 24, right: 24, bottom: 24);

    final titleSection = Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, contentWidget != null ? 0 : 20),
      child: DefaultTextStyle(
        style: titleTextStyle,
        // Names the dialog for screen readers, and is its heading.
        child: Semantics(
          container: true,
          header: true,
          namesRoute: true,
          child: Text(title),
        ),
      ),
    );

    final actionsSection = Padding(
      padding: theme.useMaterial3
          ? actionsPadding
          : actionsPadding.add(const EdgeInsets.all(spacing)),
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: OverflowBar(
          alignment: MainAxisAlignment.end,
          spacing: spacing,
          overflowAlignment: OverflowBarAlignment.end,
          children: [
            FocusTraversalOrder(
              order: const NumericFocusOrder(1),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onFirstButtonPressed();
                },
                style: isFirstButtonDestructive
                    ? TextButton.styleFrom(foregroundColor: AppColors.error)
                    : null,
                child: Text(
                  localizedFirstButtonText,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isFirstButtonDestructive
                        ? AppColors.error
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            FocusTraversalOrder(
              order: const NumericFocusOrder(2),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onSecondButtonPressed();
                },
                style: TextButton.styleFrom(
                  foregroundColor: isDestructiveAction
                      ? AppColors.error
                      : AppColors.primary,
                ),
                child: Text(
                  secondButtonText,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDestructiveAction
                        ? AppColors.error
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    const horizontalMargin = 24.0;
    final maxPanelWidth = math.max(0.0, size.width - 2 * horizontalMargin);
    final dialogConstraints = BoxConstraints(
      minWidth: math.min(280, maxPanelWidth),
      maxWidth: math.min(560, maxPanelWidth),
      maxHeight: size.height * 0.9,
    );

    if (contentWidget == null) {
      return Dialog(
        semanticsRole: SemanticsRole.alertDialog,
        clipBehavior: Clip.antiAlias,
        constraints: dialogConstraints,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            titleSection,
            actionsSection,
          ],
        ),
      );
    }

    return Dialog(
      semanticsRole: SemanticsRole.alertDialog,
      clipBehavior: Clip.antiAlias,
      constraints: dialogConstraints,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titleSection,
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                theme.useMaterial3 ? 16 : 20,
                24,
                24,
              ),
              child: DefaultTextStyle(
                style: bodyTextStyle,
                child: Semantics(
                  container: true,
                  explicitChildNodes: true,
                  child: contentWidget,
                ),
              ),
            ),
          ),
          actionsSection,
        ],
      ),
    );
  }
}
