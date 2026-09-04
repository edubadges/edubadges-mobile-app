import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/image.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_badge.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/widgets/badge_grid_tile.dart';
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

  String _buildSubtitle(String issuerName, String institutionName) {
    if (issuerName.isEmpty) {
      return institutionName;
    }
    if (institutionName.isEmpty) {
      return issuerName;
    }
    return '$issuerName — $institutionName';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final issuerName = getLocalizedString(
      badge.issuerNameDutch,
      badge.issuerNameEnglish,
      language.code,
    );
    final institutionName = getLocalizedString(
      badge.institutionNameDutch,
      badge.institutionNameEnglish,
      language.code,
    );
    final badgeImageUrl = buildImageUrl(badge.image);

    if (useGridTile) {
      final l10n = AppLocalizations.of(context);
      final institutionImageUrl = buildImageUrl(badge.institutionImageDutch);
      return BadgeGridTile(
        imageUrl: badgeImageUrl,
        name: badge.name,
        institutionName: _buildSubtitle(issuerName, institutionName),
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
      subtitle: _buildSubtitle(issuerName, institutionName),
      onTap: onTap,
    );
  }
}
