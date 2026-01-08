import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class MainPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final pillColor = colorScheme.primary.withOpacity(0.15);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
        backgroundColor: colorScheme.surface,
        elevation: 8,
        selectedItemColor: colorScheme.onSurface,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.normal,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          _buildItem(
            index: 0,
            currentIndex: navigationShell.currentIndex,
            iconPath: Assets.iconBackpack,
            label: l10n.tabBadges,
            pillColor: pillColor,
            colorScheme: colorScheme,
          ),
          _buildItem(
            index: 1,
            currentIndex: navigationShell.currentIndex,
            iconPath: Assets.iconCollections,
            label: l10n.tabCollections,
            pillColor: pillColor,
            colorScheme: colorScheme,
          ),
          _buildItem(
            index: 2,
            currentIndex: navigationShell.currentIndex,
            iconPath: Assets.iconCatalog,
            label: l10n.tabCatalog,
            pillColor: pillColor,
            colorScheme: colorScheme,
          ),
          _buildItem(
            index: 3,
            currentIndex: navigationShell.currentIndex,
            iconPath: Assets.iconAccount,
            label: l10n.tabAccount,
            pillColor: pillColor,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildItem({
    required int index,
    required int currentIndex,
    required String iconPath,
    required String label,
    required Color pillColor,
    required ColorScheme colorScheme,
  }) {
    final bool isSelected = index == currentIndex;

    return BottomNavigationBarItem(
      label: label,
      tooltip: label,
      icon: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: isSelected
              ? BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(32),
          )
              : null,
          child: SvgPicture.asset(
            iconPath,
            width: 30,
            height: 30,
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