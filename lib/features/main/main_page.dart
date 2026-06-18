import 'dart:async';

import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/providers/app_badge_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class MainPage extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage>
    with WidgetsBindingObserver {
  bool _isRefreshingOnReturn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        _refreshAndSyncBadgeCount(
          targetIndex: widget.navigationShell.currentIndex,
        ),
      );
    }
  }

  void _onTap(int index) {
    final previousIndex = widget.navigationShell.currentIndex;
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == previousIndex,
    );

    final returningToOverview = previousIndex != 0 && index == 0;
    if (returningToOverview) {
      unawaited(
        _refreshAndSyncBadgeCount(
          targetIndex: index,
          onlyWhenOverviewTab: true,
        ),
      );
    }
  }

  Future<void> _refreshAndSyncBadgeCount({
    required int targetIndex,
    bool onlyWhenOverviewTab = false,
  }) async {
    if (_isRefreshingOnReturn) return;
    if (onlyWhenOverviewTab && targetIndex != 0) return;

    _isRefreshingOnReturn = true;
    try {
      final badgesAsync = ref.read(badgesOverviewProvider);
      if (badgesAsync.hasValue) {
        await ref.read(badgesOverviewProvider.notifier).refresh();
      }

      final badgesState = await ref.read(badgesOverviewProvider.future);
      await ref
          .read(appBadgeServiceProvider)
          .syncUnclaimedCount(badgesState.unclaimedCount);
    } finally {
      _isRefreshingOnReturn = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(profileProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final pillColor = colorScheme.primary.withValues(alpha: .15);

    return Scaffold(
      body: SafeArea(child: widget.navigationShell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        backgroundColor: colorScheme.surfaceContainer,
        elevation: 8,
        indicatorColor: pillColor,
        labelTextStyle: WidgetStateProperty.resolveWith((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            );
          }
          return theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.normal,
            color: colorScheme.onSurfaceVariant,
          );
        }),
        destinations: [
          _buildItem(
            index: 0,
            currentIndex: widget.navigationShell.currentIndex,
            iconPath: Assets.iconBackpack,
            label: l10n.tabBadges,
            colorScheme: colorScheme,
          ),
          _buildItem(
            index: 1,
            currentIndex: widget.navigationShell.currentIndex,
            iconPath: Assets.iconCollections,
            label: l10n.tabCollections,
            colorScheme: colorScheme,
          ),
          _buildItem(
            index: 2,
            currentIndex: widget.navigationShell.currentIndex,
            iconPath: Assets.iconCatalog,
            label: l10n.tabCatalog,
            colorScheme: colorScheme,
          ),
          _buildItem(
            index: 3,
            currentIndex: widget.navigationShell.currentIndex,
            iconPath: Assets.iconAccount,
            label: l10n.tabAccount,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  NavigationDestination _buildItem({
    required int index,
    required int currentIndex,
    required String iconPath,
    required String label,
    required ColorScheme colorScheme,
  }) {
    final bool isSelected = index == currentIndex;

    return NavigationDestination(
      label: label,
      tooltip: label,
      icon: Padding(
        padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
        child: ExcludeSemantics(
          child: SvgPicture.asset(
            iconPath,
            width: 25,
            height: 25,
            colorFilter: ColorFilter.mode(
              isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
