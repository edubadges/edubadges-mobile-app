import 'package:collection/collection.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/image.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/keyboard_activatable.dart';
import 'package:edubadges/core/widgets/svg_icon.dart';
import 'package:edubadges/features/badge_details/data/models/badge_details_route_model.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_route_from.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/presentation/widgets/badge_visibility_dialog.dart';
import 'package:edubadges/shared/presentation/widgets/wide_button.dart';
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
  final bool isSelected, onTapDisabled, badgeRequested;
  final BadgeDetailsRouteFrom onTapFrom;

  final VoidCallback? onTap;

  const BadgeCard({
    super.key,
    required this.instance,
    required this.badgeClass,
    this.style = BadgeCardStyle.large,
    this.isSelected = false,
    this.onTapDisabled = false,
    this.badgeRequested = false,
    this.onTapFrom = BadgeDetailsRouteFrom.other,
    this.onTap,
  });

  int? getTimeInvestment() {
    final match = badgeClass.badgeclassextensionSet?.firstWhereOrNull(
      (element) => element.name == 'extensions:TimeInvestmentExtension',
    );
    if (match?.value is int) {
      return match!.value as int;
    }
    return match != null ? int.tryParse(match.value.toString()) : null;
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
      final cardContent = Container(
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
          children: [
            ExcludeSemantics(
              child: Image.network(
                badgeImageUrl ?? '',
                height: 64,
                width: 64,
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                    height: 64,
                    width: 64,
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
              child: MergeSemantics(
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
            ),
          ],
        ),
      );

      final effectiveOnTap = onTapDisabled ? null : onTap;
      if (effectiveOnTap != null) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: effectiveOnTap,
            child: cardContent,
          ),
        );
      }

      return cardContent;
    }

    final int? timeInvestment = getTimeInvestment();

    return KeyboardActivatable(
      enabled: !onTapDisabled,
      onActivate: onTapDisabled
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
                Expanded(
                  child: ExcludeSemantics(
                    child: Image.network(
                      badgeImageUrl ?? '',
                      height: 100,
                      width: 100,
                      semanticLabel: l10n.semanticsBadgeImage,
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          height: 100,
                          width: 100,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (instance != null)
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: KeyboardActivatable(
                      semanticLabel: instance!.public
                          ? l10n.semanticsBadgePublic
                          : l10n.semanticsBadgePrivate,
                      onActivate: () {
                        BadgeVisibilityDialog.show(
                          context: context,
                          ref: ref,
                          badgeInstance: instance as BadgeInstanceModel,
                          isPublic: !instance!.public,
                        );
                      },
                      child: SvgPicture.asset(
                        instance!.public
                            ? Assets.iconUnlocked
                            : Assets.iconLocked,
                      ),
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
                if (instance is BadgeInstanceModel &&
                    (instance as BadgeInstanceModel).gradeAchieved != null &&
                    (instance as BadgeInstanceModel).includeGradeAchieved)
                  buildChip(
                    icon: Assets.iconCollections,
                    text: (instance as BadgeInstanceModel).gradeAchieved!,
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
                  if (institutionImageUrl != null)
                    ExcludeSemantics(
                      child: Image.network(
                        institutionImageUrl,
                        height: 25,
                        width: 25,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(height: 25, width: 25);
                        },
                      ),
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
            if (instance == null &&
                badgeClass.userMayEnroll &&
                badgeClass.selfEnrollmentEnabled)
              _buildEnrollmentSection(
                context,
                ref,
                l10n,
                textTheme,
                colorScheme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentSection(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    if (badgeRequested) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          margin: const EdgeInsets.only(
            left: 12,
            right: 16,
            top: 10,
            bottom: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              SvgIcon(
                assetPath: Assets.iconCheck,
                size: 20,
                color: colorScheme.primary,
              ),
              Text(
                l10n.edubadgeRequested,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: WideButton(
        text: l10n.badgeRequestButton,
        icon: null,
        onTap: () async {
          final enrolled = await ref.read(enrollBadgeProvider)(
            badgeClass.entityId,
          );
          if (!enrolled && context.mounted) {
            showAppSnackBar(context, l10n.somethingWentWrong);
          }
        },
        color: colorScheme.primary,
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
        children: [
          SvgPicture.asset(
            icon,
            height: 18,
            width: 18,
            colorFilter: ColorFilter.mode(onPrimaryContainer, BlendMode.srcIn),
          ),
          const SizedBox(width: 6),
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
