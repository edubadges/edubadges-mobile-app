import 'dart:io';

import 'package:edubadges/app/colors.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveDialog extends StatelessWidget {
  final String title;

  final String? description;

  final Widget? body;

  final String? firstButtonText;

  final String secondButtonText;

  final VoidCallback onFirstButtonPressed;

  final VoidCallback onSecondButtonPressed;

  final bool isFirstButtonDefaultAction;

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
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    String? description,
    Widget? body,
    String? firstButtonText,
    required String secondButtonText,
    required VoidCallback onFirstButtonPressed,
    required VoidCallback onSecondButtonPressed,
    bool isFirstButtonDefaultAction = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AdaptiveDialog(
        title: title,
        description: description,
        body: body,
        firstButtonText: firstButtonText,
        secondButtonText: secondButtonText,
        onFirstButtonPressed: onFirstButtonPressed,
        onSecondButtonPressed: onSecondButtonPressed,
        isFirstButtonDefaultAction: isFirstButtonDefaultAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? _buildCupertinoDialog(context)
        : _buildMaterialDialog(context);
  }

  Widget _buildCupertinoDialog(BuildContext context) {
    final localizedFirstButtonText =
        firstButtonText ?? AppLocalizations.of(context)?.cancel ?? '';

    Widget? content;
    if (description != null && body != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description!, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          body!,
        ],
      );
    } else if (description != null) {
      content = Text(
        description!,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    } else if (body != null) {
      content = body;
    }

    return CupertinoAlertDialog(
      title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      content: content,
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
          textStyle: !isFirstButtonDefaultAction
              ? Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                )
              : Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
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
        firstButtonText ?? AppLocalizations.of(context)?.cancel ?? '';

    Widget? content;
    if (description != null && body != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description!, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          body!,
        ],
      );
    } else if (description != null) {
      content = Text(
        description!,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    } else if (body != null) {
      content = body;
    }

    return AlertDialog(
      title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      content: content,
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
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: Text(
            secondButtonText,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
