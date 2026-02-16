import 'package:collection/collection.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/image.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/features/badge_details/data/models/badge_details_route_model.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_route_from.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/presentation/widgets/badge_visibility_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum BadgeCardStyle { small, large }

class BadgeCard extends ConsumerWidget {
  final BadgeInstanceEntity? instance;
  final BadgeClassModel badgeClass;
  final BadgeCardStyle style;
  final bool isSelected, onTapDisabled;
  final BadgeDetailsRouteFrom onTapFrom;
  const BadgeCard({
    super.key,
    required this.instance,
    required this.badgeClass,
    this.style = BadgeCardStyle.large,
    this.isSelected = false,
    this.onTapDisabled = false,
    this.onTapFrom = BadgeDetailsRouteFrom.other,
  });

  int? getTimeInvestment() {
    final match = badgeClass.badgeclassextensionSet?.firstWhereOrNull(
      (element) => element.name == 'extensions:TimeInvestmentExtension',
    );
    if (match?.value is int) {
      return match!.value;
    }
    return match != null ? int.tryParse(match.value) : null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final institution = badgeClass.issuer?.faculty?.institution;
    final langCode = ref.read(appLanguageProvider).code;
    final institutionName = getLocalizedString(
      institution?.nameDutch,
      institution?.nameEnglish,
      langCode,
    );
    final institutionImageUrl = buildImageUrl(institution?.imageDutch);
    final badgeImageUrl = buildImageUrl(badgeClass.image);

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
                    badgeClass.name,
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

    return GestureDetector(
      onTap: onTapDisabled
          ? null
          : () {
              final routeModel = BadgeDetailsRouteModel(
                id: instance?.entityId ?? badgeClass.entityId,
                from: onTapFrom,
              );
              context.push(routeModel.buildRouteUrl());
            },
      child: Container(
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
                if (instance != null)
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: GestureDetector(
                      child: SvgPicture.asset(
                        instance!.public
                            ? Assets.iconUnlocked
                            : Assets.iconLocked,
                      ),
                      onTap: () {
                        BadgeVisibilityDialog.show(
                          context: context,
                          ref: ref,
                          badgeInstance: instance as BadgeInstanceModel,
                          isPublic: !instance!.public,
                        );
                      },
                    ),
                  )
                else
                  const SizedBox(height: 32, width: 32),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              badgeClass.name,
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
                if (instance?.gradeAchieved != null && instance!.includeGradeAchieved)
                  buildChip(
                    icon: Assets.iconCollections,
                    text: instance!.gradeAchieved!,
                    context: context,
                  ),
                if (instance?.issuedOn != null)
                  buildChip(
                    icon: Assets.iconDate,
                    text: DateFormat(
                      'd MMM, yyyy',
                      l10n.localeName,
                    ).format(instance!.issuedOn!),
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
