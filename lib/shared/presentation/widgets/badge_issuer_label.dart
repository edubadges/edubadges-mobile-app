import 'package:edubadges/core/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

/// Who awarded a badge: the issuer on the first line and its institution on
/// the second, optionally next to the institution logo.
///
/// The two names are stacked instead of joined on one line, so neither gets
/// cut off on narrow cards.
class BadgeIssuerLabel extends StatelessWidget {
  /// Two [TextTheme.bodySmall] lines high.
  static const double logoSize = 32;

  final String issuerName;
  final String institutionName;
  final String? logoUrl;

  /// Centers the label in its row, for the vertical cards. Next to a logo the
  /// names stay left aligned so they read as one block.
  final bool centered;

  const BadgeIssuerLabel({
    super.key,
    required this.issuerName,
    required this.institutionName,
    this.logoUrl,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle? style = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final List<String> lines = <String>[
      issuerName,
      institutionName,
    ].where((String line) => line.isNotEmpty).toList();

    final String url = logoUrl ?? '';
    final bool hasLogo = url.isNotEmpty;
    final bool centerNames = centered && !hasLogo;

    final Widget names = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centerNames
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        for (final String line in lines)
          Text(
            line,
            style: style,
            textAlign: centerNames ? TextAlign.center : TextAlign.start,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );

    if (!hasLogo) {
      return names;
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
        const SizedBox(width: 8),
        Flexible(child: names),
      ],
    );
  }
}
