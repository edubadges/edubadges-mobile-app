import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/image.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_badge.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/widgets/badge_grid_tile.dart';
import 'package:edubadges/shared/presentation/widgets/badge_issuer_label.dart';
import 'package:edubadges/shared/presentation/widgets/list_row_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogBadgeCard extends ConsumerWidget {
  final CatalogBadge badge;
  final VoidCallback? onTap;

  /// Renders the vertical grid tile instead of the compact list row.
  final bool useGridTile;

  const CatalogBadgeCard({
    super.key,
    required this.badge,
    this.onTap,
    this.useGridTile = false,
  });

  /// The names and logo a card shows for [badge]. The grid uses it to size its
  /// tiles before building them.
  static BadgeIssuerNames issuerNames(CatalogBadge badge, String langCode) => (
    issuerName: getLocalizedString(
      badge.issuerNameDutch,
      badge.issuerNameEnglish,
      langCode,
    ),
    institutionName: getLocalizedString(
      badge.institutionNameDutch,
      badge.institutionNameEnglish,
      langCode,
    ),
    logoUrl: buildImageUrl(badge.institutionImageDutch),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (:issuerName, :institutionName, logoUrl: institutionImageUrl) =
        issuerNames(badge, ref.watch(appLanguageProvider).code);
    final badgeImageUrl = buildImageUrl(badge.image);

    if (useGridTile) {
      final l10n = AppLocalizations.of(context);
      return BadgeGridTile(
        imageUrl: badgeImageUrl,
        name: badge.name,
        issuerName: issuerName,
        institutionName: institutionName,
        institutionImageUrl: institutionImageUrl,
        // No chips: grade and award date only exist once a badge is awarded,
        // and /catalog does not return the extension set that holds the time
        // investment. Only /badge-classes/{id} does, one badge per request.
        isPublic: !badge.isPrivate,
        visibilityLabel: badge.isPrivate
            ? l10n.semanticsBadgeVisibilityPrivate
            : l10n.semanticsBadgeVisibilityPublic,
        imageSemanticLabel: l10n.semanticsBadgeImage,
        onTap: onTap,
      );
    }

    return ListRowCard(
      imageUrl: badgeImageUrl,
      title: badge.name,
      issuerName: issuerName,
      institutionName: institutionName,
      onTap: onTap,
    );
  }
}
