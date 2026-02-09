import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/features/badge_details/data/models/badge_details_route_model.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_route_from.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/badges_overview/presentation/widgets/feedback_bottom_sheet.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/presentation/widgets/badge_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class BadgesOverviewPage extends ConsumerWidget {
  const BadgesOverviewPage({super.key});

  void _showFeedbackBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FeedbackBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(badgesOverviewProvider);
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(Assets.imageLogo, width: 131, height: 32),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              Assets.iconFeedback,
              colorFilter: ColorFilter.mode(
                colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => _showFeedbackBottomSheet(context),
          ),
        ],
      ),
      body: MaxWidthWrapper(
        child: badgesAsync.when(
          data: (state) {
            final slivers = <Widget>[];

            if (state.unclaimedCount > 0) {
              final firstBadge = state.unclaimedBadges.first;
              final remainingCount = state.unclaimedBadges.length;

              slivers.add(
                SliverToBoxAdapter(
                  child: InkWell(
                    onTap: () {
                      final claimRoute = RoutePath.badgeClaim.replaceAll(
                        ':id',
                        firstBadge.id.toString(),
                      );
                      context.push(
                        '$claimRoute?remainingCount=$remainingCount',
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            Assets.iconParty,
                            colorFilter: ColorFilter.mode(
                              colorScheme.onPrimary,
                              BlendMode.srcIn,
                            ),
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.newBadgeReady(state.unclaimedCount),
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          SvgPicture.asset(
                            Assets.iconChevron,
                            colorFilter: ColorFilter.mode(
                              colorScheme.onPrimary,
                              BlendMode.srcIn,
                            ),
                            width: 12,
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            if (state.claimedBadges.isNotEmpty) {
              slivers.add(
                SliverPadding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final badge = state.claimedBadges[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () {
                            final routeModel = BadgeDetailsRouteModel(
                              id: badge.entityId,
                              from: BadgeDetailsRouteFrom.overview,
                            );
                            context.push(routeModel.buildRouteUrl());
                          },
                          child: BadgeCard(
                            instance: badge,
                            badgeClass: badge.badgeclass as BadgeClassModel,
                            style: BadgeCardStyle.small,
                          ),
                        ),
                      );
                    }, childCount: state.claimedBadges.length),
                  ),
                ),
              );
            }

            if (state.requestedBadges.isNotEmpty) {
              if (state.claimedBadges.isNotEmpty || state.unclaimedCount > 0) {
                slivers.add(
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                );
              }
              slivers.add(
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      l10n.requestedBadges,
                      style: textTheme.titleMedium,
                    ),
                  ),
                ),
              );
              slivers.add(
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final badge = state.requestedBadges[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: BadgeCard(
                          instance: badge,
                          badgeClass: badge.badgeclass as BadgeClassModel,
                          style: BadgeCardStyle.small,
                        ),
                      );
                    }, childCount: state.requestedBadges.length),
                  ),
                ),
              );
            }

            if (state.claimedBadges.isEmpty && state.requestedBadges.isEmpty) {
              slivers.add(
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          Assets.iconBackpack,
                          colorFilter: ColorFilter.mode(
                            colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                          width: 48,
                          height: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.noEdubadgesYet, style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              );
            }

            return CustomScrollView(slivers: slivers);
          },
          loading: () => const CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          error: (error, stackTrace) => const CustomScrollView(
            slivers: [SliverFillRemaining(child: Center(child: SizedBox()))],
          ),
        ),
      ),
    );
  }
}
