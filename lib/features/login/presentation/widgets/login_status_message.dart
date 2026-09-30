import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tells the user on the login screen why logging in is needed or did not
/// work: the session expired, or SurfConext could not be reached.
///
/// Shows nothing otherwise, e.g. after the user cancelled the login.
class LoginStatusMessage extends ConsumerWidget {
  const LoginStatusMessage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final AsyncValue<bool> auth = ref.watch(authProvider);
    final bool sessionExpired = ref.watch(sessionExpiredNoticeProvider);

    final bool unreachable =
        !auth.isLoading && auth.hasError && auth.error is NetworkFailure;
    final String? message = unreachable
        ? l10n.loginConnectionError
        : sessionExpired
        ? l10n.sessionExpiredMessage
        : null;
    if (message == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: Semantics(
          liveRegion: true,
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: unreachable
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
