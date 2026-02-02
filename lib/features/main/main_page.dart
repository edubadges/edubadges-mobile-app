import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class MainPage extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(profileProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final pillColor = colorScheme.primary.withValues(alpha: .15);

    return Scaffold(
      body: SafeArea(
        child: navigationShell,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
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
            currentIndex: navigationShell.currentIndex,
            iconPath: Assets.iconBackpack,
            label: l10n.tabBadges,
            colorScheme: colorScheme,
          ),
          _buildItem(
            index: 1,
            currentIndex: navigationShell.currentIndex,
            iconPath: Assets.iconCollections,
            label: l10n.tabCollections,
            colorScheme: colorScheme,
          ),
          _buildItem(
            index: 2,
            currentIndex: navigationShell.currentIndex,
            iconPath: Assets.iconCatalog,
            label: l10n.tabCatalog,
            colorScheme: colorScheme,
          ),
          _buildItem(
            index: 3,
            currentIndex: navigationShell.currentIndex,
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
    );
  }
}