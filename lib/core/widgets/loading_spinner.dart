import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// A [CircularProgressIndicator] announced as "Loading..." (or [label]).
///
/// Material marks its indicator as a loading spinner, but Flutter's web engine
/// gives that role no ARIA role, only the `aria-label`, which is not allowed on
/// an element without one (WCAG 4.1.2; axe reports `aria-prohibited-attr`).
/// This spinner is a `status` with the label instead.
class LoadingSpinner extends StatelessWidget {
  /// What is loading; "Loading..." by default.
  final String? label;
  final double? strokeWidth;
  final Color? color;

  const LoadingSpinner({super.key, this.label, this.strokeWidth, this.color});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      role: SemanticsRole.status,
      label: label ?? AppLocalizations.of(context).semanticsLoading,
      child: ExcludeSemantics(
        child: CircularProgressIndicator(strokeWidth: strokeWidth, color: color),
      ),
    );
  }
}
