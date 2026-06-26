import 'dart:async';

import 'package:collection/collection.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/utils/image.dart';
import 'package:edubadges/core/widgets/adaptive_dialog.dart';
import 'package:edubadges/core/widgets/app_network_image.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/core/widgets/primary_button.dart';
import 'package:edubadges/features/badges_overview/domain/entities/direct_award_detail_entity.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/presentation/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BadgeClaimPage extends ConsumerStatefulWidget {
  final String badgeId;
  final int remainingCount;
  final VoidCallback? onClose;
  final void Function(String badgeId)? onNavigateToPrivacy;
  final void Function(String badgeClassId)? onNavigateToSuccess;

  const BadgeClaimPage({
    super.key,
    required this.badgeId,
    required this.remainingCount,
    this.onClose,
    this.onNavigateToPrivacy,
    this.onNavigateToSuccess,
  });

  @override
  ConsumerState<BadgeClaimPage> createState() => _BadgeClaimPageState();
}

class _BadgeClaimPageState extends ConsumerState<BadgeClaimPage> {
  bool _isClaiming = false;
  bool _isDeclining = false;

  String _getErrorMessage(Failure failure, AppLocalizations l10n) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return failure.message;
    }
    return l10n.somethingWentWrong;
  }

  Future<void> _handleClaim(
    BadgeInstanceEntity badge,
    AsyncValue<DirectAwardDetailEntity> detailAsync,
  ) async {
    if (_isClaiming || _isDeclining) return;

    final l10n = AppLocalizations.of(context);

    // On error or terms not accepted, go to privacy page
    final detail = detailAsync.whenOrNull(data: (d) => d);
    final needsPrivacyPage =
        detailAsync.hasError || detail == null || !detail.userHasAcceptedTerms;
    if (needsPrivacyPage) {
      if (widget.onNavigateToPrivacy != null) {
        widget.onNavigateToPrivacy!(widget.badgeId);
      } else {
        if (context.mounted) {
          unawaited(
            context.push(RoutePath.badgePrivacyPath(id: widget.badgeId)),
          );
        }
      }
      return;
    }

    setState(() => _isClaiming = true);

    try {
      final repository = ref.read(badgesOverviewRepositoryProvider);
      final result = await repository.claimBadge(badge.entityId);

      result.fold(
        (failure) {
          if (mounted) {
            showAppSnackBar(context, _getErrorMessage(failure, l10n));
            setState(() => _isClaiming = false);
          }
        },
        (_) {
          if (mounted) {
            ref.read(badgesOverviewProvider.notifier).refresh();
            if (widget.onNavigateToSuccess != null) {
              widget.onNavigateToSuccess!(badge.badgeclass.entityId);
            } else {
              context.go(
                RoutePath.badgeClaimSuccessPath(id: badge.badgeclass.entityId),
              );
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, l10n.somethingWentWrong);
        setState(() => _isClaiming = false);
      }
    }
  }

  Future<void> _handleDecline(BadgeInstanceEntity badge) async {
    if (_isClaiming || _isDeclining) return;

    final l10n = AppLocalizations.of(context);

    await AdaptiveDialog.show(
      context: context,
      config: AdaptiveDialogConfig(
        title: l10n.declineBadgeTitle,
        description: l10n.declineBadgeConfirmation,
        secondButtonText: l10n.decline,
        isDestructiveAction: false,
        onFirstButtonPressed: () {},
        onSecondButtonPressed: () async {
          setState(() {
            _isDeclining = true;
          });

          try {
            final repository = ref.read(badgesOverviewRepositoryProvider);
            final result = await repository.declineBadge(badge.entityId);

            result.fold(
              (failure) {
                if (mounted) {
                  showAppSnackBar(context, _getErrorMessage(failure, l10n));
                  setState(() {
                    _isDeclining = false;
                  });
                }
              },
              (_) {
                if (mounted) {
                  ref.read(badgesOverviewProvider.notifier).refresh();
                  Navigator.of(context).pop();
                  if (widget.onClose != null) {
                    widget.onClose!();
                  } else {
                    Navigator.of(context).pop();
                  }
                }
              },
            );
          } catch (e) {
            if (mounted) {
              showAppSnackBar(context, l10n.somethingWentWrong);
              setState(() {
                _isDeclining = false;
              });
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final badgesAsync = ref.watch(badgesOverviewProvider);
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainer,

        leading: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: colorScheme.primary),
            onPressed:
                widget.onClose ??
                () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RoutePath.main);
                  }
                },
            tooltip: l10n.semanticsClose,
          ),
        ],
      ),
      body: MaxWidthWrapper(
        child: badgesAsync.when(
          data: (state) {
            if (state.unclaimedBadges.isEmpty) {
              return Center(
                child: Text(
                  l10n.somethingWentWrong,
                  style: textTheme.bodyMedium,
                ),
              );
            }

            final badge =
                state.unclaimedBadges.firstWhereOrNull(
                  (b) => b.id.toString() == widget.badgeId,
                ) ??
                state.claimedBadges.firstWhereOrNull(
                  (b) => b.id.toString() == widget.badgeId,
                ) ??
                state.unclaimedBadges.firstOrNull ??
                state.claimedBadges.firstOrNull;

            if (badge == null) {
              return Center(
                child: Text(
                  l10n.somethingWentWrong,
                  style: textTheme.bodyMedium,
                ),
              );
            }

            final detailAsync = ref.watch(
              directAwardDetailProvider(badge.entityId),
            );
            final isClaimButtonReady = !detailAsync.isLoading && !_isClaiming;
            final isClaimButtonLoading = detailAsync.isLoading || _isClaiming;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  Center(
                    child: _buildBadgeDisplay(
                      badge,
                      context,
                      l10n,
                      textTheme,
                      colorScheme,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.remainingCount > 1)
                          Text(
                            l10n.badgesRemainingToClaim(widget.remainingCount),
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: l10n.claimEdubadge,
                          isLoading: isClaimButtonLoading,
                          onPressed: isClaimButtonReady && !_isDeclining
                              ? () => _handleClaim(badge, detailAsync)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _isClaiming || _isDeclining
                                ? null
                                : () => _handleDecline(badge),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(color: colorScheme.primary),
                            ),
                            child: _isDeclining
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.primary,
                                      ),
                                      semanticsLabel: AppLocalizations.of(
                                        context,
                                      ).semanticsLoading,
                                    ),
                                  )
                                : Text(
                                    l10n.decline,
                                    style: textTheme.labelLarge?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(
              semanticsLabel: AppLocalizations.of(context).semanticsLoading,
            ),
          ),
          error: (error, stackTrace) => Center(
            child: ErrorMessageWidget(error: error, stackTrace: stackTrace),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeDisplay(
    BadgeInstanceEntity badge,
    BuildContext context,
    AppLocalizations l10n,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final institution = badge.badgeclass.issuer?.faculty?.institution;
    final institutionName =
        (institution?.nameDutch ?? institution?.nameEnglish) ?? 'Unknown';
    final institutionImageUrl = buildImageUrl(institution?.imageDutch);
    final badgeImageUrl = buildImageUrl(badge.badgeclass.image);

    final timeInvestmentMatch = badge.badgeclass.badgeclassextensionSet
        ?.firstWhereOrNull(
          (element) => element.name == 'extensions:TimeInvestmentExtension',
        );
    final timeInvestment = timeInvestmentMatch != null
        ? int.tryParse(timeInvestmentMatch.value as String)
        : null;

    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 180 / 393;

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (badgeImageUrl != null)
            ExcludeSemantics(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 200,
                  maxHeight: 200,
                ),
                child: AppNetworkImage(
                  imageUrl: badgeImageUrl,
                  height: imageSize,
                  width: imageSize,
                  semanticLabel: l10n.semanticsBadgeImage,
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox(
                      height: imageSize,
                      width: imageSize,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            badge.badgeclass.name,
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
                _buildChip(
                  icon: Assets.iconTimeInvestment,
                  text: l10n.countHours(timeInvestment),
                  context: context,
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                ),
              if (badge.gradeAchieved != null)
                _buildChip(
                  icon: Assets.iconCollections,
                  text: badge.gradeAchieved!,
                  context: context,
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                ),
              if (badge.issuedOn != null)
                _buildChip(
                  icon: Assets.iconDate,
                  text: DateFormat(
                    'd MMM yyyy',
                    l10n.localeName,
                  ).format(badge.issuedOn!),
                  context: context,
                  textTheme: textTheme,
                  colorScheme: colorScheme,
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
                    child: AppNetworkImage(
                      imageUrl: institutionImageUrl,
                      height: 25,
                      width: 25,
                      semanticLabel: l10n.semanticsInstitutionLogo,
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
        ],
      ),
    );
  }

  Widget _buildChip({
    required String icon,
    required String text,
    required BuildContext context,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    final onPrimaryContainer = colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.only(left: 8, right: 12, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
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
