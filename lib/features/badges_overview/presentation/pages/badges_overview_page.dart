import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/shared/presentation/widgets/badge_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BadgesOverviewPage extends ConsumerWidget {
  const BadgesOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(badgesOverviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(Assets.imageLogo),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(badgesOverviewProvider.notifier).refresh();
        },
        child: CustomScrollView(
          slivers: [
            badgesAsync.when(
              data: (badges) {
                // TODO: Temp design once it's been designed in Figma it will be changed
                if (badges.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: SizedBox()),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final badge = badges[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: BadgeCard(
                          instance: badge,
                          style: BadgeCardStyle.small,
                        ),
                      );
                    }, childCount: badges.length),
                  ),
                );
              },
              // TODO: Temp design once it's been designed in Figma it will be changed
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              // TODO: Temp design once it's been designed in Figma it will be changed
              error: (error, stackTrace) =>
                  SliverFillRemaining(child: Center(child: SizedBox())),
            ),
          ],
        ),
      ),
    );
  }
}
