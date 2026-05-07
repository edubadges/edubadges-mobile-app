import 'package:collection/collection.dart';
import 'package:edubadges/app/colors.dart';
import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/core/widgets/actionable_content_layout.dart';
import 'package:edubadges/core/widgets/adaptive_dialog.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/info_state_view.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/features/account/data/models/agreement_route_model.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/presentation/providers/markdown_fetcher.dart';
import 'package:edubadges/shared/presentation/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BadgePrivacyPage extends ConsumerStatefulWidget {
  final String badgeId;

  const BadgePrivacyPage({super.key, required this.badgeId});

  @override
  ConsumerState<BadgePrivacyPage> createState() => _BadgePrivacyPageState();
}

class _BadgePrivacyPageState extends ConsumerState<BadgePrivacyPage> {
  bool _isClaiming = false;
  bool _isDeclining = false;
  bool _isShowingLongVersion = false;
  bool _hasInitializedToggle = false;

  void _handleDecline(BadgeInstanceEntity badge) {
    final l10n = AppLocalizations.of(context);

    AdaptiveDialog.show(
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
                  showAppSnackBar(context, failure.toString());
                  setState(() {
                    _isDeclining = false;
                  });
                }
              },
              (_) {
                if (mounted) {
                  ref.read(badgesOverviewProvider.notifier).refresh();
                  context.go(RoutePath.main);
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

  Future<void> _handleAccept(BadgeInstanceEntity badge) async {
    setState(() {
      _isClaiming = true;
    });

    try {
      final repository = ref.read(badgesOverviewRepositoryProvider);
      final result = await repository.claimBadge(badge.entityId);

      result.fold(
        (failure) {
          if (mounted) {
            showAppSnackBar(context, failure.toString());
            setState(() {
              _isClaiming = false;
            });
          }
        },
        (_) {
          if (mounted) {
            ref.read(badgesOverviewProvider.notifier).refresh();
            context.go(
              RoutePath.badgeClaimSuccessPath(
                id: badge.badgeclass.entityId,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          AppLocalizations.of(context).somethingWentWrong,
        );
        setState(() {
          _isClaiming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final langCode = ref.watch(appLanguageProvider).code;

    final badgesAsync = ref.watch(badgesOverviewProvider);
    final profileAsync = ref.watch(profileProvider);

    return MaxWidthWrapper(
      child: badgesAsync.when(
        data: (state) {
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
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: AppLocalizations.of(context).semanticsLoading,
                ),
              ),
            );
          }

          final badgeInstitutionId =
              badge.badgeclass.issuer?.faculty?.institution?.identifier;

          final profile = profileAsync.whenOrNull(data: (p) => p);
          if (profile == null) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: AppLocalizations.of(context).semanticsLoading,
                ),
              ),
            );
          }

          final matchingAgreement = profile.termsagreementSet.firstWhereOrNull(
            (TermsAgreementEntity ta) =>
                ta.terms.institution?.identifier == badgeInstitutionId,
          );

          if (matchingAgreement == null) {
            return Scaffold(
              body: Center(
                child: InfoStateView(
                  assetPath: Assets.iconInfo,
                  description: l10n.somethingWentWrong,
                ),
              ),
            );
          }

          final institutionName = getLocalizedString(
            matchingAgreement.terms.institution?.nameDutch,
            matchingAgreement.terms.institution?.nameEnglish,
            langCode,
          );

          final agreementModel = AgreementRouteModel.create(
            institutionName,
            matchingAgreement,
            langCode,
          );

          // Initialize toggle state: default to long if no short version
          if (!_hasInitializedToggle) {
            _hasInitializedToggle = true;
            if (agreementModel.titleShort == null ||
                agreementModel.titleShort!.trim().isEmpty) {
              _isShowingLongVersion = true;
            }
          }

          final currentTitle = _isShowingLongVersion
              ? agreementModel.titleLong
              : (agreementModel.titleShort?.trim().isEmpty ?? true
                    ? agreementModel.titleLong
                    : agreementModel.titleShort!);
          final currentUrlText = _isShowingLongVersion
              ? agreementModel.textUrlLong
              : (agreementModel.textUrlShort?.trim().isEmpty ?? true
                    ? agreementModel.textUrlLong
                    : agreementModel.textUrlShort!);
          final toggleButtonText = _isShowingLongVersion
              ? l10n.viewShortText
              : l10n.viewFullText;

          final markdownAsyncValue = ref.watch(
            markdownFetcherProvider(currentUrlText),
          );

          return ActionableContentLayout(
            title: currentTitle,
            error: markdownAsyncValue.hasError,
            content: markdownAsyncValue.when(
              data: (data) {
                return MarkdownBody(
                  data: filterBadMarkdown(data),
                  styleSheet: AppThemes.markdownStyleSheet(context).copyWith(
                    h1: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
              error: (error, stackTrace) {
                return Center(
                  child: InfoStateView(
                    assetPath: Assets.iconInfo,
                    description: l10n.failedToLoadTermsFrom(
                      agreementModel.titleLong,
                    ),
                  ),
                );
              },
              loading: () {
                return Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: AppLocalizations.of(
                      context,
                    ).semanticsLoading,
                  ),
                );
              },
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isClaiming || _isDeclining
                      ? null
                      : () => _handleAccept(badge),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isClaiming
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            semanticsLabel: AppLocalizations.of(
                              context,
                            ).semanticsLoading,
                          ),
                        )
                      : Text(
                          l10n.badgePrivacyReadButton,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
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
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: _isDeclining
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            semanticsLabel: AppLocalizations.of(
                              context,
                            ).semanticsLoading,
                          ),
                        )
                      : Text(
                          l10n.decline,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              if (agreementModel.textUrlShort?.isEmpty != true)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isShowingLongVersion = !_isShowingLongVersion;
                    });
                  },
                  child: Text(
                    toggleButtonText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              semanticsLabel: AppLocalizations.of(context).semanticsLoading,
            ),
          ),
        ),
        error: (err, stack) =>
            const Scaffold(body: Center(child: ErrorMessageWidget())),
      ),
    );
  }
}
