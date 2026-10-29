import 'package:edubadges/core/widgets/delayed_loader.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? colorScheme.primary
              : colorScheme.primary.withValues(alpha: 0.12),
          foregroundColor: isEnabled
              ? colorScheme.onPrimary
              : colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.12),
        ).copyWith(animationDuration: const Duration(milliseconds: 0)),

        child: isLoading
            ? DelayedLoader(
                size: 20,
                strokeWidth: 2,
                // The button is disabled, so pale, while it loads.
                color: colorScheme.primary,
              )
            : Text(
                text,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isEnabled
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              ),
      ),
    );
  }
}
