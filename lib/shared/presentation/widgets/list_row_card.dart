import 'package:edubadges/core/widgets/app_network_image.dart';
import 'package:edubadges/shared/presentation/widgets/badge_issuer_label.dart';
import 'package:flutter/material.dart';

class ListRowCard extends StatelessWidget {
  /// 16 padding + 2 title lines (40) + 2 issuer lines (32) + 16 padding, as in
  /// the design. Rows with shorter text keep this height, so all cards in a
  /// list are the same size.
  static const double minHeight = 106;

  final String? imageUrl;
  final String title;
  final String issuerName;
  final String institutionName;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const ListRowCard({
    super.key,
    this.imageUrl,
    required this.title,
    required this.issuerName,
    required this.institutionName,
    this.onTap,
    this.semanticLabel,
  });

  Widget _buildImage(ColorScheme colorScheme) {
    final Widget placeholder = Container(
      height: 64,
      width: 64,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: placeholder,
        ),
      );
    }

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AppNetworkImage(
          imageUrl: imageUrl!,
          height: 64,
          width: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => placeholder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final cardContent = Container(
      constraints: const BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surfaceContainer,
      ),
      // Drawn in front so the hairline does not add to the height, which the
      // design measures from the outer edge.
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildImage(colorScheme),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                BadgeIssuerLabel(
                  issuerName: issuerName,
                  institutionName: institutionName,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return MergeSemantics(
        child: Semantics(
          label: semanticLabel,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: cardContent,
          ),
        ),
      );
    }

    return cardContent;
  }
}
