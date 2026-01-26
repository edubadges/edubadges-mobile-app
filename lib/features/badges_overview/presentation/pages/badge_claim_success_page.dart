import 'dart:async';

import 'package:collection/collection.dart';
import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/widgets/badge_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      body: badgesState.when(
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
              // Initial screen
              if (!_showDetails)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      spacing: 16,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          Assets.iconBackpack,
                          width: 48,
                          height: 48,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              l10n.badgeClaimSuccessTitle,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.badgeClaimSuccessSubtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Animated details
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
                          const SizedBox(height: 16),
                          _buildVisibilityPlaceholder(context),
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
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildVisibilityPlaceholder(BuildContext context) {
    // TODO: Implement visibility container
    return SizedBox(height: 100, child: Placeholder());
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
