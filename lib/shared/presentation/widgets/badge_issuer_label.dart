import 'dart:math' as math;

import 'package:edubadges/core/widgets/app_network_image.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// What a [BadgeIssuerLabel] shows, so a grid can measure the label before
/// building it.
typedef BadgeIssuerNames = ({
  String issuerName,
  String institutionName,
  String? logoUrl,
});

/// Who awarded a badge, "Issuer van instelling", optionally next to the
/// institution logo.
///
/// One line when it fits, as in the design. A name that does not fit wraps
/// onto a second line instead of being cut off (SURF-679).
class BadgeIssuerLabel extends StatelessWidget {
  static const double logoSize = 22;
  static const double _logoGap = 8;
  static const int maxLines = 2;

  final String issuerName;
  final String institutionName;
  final String? logoUrl;

  /// Centers the label in its row, for the vertical cards. Next to a logo a
  /// wrapped label stays left aligned so it reads as one block.
  final bool centered;

  const BadgeIssuerLabel({
    super.key,
    required this.issuerName,
    required this.institutionName,
    this.logoUrl,
    this.centered = false,
  });

  static String _text(
    BuildContext context,
    String issuerName,
    String institutionName,
  ) {
    if (issuerName.isEmpty) return institutionName;
    if (institutionName.isEmpty) return issuerName;
    return AppLocalizations.of(
      context,
    ).badgeIssuerOfInstitution(issuerName, institutionName);
  }

  static TextStyle? _style(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall;

  /// Lines the label for [names] takes in [maxWidth], measured the way [build]
  /// lays it out.
  static int lineCount(
    BuildContext context,
    BadgeIssuerNames names, {
    required double maxWidth,
  }) {
    final bool hasLogo = (names.logoUrl ?? '').isNotEmpty;
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: _text(context, names.issuerName, names.institutionName),
        style: _style(context),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: maxLines,
    );
    painter.layout(
      maxWidth: math.max(
        0,
        hasLogo ? maxWidth - logoSize - _logoGap : maxWidth,
      ),
    );
    final int lines = painter.computeLineMetrics().length;
    painter.dispose();
    return lines.clamp(1, maxLines);
  }

  @override
  Widget build(BuildContext context) {
    final String url = logoUrl ?? '';
    final bool hasLogo = url.isNotEmpty;

    final Widget label = Text(
      _text(context, issuerName, institutionName),
      style: _style(
        context,
      )?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      textAlign: centered && !hasLogo ? TextAlign.center : TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );

    if (!hasLogo) {
      return label;
    }

    return Row(
      mainAxisSize: centered ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: centered
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: AppNetworkImage(
            imageUrl: url,
            height: logoSize,
            width: logoSize,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox(height: logoSize, width: logoSize),
          ),
        ),
        const SizedBox(width: _logoGap),
        Flexible(child: label),
      ],
    );
  }
}
