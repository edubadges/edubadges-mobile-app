import 'package:collection/collection.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/error_message.dart';
import 'package:edubadges/core/utils/image.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/core/widgets/adaptive_dialog.dart';
import 'package:edubadges/core/widgets/app_network_image.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/focus_ring_overlay.dart';
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
import 'package:edubadges/shared/presentation/widgets/badge_issuer_label.dart';
import 'package:edubadges/shared/presentation/widgets/list_row_card.dart';
import 'package:edubadges/shared/presentation/widgets/wide_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum BadgeCardStyle { small, large, grid }

class BadgeCard extends ConsumerWidget {
  static const double _visibilityIconSize = 32;

  final BadgeInstanceEntity? instance;
  final BadgeClassModel badgeClass;
  final BadgeCardStyle style;
  final bool isSelected, onTapDisabled, badgeRequested;

  /// When the pending request was made; shown next to [badgeRequested].
  final DateTime? requestedOn;

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

  /// Border of an unselected [BadgeCardStyle.small] card; defaults to
  /// `outlineVariant`. Ignored by the other styles.
  final Color? borderColor;

  const BadgeCard({
    super.key,
    required this.instance,
    required this.badgeClass,
    this.style = BadgeCardStyle.large,
    this.isSelected = false,
    this.onTapDisabled = false,
    this.badgeRequested = false,
    this.requestedOn,
    this.badgeNavigationScope,
    this.badgeNavigationEntityId,
    this.showClaimedGalleryOnOpen = false,
    this.onTap,
    this.trailing,
    this.borderColor,
  });

  int? getTimeInvestment() => _timeInvestment(badgeClass);

  static int? _timeInvestment(BadgeClassModel badgeClass) {
    final match = badgeClass.badgeclassextensionSet?.firstWhereOrNull(
      (element) => element.name == 'extensions:TimeInvestmentExtension',
    );
    if (match?.value is int) {
      return match!.value as int;
    }
    return match != null ? int.tryParse(match.value.toString()) : null;
  }

  /// The chips a card shows for [badgeClass], and for [instance] once awarded.
  /// Grids use it to size their tiles before building them.
  static List<BadgeInfoChipData> infoChips({
    required BadgeInstanceEntity? instance,
    required BadgeClassModel badgeClass,
    required AppLocalizations l10n,
  }) {
    final int? timeInvestment = _timeInvestment(badgeClass);
    final String? gradeAchieved = instance is BadgeInstanceModel
        ? instance.gradeAchieved
        : null;

    return [
      if (timeInvestment != null)
        BadgeInfoChipData(
          icon: Assets.iconTimeInvestment,
          label: l10n.countHours(timeInvestment),
        ),
      if (gradeAchieved != null)
        BadgeInfoChipData(icon: Assets.iconCollections, label: gradeAchieved),
      if (instance?.issuedOn != null)
        BadgeInfoChipData(
          icon: Assets.iconDate,
          label: DateFormat(
            'd MMM, yyyy',
            l10n.localeName,
          ).format(instance!.issuedOn!),
        ),
    ];
  }

  List<BadgeInfoChipData> _buildInfoChips(AppLocalizations l10n) =>
      infoChips(instance: instance, badgeClass: badgeClass, l10n: l10n);

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
    final langCode = ref.watch(appLanguageProvider).code;
    final issuerName = getLocalizedString(
      badgeClass.issuer?.nameDutch,
      badgeClass.issuer?.nameEnglish,
      langCode,
    );
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
        issuerName: issuerName,
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
      return ListRowCard(
        imageUrl: badgeImageUrl,
        title: badgeClass.name,
        issuerName: issuerName,
        institutionName: institutionName,
        isSelected: isSelected,
        borderColor: borderColor,
        trailing: trailing,
        onTap: onTapDisabled ? null : onTap,
      );
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
        if (institution != null || issuerName.isNotEmpty)
          BadgeIssuerLabel(
            issuerName: issuerName,
            institutionName: institutionName,
            logoUrl: institutionImageUrl,
            centered: true,
          ),
        if (instance == null &&
            badgeClass.userMayEnroll &&
            badgeClass.selfEnrollmentEnabled)
          _buildEnrollmentSection(context, ref, l10n, textTheme, colorScheme),
      ],
    );

    return FocusRingShape.rounded(
      borderRadius: BorderRadius.circular(20),
      child: KeyboardActivatable(
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
          child: Stack(
            children: [
              largeContent,
              // Shown on the badge itself, so its visibility reads at a glance.
              if (instance != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: SvgIcon(
                    assetPath: instance!.public
                        ? Assets.iconUnlocked
                        : Assets.iconLocked,
                    size: _visibilityIconSize,
                    semanticLabel: instance!.public
                        ? l10n.semanticsBadgeVisibilityPublic
                        : l10n.semanticsBadgeVisibilityPrivate,
                  ),
                ),
            ],
          ),
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
        child: Column(
          children: [
            Container(
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
                    requestedOn != null
                        ? l10n.edubadgeRequestedOn(
                            DateFormat(
                              'd MMM, yyyy',
                              l10n.localeName,
                            ).format(requestedOn!),
                          )
                        : l10n.edubadgeRequested,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            _CancelRequestButton(badgeClassId: badgeClass.entityId),
          ],
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

class _CancelRequestButton extends ConsumerStatefulWidget {
  const _CancelRequestButton({required this.badgeClassId});

  final String badgeClassId;

  @override
  ConsumerState<_CancelRequestButton> createState() =>
      _CancelRequestButtonState();
}

class _CancelRequestButtonState extends ConsumerState<_CancelRequestButton> {
  bool _isCancelling = false;

  Future<void> _cancelRequest() async {
    if (_isCancelling) return;

    setState(() => _isCancelling = true);
    final result = await ref.read(cancelEnrollmentProvider)(
      widget.badgeClassId,
    );
    if (!mounted) return;

    result.fold(
      (failure) {
        showAppSnackBar(context, messageFromFailure(context, failure));
        setState(() => _isCancelling = false);
      },
      (_) {
        showAppSnackBar(
          context,
          AppLocalizations.of(context).cancelRequestSuccess,
        );
        setState(() => _isCancelling = false);
      },
    );
  }

  Future<void> _confirmCancel() async {
    if (_isCancelling) return;

    final l10n = AppLocalizations.of(context);
    await AdaptiveDialog.show(
      context: context,
      config: AdaptiveDialogConfig(
        title: l10n.cancelRequestTitle,
        description: l10n.cancelRequestConfirmation,
        firstButtonText: l10n.cancel,
        secondButtonText: l10n.confirm,
        onFirstButtonPressed: () {},
        onSecondButtonPressed: () {
          _cancelRequest();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return WideButton(
      text: l10n.cancelRequestButton,
      icon: null,
      secondary: true,
      color: colorScheme.primary,
      onTap: _isCancelling ? null : _confirmCancel,
    );
  }
}
