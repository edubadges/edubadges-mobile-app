import 'package:edubadges/core/widgets/app_network_image.dart';
import 'package:edubadges/shared/presentation/widgets/badge_issuer_label.dart';
import 'package:flutter/material.dart';

/// Compact badge row used by the app lists: the backpack overview, the
/// catalog and the collection badge picker all render a badge the same way.
class ListRowCard extends StatelessWidget {
  static const double _imageSize = 64;

  /// 16 padding + 64 image + 16 padding, as in the design. Two title lines
  /// (40) + 2 + the issuer line (16) fit beside the image; only a card whose
  /// title and issuer both wrap grows past it.
  static const double minHeight = 96;

  final String? imageUrl;
  final String title;
  final String issuerName;
  final String institutionName;
  final VoidCallback? onTap;
  final String? semanticLabel;

  /// Shown at the end of the row, e.g. a selection checkbox.
  final Widget? trailing;
  final bool isSelected;

  /// Border of an unselected card; defaults to `outlineVariant`.
  final Color? borderColor;

  const ListRowCard({
    super.key,
    this.imageUrl,
    required this.title,
    required this.issuerName,
    required this.institutionName,
    this.onTap,
    this.semanticLabel,
    this.trailing,
    this.isSelected = false,
    this.borderColor,
  });

  Widget _buildImage(ColorScheme colorScheme) {
    final Widget placeholder = SizedBox(
      height: _imageSize,
      width: _imageSize,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return ExcludeSemantics(child: placeholder);
    }

    return ExcludeSemantics(
      child: AppNetworkImage(
        imageUrl: imageUrl!,
        height: _imageSize,
        width: _imageSize,
        // Badge images come in any aspect ratio; show them whole.
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => placeholder,
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
        color: isSelected ? colorScheme.surface : colorScheme.surfaceContainer,
      ),
      // Drawn in front so the hairline does not add to the height, which the
      // design measures from the outer edge.
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : borderColor ?? colorScheme.outlineVariant,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildImage(colorScheme),
          const SizedBox(width: 16),
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  BadgeIssuerLabel(
                    issuerName: issuerName,
                    institutionName: institutionName,
                  ),
                ],
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );

    if (onTap != null) {
      return MergeSemantics(
        child: Semantics(
          label: semanticLabel,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: cardContent,
            ),
          ),
        ),
      );
    }

    return cardContent;
  }
}
