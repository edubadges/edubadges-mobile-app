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
            // Badges list
            badgesAsync.when(
              data: (badges) {
                // TODO: Setup cleaner message once it's been designed in Figma
                if (badges.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No badges found')),
                  );
                }
                
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final badge = badges[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BadgeCard(
                            instance: badge,
                            style: BadgeCardStyle.small,
                          ),
                        );
                      },
                      childCount: badges.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading badges',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(badgesOverviewProvider.notifier).refresh();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
