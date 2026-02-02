import 'dart:async';

import 'package:collection/collection.dart';
import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/widgets/info_state_view.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/features/badge_details/presentation/widgets/badge_visibility_card.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/widgets/badge_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BadgeClaimSuccessPage extends ConsumerStatefulWidget {
  final String badgeId;

  const BadgeClaimSuccessPage({super.key, required this.badgeId});

  @override
  ConsumerState<BadgeClaimSuccessPage> createState() =>
      _BadgeClaimSuccessPageState();
}

class _BadgeClaimSuccessPageState extends ConsumerState<BadgeClaimSuccessPage>
    with SingleTickerProviderStateMixin {
  bool _showDetails = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    Timer(const Duration(milliseconds: 750), () {
      if (mounted) {
        setState(() {
          _showDetails = true;
          _animationController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final badgesState = ref.watch(badgesOverviewProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.primary),
            onPressed: () => context.go(RoutePath.main),
          ),
        ],
      ),
      body: MaxWidthWrapper(
        child: badgesState.when(
          data: (state) {
            final claimedBadge =
                state.claimedBadges.firstWhereOrNull(
                  (b) =>
                      b.entityId == widget.badgeId ||
                      b.id.toString() == widget.badgeId,
                ) ??
                state.claimedBadges.firstOrNull;

            if (claimedBadge == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final hasMoreBadges = state.unclaimedBadges.isNotEmpty;

            return Stack(
              children: [
                if (!_showDetails)
                  InfoStateView(
                    assetPath: Assets.iconBackpack,
                    title: l10n.badgeClaimSuccessTitle,
                    description: l10n.badgeClaimSuccessSubtitle,
                  ),

                if (_showDetails)
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BadgeCard(
                              instance: claimedBadge,
                              style: BadgeCardStyle.large,
                            ),
                            BadgeVisibilityCard(
                              margin: const EdgeInsets.only(bottom: 8, top: 16),
                              badge: claimedBadge,
                            ),
                            const Spacer(),
                            _buildBottomButton(
                              context,
                              hasMoreBadges,
                              state.unclaimedBadges.length,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => InfoStateView(
            title: l10n.badgeClaimErrorTitle,
            description: l10n.badgeClaimErrorSubtitle,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
    bool hasMoreBadges,
    int count,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (hasMoreBadges) {
      return TextButton(
        onPressed: () {
          final nextBadgeId = ref
              .read(badgesOverviewProvider)
              .asData
              ?.value
              .unclaimedBadges
              .first
              .id
              .toString();
          if (nextBadgeId != null) {
            context.pushReplacement(
              '${RoutePath.badgeClaim.replaceAll(':id', nextBadgeId)}?remainingCount=$count',
            );
          }
        },
        child: Text(
          l10n.claimNextBadge(count),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.primary,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return TextButton(
        onPressed: () => context.go(RoutePath.main),
        child: Text(
          l10n.goToOverview,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.primary,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }
}
