import 'package:collection/collection.dart';
import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/constants/mock_data.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/widgets/actionable_content_layout.dart';
import 'package:edubadges/core/widgets/adaptive_dialog.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/core/widgets/link_text.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:flutter/material.dart';
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
            context.go('${RoutePath.badgeClaimSuccess}?id=${badge.id}');
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

    final badgesAsync = ref.watch(badgesOverviewProvider);

    final currentTitle = _isShowingLongVersion
        ? MockData.privacyAgreementTitleLong
        : MockData.privacyAgreementTitle;

    final currentText = _isShowingLongVersion
        ? MockData.privacyAgreementTextLong
        : MockData.privacyAgreementTextShort;

    final toggleButtonText = _isShowingLongVersion
        ? l10n.viewShortText
        : l10n.viewFullText;

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
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return ActionableContentLayout(
            title: currentTitle,
            content: LinkText(
              text: currentText,
              style: theme.textTheme.bodyMedium,
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
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
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
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
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
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) =>
            Scaffold(body: Center(child: Text('Error: $err'))),
      ),
    );
  }
}
