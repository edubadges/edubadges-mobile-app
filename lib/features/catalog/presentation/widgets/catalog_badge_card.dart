import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/image.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogBadgeCard extends ConsumerWidget {
  final CatalogBadge badge;
  final VoidCallback? onTap;

  const CatalogBadgeCard({super.key, required this.badge, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final language = ref.read(appLanguageProvider);

    final institutionName = getLocalizedString(
      badge.institutionNameDutch,
      badge.institutionNameEnglish,
      language.code,
    );
    final badgeImageUrl = buildImageUrl(badge.image);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
          color: colorScheme.surfaceContainer,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (badgeImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  badgeImageUrl,
                  height: 64,
                  width: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 64,
                      width: 64,
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    badge.name,
                    style: textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    institutionName,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
