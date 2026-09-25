import 'package:collection/collection.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/image.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/core/widgets/app_network_image.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/keyboard_activatable.dart';
import 'package:edubadges/core/widgets/svg_icon.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_scope.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/features/badges_overview/utils/badge_terms_agreement_utils.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/presentation/widgets/badge_grid_tile.dart';
import 'package:edubadges/shared/presentation/widgets/wide_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum BadgeCardStyle { small, large, grid }

class BadgeCard extends ConsumerWidget {
  final BadgeInstanceEntity? instance;
  final BadgeClassModel badgeClass;
  final BadgeCardStyle style;
  final bool isSelected, onTapDisabled, badgeRequested;

  /// When set, navigation uses this scope and [badgeNavigationEntityId] instead
  /// of inferring claimed vs public from [instance].
  final BadgeDetailsScope? badgeNavigationScope;
  final String? badgeNavigationEntityId;

  /// Only applies when opening as [BadgeDetailsScope.claimed] (backpack carousel).
  final bool showClaimedGalleryOnOpen;

  final VoidCallback? onTap;

  /// Shown at the end of the row for [BadgeCardStyle.small], e.g. a selection
  /// checkbox. Ignored by the other styles.
  final Widget? trailing;

  const BadgeCard({
    super.key,
    required this.instance,
    required this.badgeClass,
    this.style = BadgeCardStyle.large,
    this.isSelected = false,
    this.onTapDisabled = false,
    this.badgeRequested = false,
    this.badgeNavigationScope,
    this.badgeNavigationEntityId,
    this.showClaimedGalleryOnOpen = false,
    this.onTap,
    this.trailing,
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

  List<BadgeInfoChipData> _buildInfoChips(AppLocalizations l10n) {
    final int? timeInvestment = getTimeInvestment();
    final BadgeInstanceEntity? badgeInstance = instance;
    final String? gradeAchieved = badgeInstance is BadgeInstanceModel
        ? badgeInstance.gradeAchieved
        : null;

    return [
      if (timeInvestment != null)
        BadgeInfoChipData(
          icon: Assets.iconTimeInvestment,
          label: l10n.countHours(timeInvestment),
        ),
      if (gradeAchieved != null)
        BadgeInfoChipData(icon: Assets.iconCollections, label: gradeAchieved),
      if (badgeInstance?.issuedOn != null)
        BadgeInfoChipData(
          icon: Assets.iconDate,
          label: DateFormat(
            'd MMM, yyyy',
            l10n.localeName,
          ).format(badgeInstance!.issuedOn!),
        ),
    ];
  }

  void _openDetails(BuildContext context) {
    final scope =
        badgeNavigationScope ??
        (instance != null
            ? BadgeDetailsScope.claimed
            : BadgeDetailsScope.public);
    final id =
        badgeNavigationEntityId ?? (instance?.entityId ?? badgeClass.entityId);
    final gallery =
        scope != BadgeDetailsScope.claimed || showClaimedGalleryOnOpen;
    context.push(
      RoutePath.badgeDetailsLocation(scope: scope, id: id, gallery: gallery),
    );
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

    if (style == BadgeCardStyle.grid) {
      final BadgeInstanceEntity? badgeInstance = instance;
      return BadgeGridTile(
        imageUrl: badgeImageUrl,
        name: badgeClass.name,
        institutionName: institutionName,
        institutionImageUrl: institutionImageUrl,
        chips: _buildInfoChips(l10n),
        isPublic: badgeInstance?.public,
        visibilityLabel: badgeInstance == null
            ? null
            : badgeInstance.public
            ? l10n.semanticsBadgeVisibilityPublic
            : l10n.semanticsBadgeVisibilityPrivate,
        imageSemanticLabel: l10n.semanticsBadgeImage,
        onTap: onTapDisabled ? null : (onTap ?? () => _openDetails(context)),
      );
    }

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
              child: AppNetworkImage(
                imageUrl: badgeImageUrl ?? '',
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
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
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

    final Widget largeContent = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32, width: 32),
            Expanded(
              child: ExcludeSemantics(
                child: AppNetworkImage(
                  imageUrl: badgeImageUrl ?? '',
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
            for (final BadgeInfoChipData chip in _buildInfoChips(l10n))
              BadgeInfoChip(icon: chip.icon, label: chip.label),
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
                  child: AppNetworkImage(
                    imageUrl: institutionImageUrl,
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
          _buildEnrollmentSection(context, ref, l10n, textTheme, colorScheme),
      ],
    );

    return KeyboardActivatable(
      enabled: !onTapDisabled,
      onActivate: onTapDisabled ? null : () => _openDetails(context),
      child: Container(
        width: double.infinity,
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
        child: largeContent,
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
          try {
            final langCode = ref.read(appLanguageProvider).code;
            final List<TermsAgreementEntity> profileAgreements =
                ref.read(profileProvider).value?.termsagreementSet ?? [];
            if (shouldPromptForBadgeTerms(
              badgeClass: badgeClass,
              profileAgreements: profileAgreements,
              languageCode: langCode,
            )) {
              if (context.mounted) {
                await context.push(
                  RoutePath.badgeEnrollmentTermsPath(id: badgeClass.entityId),
                );
              }
              return;
            }
            final enrolled = await ref.read(enrollBadgeProvider)(
              badgeClass.entityId,
            );
            if (!enrolled && context.mounted) {
              showAppSnackBar(context, l10n.somethingWentWrong);
            }
          } catch (error) {
            if (!context.mounted) return;
            final errorMessage = switch (error) {
              Failure(:final message) => message,
              _ => error.toString(),
            };
            showAppSnackBar(context, errorMessage);
          }
        },
        color: colorScheme.primary,
      ),
    );
  }
}
