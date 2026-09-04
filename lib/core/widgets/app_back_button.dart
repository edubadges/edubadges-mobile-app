import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pops the current route, or navigates to [fallbackLocation] when there is
/// nothing to pop. Deep links and browser reloads open a detail page as the
/// first entry of the stack, so popping is not always possible.
void navigateBack(
  BuildContext context, {
  String fallbackLocation = RoutePath.main,
}) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallbackLocation);
  }
}

/// Back affordance for the `leading` slot of an [AppBar].
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String fallbackLocation;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.fallbackLocation = RoutePath.main,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(Icons.arrow_back, color: colorScheme.primary),
      onPressed:
          onPressed ??
          () => navigateBack(context, fallbackLocation: fallbackLocation),
      tooltip: AppLocalizations.of(context).semanticsBack,
    );
  }
}

/// Back affordance with a visible label, for wide layouts that render their own
/// header instead of an [AppBar].
class AppBackTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String fallbackLocation;

  const AppBackTextButton({
    super.key,
    this.onPressed,
    this.fallbackLocation = RoutePath.main,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return TextButton.icon(
      onPressed:
          onPressed ??
          () => navigateBack(context, fallbackLocation: fallbackLocation),
      icon: Icon(Icons.arrow_back, color: colorScheme.primary, size: 20),
      label: Text(
        l10n.semanticsBack,
        style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.primary),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
