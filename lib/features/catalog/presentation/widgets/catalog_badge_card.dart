import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/image.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_badge.dart';
import 'package:edubadges/shared/presentation/widgets/list_row_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogBadgeCard extends ConsumerWidget {
  final CatalogBadge badge;
  final VoidCallback? onTap;

  const CatalogBadgeCard({super.key, required this.badge, this.onTap});

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

    return ListRowCard(
      imageUrl: badgeImageUrl,
      title: badge.name,
      subtitle: _buildSubtitle(issuerName, institutionName),
      onTap: onTap,
    );
  }
}
