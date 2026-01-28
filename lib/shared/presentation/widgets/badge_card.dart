import 'package:collection/collection.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/utils/image.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

enum BadgeCardStyle { small, large }

class BadgeCard extends StatelessWidget {
  final BadgeInstanceEntity instance;
  final BadgeCardStyle style;
  final bool isSelected;
  const BadgeCard({
    super.key,
    required this.instance,
    this.style = BadgeCardStyle.large,
    this.isSelected = false,
  });

  int? getTimeInvestment() {
    final match = instance.badgeclass.badgeclassextensionSet?.firstWhereOrNull(
      (element) => element.name == 'extensions:TimeInvestmentExtension',
    );
    return match != null ? int.tryParse(match.value) : null;
  }

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

    if (style == BadgeCardStyle.small) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
          ),
          color: isSelected
              ? colorScheme.surface
              : colorScheme.surfaceContainer,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          spacing: 12,
          children: [
            // TODO: add no image paceholder (https://digitalclub.atlassian.net/browse/SURF-517)
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

    int? timeInvestment = getTimeInvestment();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
        color: isSelected ? colorScheme.surface : colorScheme.surfaceContainer,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32, width: 32),
              // TODO: add no image paceholder (https://digitalclub.atlassian.net/browse/SURF-517)
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
          Text(
            instance.badgeclass.name,
            style: textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              if (timeInvestment != null)
                buildChip(
                  icon: Assets.iconTimeInvestment,
                  text: l10n.countHours(timeInvestment),
                  context: context,
                ),
              if (instance.gradeAchieved != null)
                buildChip(
                  icon: Assets.iconCollections,
                  text: instance.gradeAchieved!,
                  context: context,
                ),
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
          if (institution != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // TODO: add no image paceholder (https://digitalclub.atlassian.net/browse/SURF-517)
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
                Flexible(
                  child: Text(
                    institutionName,
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
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
        mainAxisSize: MainAxisSize.min,
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
