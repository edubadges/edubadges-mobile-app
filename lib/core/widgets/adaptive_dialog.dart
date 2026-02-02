import 'dart:io';

import 'package:edubadges/app/colors.dart';
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
  final bool isDestructiveAction;

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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
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

    return CupertinoAlertDialog(
      title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      content: _buildContent(context),

      actions: [
        CupertinoDialogAction(
          isDefaultAction: isFirstButtonDefaultAction,
          textStyle: isFirstButtonDefaultAction
              ? Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.iosBlue,
                  fontWeight: FontWeight.w600,
                )
              : Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.iosBlue),
          onPressed: () {
            Navigator.of(context).pop();
            onFirstButtonPressed();
          },
          child: Text(
            localizedFirstButtonText,
            style: Theme.of(context).textTheme.labelLarge,
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
    final localizedFirstButtonText =
        firstButtonText ?? AppLocalizations.of(context).cancel;

    return AlertDialog(
      title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      content: _buildContent(context),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onFirstButtonPressed();
          },
          child: Text(
            localizedFirstButtonText,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        TextButton(
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isDestructiveAction ? AppColors.error : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
