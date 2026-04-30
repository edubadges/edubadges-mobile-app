import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/widgets/info_state_view.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/features/badge_details/presentation/widgets/badge_visibility_card.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
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
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    const springCurve = _SpringCurve(
      mass: 1.0,
      stiffness: 256.1,
      damping: 24.0,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: springCurve,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: springCurve),
        );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(badgesOverviewProvider.notifier).refresh();
    });

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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final badgesState = ref.watch(badgesOverviewProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        leading: const SizedBox.shrink(),
        actions: [
          FadeTransition(
            opacity: _opacityAnimation,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.primary),
              onPressed: () => context.go(RoutePath.main),
              tooltip: AppLocalizations.of(context).semanticsClose,
            ),
          ),
        ],
      ),
      body: MaxWidthWrapper(
        child: badgesState.when(
          data: (state) {
            // Check claimed badges first, but also check unclaimed badges
            // in case the state hasn't been updated yet from the claim page
            final claimedBadge =
                state.claimedBadges.firstWhereOrNull(
                  (b) =>
                      b.entityId == widget.badgeId ||
                      b.id.toString() == widget.badgeId,
                ) ??
                state.unclaimedBadges.firstWhereOrNull(
                  (b) =>
                      b.entityId == widget.badgeId ||
                      b.id.toString() == widget.badgeId,
                ) ??
                state.claimedBadges.firstOrNull;

            if (claimedBadge == null) {
              return Center(
                child: CircularProgressIndicator(
                  semanticsLabel: AppLocalizations.of(context).semanticsLoading,
                ),
              );
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
                  SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BadgeCard(
                                instance: claimedBadge,
                                badgeClass:
                                    claimedBadge.badgeclass as BadgeClassModel,
                                style: BadgeCardStyle.large,
                              ),
                              BadgeVisibilityCard(
                                margin: const EdgeInsets.only(
                                  bottom: 8,
                                  top: 16,
                                ),
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
                  ),
              ],
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(
              semanticsLabel: AppLocalizations.of(context).semanticsLoading,
            ),
          ),
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
    final l10n = AppLocalizations.of(context);
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
              RoutePath.badgeClaimPath(
                id: nextBadgeId,
                remainingCount: count,
              ),
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

class _SpringCurve extends Curve {
  final double mass;
  final double stiffness;
  final double damping;

  const _SpringCurve({
    required this.mass,
    required this.stiffness,
    required this.damping,
  });

  @override
  double transformInternal(double t) {
    // Spring physics calculation
    final dampingRatio = damping / (2 * sqrt(mass * stiffness));
    final angularFrequency = sqrt(stiffness / mass);

    if (dampingRatio < 1) {
      // Under-damped spring (bouncy)
      final dampedFrequency =
          angularFrequency * sqrt(1 - dampingRatio * dampingRatio);
      final envelope = exp(-dampingRatio * angularFrequency * t);
      final phase = dampedFrequency * t;
      return 1 -
          envelope *
              (cos(phase) +
                  (dampingRatio * angularFrequency / dampedFrequency) *
                      sin(phase));
    } else if (dampingRatio == 1) {
      // Critically damped
      final decay = exp(-angularFrequency * t);
      return 1 - decay * (1 + angularFrequency * t);
    } else {
      // Over-damped
      final r1 =
          -angularFrequency *
          (dampingRatio + sqrt(dampingRatio * dampingRatio - 1));
      final r2 =
          -angularFrequency *
          (dampingRatio - sqrt(dampingRatio * dampingRatio - 1));
      final c1 = (0 - r2) / (r1 - r2);
      final c2 = 1 - c1;
      return 1 - (c1 * exp(r1 * t) + c2 * exp(r2 * t));
    }
  }
}
