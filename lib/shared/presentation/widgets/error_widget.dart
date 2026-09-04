import 'package:edubadges/core/widgets/debug_error_log_button.dart';
import 'package:edubadges/core/widgets/preview_app.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// ## ErrorMessageWidget
///
/// Use `InfoStateView` for error messages with custom messages.
class ErrorMessageWidget extends StatelessWidget {
  final Object? error;
  final StackTrace? stackTrace;
  final String? debugContext;

  const ErrorMessageWidget({
    super.key,
    this.error,
    this.stackTrace,
    this.debugContext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          ExcludeSemantics(
            child: Icon(Icons.error, size: 40, color: colorScheme.primary),
          ),
          Semantics(
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.unableToLoad,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  l10n.unableToLoadSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          DebugErrorLogButton(
            error: error,
            stackTrace: stackTrace,
            debugContext: debugContext,
          ),
        ],
      ),
    );
  }
}

@EdubadgesWidgetPreview(name: 'Error Message', group: 'Error Message Widget')
Widget errorStateMessagePreview() {
  return const ErrorMessageWidget();
}
