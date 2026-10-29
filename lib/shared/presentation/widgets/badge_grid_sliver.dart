import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/presentation/widgets/badge_card.dart';
import 'package:edubadges/shared/presentation/widgets/badge_grid_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The web grid of badge tiles, shared by the backpack overview and the
/// collection page so a badge looks the same in both.
class BadgeGridSliver extends ConsumerWidget {
  final List<BadgeInstanceEntity> badges;
  final int columns;

  /// Builds the tile for `badges[index]`.
  final IndexedWidgetBuilder itemBuilder;

  const BadgeGridSliver({
    super.key,
    required this.badges,
    required this.columns,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String langCode = ref.watch(appLanguageProvider).code;
    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        final double tileWidth = LayoutConstants.badgeGridTileWidth(
          constraints.crossAxisExtent,
          columns,
        );
        final AppLocalizations l10n = AppLocalizations.of(context);
        final Iterable<BadgeClassModel> badgeClasses = badges.map(
          (BadgeInstanceEntity badge) => badge.badgeclass as BadgeClassModel,
        );
        // Every tile gets the height of the badge with the most chip rows and
        // issuer lines, so the grid stays even without blank rows.
        final int chipRows = BadgeGridTile.chipRowsFor(
          context,
          badges.map(
            (BadgeInstanceEntity badge) => BadgeCard.infoChips(
              instance: badge,
              badgeClass: badge.badgeclass as BadgeClassModel,
              l10n: l10n,
            ),
          ),
          tileWidth,
        );
        final int issuerLines = BadgeGridTile.issuerLinesFor(
          context,
          badgeClasses.map(
            (BadgeClassModel badgeClass) =>
                BadgeCard.issuerNames(badgeClass, langCode),
          ),
          tileWidth,
        );
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: LayoutConstants.badgeGridSpacing,
            mainAxisSpacing: LayoutConstants.badgeGridSpacing,
            mainAxisExtent: LayoutConstants.badgeGridTileHeightFor(
              chipRows: chipRows,
              issuerLines: issuerLines,
              textScaler: MediaQuery.textScalerOf(context),
            ),
          ),
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: badges.length,
          ),
        );
      },
    );
  }
}
