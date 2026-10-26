import 'dart:math' as math;

import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/core/widgets/app_network_image.dart';
import 'package:edubadges/core/widgets/svg_icon.dart';
import 'package:edubadges/shared/presentation/widgets/badge_issuer_label.dart';
import 'package:flutter/material.dart';

/// A single piece of metadata shown on a [BadgeGridTile], such as the time
/// investment or the award date.
class BadgeInfoChipData {
  final String icon;
  final String label;

  const BadgeInfoChipData({required this.icon, required this.label});
}

class BadgeInfoChip extends StatelessWidget {
  static const double _paddingStart = 8;
  static const double _paddingEnd = 12;
  static const double _iconSize = 18;
  static const double _iconGap = 6;

  final String icon;
  final String label;

  const BadgeInfoChip({super.key, required this.icon, required this.label});

  static TextStyle? _labelStyle(BuildContext context) => Theme.of(
    context,
  ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600);

  /// Width the chip for [label] takes, measured the way [build] lays it out.
  static double widthFor(BuildContext context, String label) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: label, style: _labelStyle(context)),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final double textWidth = painter.width.ceilToDouble();
    painter.dispose();
    return _paddingStart + _iconSize + _iconGap + textWidth + _paddingEnd;
  }

  @override
  Widget build(BuildContext context) {
    final onPrimaryContainer = Theme.of(context).colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.only(
        left: _paddingStart,
        right: _paddingEnd,
        top: 6,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgIcon(
            assetPath: icon,
            size: _iconSize,
            color: onPrimaryContainer,
            excludeFromSemantics: true,
          ),
          const SizedBox(width: _iconGap),
          Flexible(
            child: Text(
              label,
              style: _labelStyle(context)?.copyWith(color: onPrimaryContainer),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical badge tile used by the web grid layouts.
///
/// Presentation only, so the badges overview (badge instances) and the catalog
/// (catalog search results) can share it without a common entity type.
class BadgeGridTile extends StatelessWidget {
  static const double _padding = 16;
  static const double _chipSpacing = 8;
  static const double _imageSize = 100;
  static const int _nameMaxLines = 2;
  static const double _visibilityIconSize = 32;

  final String? imageUrl;
  final String name;
  final String issuerName;
  final String institutionName;
  final String? institutionImageUrl;
  final List<BadgeInfoChipData> chips;

  /// Renders the visibility shield when set. Omitted when visibility does not
  /// apply to the badge.
  final bool? isPublic;
  final String? visibilityLabel;

  final String? imageSemanticLabel;
  final VoidCallback? onTap;

  const BadgeGridTile({
    super.key,
    this.imageUrl,
    required this.name,
    required this.issuerName,
    required this.institutionName,
    this.institutionImageUrl,
    this.chips = const <BadgeInfoChipData>[],
    this.isPublic,
    this.visibilityLabel,
    this.imageSemanticLabel,
    this.onTap,
  });

  /// The most chip rows any of [chipSets] wraps onto in a tile of
  /// [tileWidth]. A grid sizes every tile to this, so the tiles stay equal
  /// without reserving a second row no badge needs.
  static int chipRowsFor(
    BuildContext context,
    Iterable<List<BadgeInfoChipData>> chipSets,
    double tileWidth,
  ) {
    final double available = tileWidth - _padding * 2;
    // Dates and hours repeat across a backpack, so measure each label once.
    final Map<String, double> widths = <String, double>{};
    int maxRows = 0;
    for (final List<BadgeInfoChipData> chips in chipSets) {
      int rows = 0;
      double line = 0;
      for (final BadgeInfoChipData chip in chips) {
        final double width = math.min(
          widths.putIfAbsent(
            chip.label,
            () => BadgeInfoChip.widthFor(context, chip.label),
          ),
          available,
        );
        if (rows == 0 || line + _chipSpacing + width > available) {
          rows++;
          line = width;
        } else {
          line += _chipSpacing + width;
        }
      }
      maxRows = math.max(maxRows, rows);
    }
    return maxRows;
  }

  Widget _buildBadgeImage(ColorScheme colorScheme) {
    Widget placeholder() => SizedBox(
      height: _imageSize,
      width: _imageSize,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return ExcludeSemantics(child: placeholder());
    }

    return ExcludeSemantics(
      child: AppNetworkImage(
        imageUrl: imageUrl!,
        height: _imageSize,
        width: _imageSize,
        semanticLabel: imageSemanticLabel,
        errorBuilder: (context, error, stackTrace) => placeholder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: _buildBadgeImage(colorScheme)),
        const SizedBox(height: 8),
        // Always two lines tall, so every tile in a grid lines up the same.
        SizedBox(
          height: LayoutConstants.badgeGridTileNameHeight,
          child: Center(
            child: Text(
              name,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
              maxLines: _nameMaxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (chips.isEmpty)
          // The catalog has no chip content, and its card drops the row rather
          // than leaving a gap.
          const Spacer()
        else ...[
          const SizedBox(height: 8),
          // The tile has a fixed extent in the grid, so a chip row that wraps
          // further than budgeted is clipped rather than overflowing the tile.
          Expanded(
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: double.infinity,
                child: Wrap(
                  spacing: _chipSpacing,
                  runSpacing: _chipSpacing,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final BadgeInfoChipData chip in chips)
                      BadgeInfoChip(icon: chip.icon, label: chip.label),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        BadgeIssuerLabel(
          issuerName: issuerName,
          institutionName: institutionName,
          logoUrl: institutionImageUrl,
          centered: true,
        ),
      ],
    );

    final Widget tile = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surfaceContainer,
      ),
      // Drawn in front so the hairline does not eat 2px of the fixed tile
      // height, which the design measures from the outer edge.
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(_padding),
      child: Stack(
        children: [
          MergeSemantics(child: content),
          if (isPublic != null)
            Positioned(
              top: 0,
              right: 0,
              // Both shields carry their own two-tone palette, so no tint.
              child: SvgIcon(
                assetPath: isPublic! ? Assets.iconUnlocked : Assets.iconLocked,
                size: _visibilityIconSize,
                semanticLabel: visibilityLabel,
              ),
            ),
        ],
      ),
    );

    if (onTap == null) {
      return tile;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: tile,
      ),
    );
  }
}
