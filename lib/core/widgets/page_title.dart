import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sets the browser tab title to "[title] – Edubadges" while the page it wraps
/// is the one on screen (WCAG 2.4.2 Page titled).
///
/// Pages under the current route, and pages in a shell tab that is not shown,
/// keep building in the background with their tickers off; they leave the
/// title alone. A [PageTitle] deeper in a page builds after one around its
/// route, so the page can refine the title, for example with a badge name
/// once it has loaded.
class PageTitle extends StatelessWidget {
  final String Function(AppLocalizations l10n) title;
  final Widget child;

  const PageTitle({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool onScreen =
        (ModalRoute.isCurrentOf(context) ?? true) &&
        TickerMode.valuesOf(context).enabled;
    if (onScreen) {
      final AppLocalizations l10n = AppLocalizations.of(context);
      final String page = title(l10n).trim();
      // What [Title] does, without changing the tree when the page leaves the
      // screen, which would rebuild the page from scratch.
      SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
          label: page.isEmpty || page == l10n.appName
              ? l10n.appName
              : '$page – ${l10n.appName}',
          primaryColor: Theme.of(context).colorScheme.primary.toARGB32(),
        ),
      );
    }
    return child;
  }
}
