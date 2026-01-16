import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/utils/image.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

enum BadgeCardStyle { small, large }

class BadgeCard extends StatelessWidget {
  final BadgeInstanceModel instance;
  final BadgeCardStyle style;
  const BadgeCard({
    super.key,
    required this.instance,
    this.style = BadgeCardStyle.large,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final institution = instance.badgeclass.issuer?.faculty?.institution;
    // TODO: decide the approach we want to go with (at least one should never not be null)
    final institutionName =
        (institution?.nameDutch ?? institution?.nameEnglish) ?? 'Unknown';
    final institutionImageUrl = buildImageUrl(institution?.imageDutch);
    final badgeImageUrl = buildImageUrl(instance.badgeclass.image);

    // Small badge
    if (style == BadgeCardStyle.small) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
          color: colorScheme.surfaceContainer,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          spacing: 12,
          children: [
            // TODO: add no image paceholder
            if (badgeImageUrl != null)
              Image.network(
                badgeImageUrl,
                height: 64,
                width: 64,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(height: 64, width: 100);
                },
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instance.badgeclass.name,
                    style: textTheme.titleSmall,
                    maxLines: 2,
                  ),
                  Text(
                    institutionName,
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Large card style
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surfaceContainer,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32, width: 32),
              // TODO: add no image paceholder
              if (badgeImageUrl != null)
                Expanded(
                  child: Image.network(
                    badgeImageUrl,
                    height: 100,
                    width: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(height: 100, width: 100);
                    },
                  ),
                ),
              SizedBox(
                height: 32,
                width: 32,
                child: SvgPicture.asset(
                  instance.public ? Assets.iconUnlocked : Assets.iconLocked,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Name
          Text(instance.badgeclass.name, style: textTheme.titleMedium),
          const SizedBox(height: 12),
          // Chips
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              // TODO: add other chips (need to see where the data comes from)
              buildChip(
                icon: Assets.iconDate,
                text: DateFormat(
                  'd MMM, yyyy',
                  l10n.localeName,
                ).format(instance.issuedOn),
                context: context,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Institution
          if (institution != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // TODO: add no image paceholder
                if (institutionImageUrl != null)
                  Image.network(
                    institutionImageUrl,
                    height: 25,
                    width: 25,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(height: 25, width: 25);
                    },
                  ),
                const SizedBox(width: 8),
                Text(institutionName),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildChip({
    required String icon,
    required String text,
    required BuildContext context,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final onPrimaryContainer = Theme.of(context).colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.only(left: 8, right: 12, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        spacing: 6,
        children: [
          SvgPicture.asset(
            icon,
            height: 18,
            width: 18,
            colorFilter: ColorFilter.mode(onPrimaryContainer, BlendMode.srcIn),
          ),
          Text(
            text,
            style: textTheme.labelMedium?.copyWith(
              color: onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
