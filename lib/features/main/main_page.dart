import 'dart:async';

import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/providers/app_badge_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class _NavigationDestinationData {
  const _NavigationDestinationData({
    required this.iconPath,
    required this.label,
  });

  final String iconPath;
  final String label;
}

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

  List<_NavigationDestinationData> _navigationDestinations(AppLocalizations l10n) {
    return <_NavigationDestinationData>[
      _NavigationDestinationData(
        iconPath: Assets.iconBackpack,
        label: l10n.tabBadges,
      ),
      _NavigationDestinationData(
        iconPath: Assets.iconCollections,
        label: l10n.tabCollections,
      ),
      _NavigationDestinationData(
        iconPath: Assets.iconCatalog,
        label: l10n.tabCatalog,
      ),
      _NavigationDestinationData(
        iconPath: Assets.iconAccount,
        label: l10n.tabAccount,
      ),
    ];
  }

  Widget _buildNavIcon({
    required String iconPath,
    required bool isSelected,
    required ColorScheme colorScheme,
  }) {
    return ExcludeSemantics(
      child: SvgPicture.asset(
        iconPath,
        width: 25,
        height: 25,
        colorFilter: ColorFilter.mode(
          isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  NavigationDestination _buildNavigationBarDestination({
    required int index,
    required int currentIndex,
    required _NavigationDestinationData destination,
    required ColorScheme colorScheme,
  }) {
    final bool isSelected = index == currentIndex;
    return NavigationDestination(
      label: destination.label,
      tooltip: destination.label,
      icon: Padding(
        padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
        child: _buildNavIcon(
          iconPath: destination.iconPath,
          isSelected: isSelected,
          colorScheme: colorScheme,
        ),
      ),
    );
  }

  NavigationRailDestination _buildNavigationRailDestination({
    required _NavigationDestinationData destination,
    required ColorScheme colorScheme,
  }) {
    return NavigationRailDestination(
      icon: _buildNavIcon(
        iconPath: destination.iconPath,
        isSelected: false,
        colorScheme: colorScheme,
      ),
      selectedIcon: _buildNavIcon(
        iconPath: destination.iconPath,
        isSelected: true,
        colorScheme: colorScheme,
      ),
      label: Text(destination.label),
    );
  }

  Widget _buildCompactScaffold({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required Color pillColor,
    required List<_NavigationDestinationData> destinations,
  }) {
    final int currentIndex = widget.navigationShell.currentIndex;
    return Scaffold(
      body: SafeArea(child: widget.navigationShell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
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
        destinations: List<NavigationDestination>.generate(
          destinations.length,
          (int index) => _buildNavigationBarDestination(
            index: index,
            currentIndex: currentIndex,
            destination: destinations[index],
            colorScheme: colorScheme,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedScaffold({
    required ColorScheme colorScheme,
    required Color pillColor,
    required List<_NavigationDestinationData> destinations,
  }) {
    final int currentIndex = widget.navigationShell.currentIndex;
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: _onTap,
            backgroundColor: colorScheme.surfaceContainer,
            indicatorColor: pillColor,
            labelType: NavigationRailLabelType.all,
            destinations: destinations
                .map(
                  (_NavigationDestinationData destination) =>
                      _buildNavigationRailDestination(
                    destination: destination,
                    colorScheme: colorScheme,
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: SafeArea(child: widget.navigationShell)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(profileProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pillColor = colorScheme.primary.withValues(alpha: .15);
    final destinations = _navigationDestinations(l10n);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useNavigationRail =
            constraints.maxWidth >= LayoutConstants.navigationRailMinWidth;
        if (useNavigationRail) {
          return _buildExpandedScaffold(
            colorScheme: colorScheme,
            pillColor: pillColor,
            destinations: destinations,
          );
        }
        return _buildCompactScaffold(
          theme: theme,
          colorScheme: colorScheme,
          pillColor: pillColor,
          destinations: destinations,
        );
      },
    );
  }
}
