import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class SidebarListLayout extends StatelessWidget {
  final Widget sidebar;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final List<Widget> slivers;
  final bool useSidebarLayout;
  final double padding;
  final double columnGap;
  final double sidebarWidth;

  const SidebarListLayout({
    super.key,
    required this.sidebar,
    required this.scrollController,
    required this.onRefresh,
    required this.slivers,
    required this.useSidebarLayout,
    this.padding = LayoutConstants.sidebarListLayoutPadding,
    this.columnGap = LayoutConstants.sidebarListLayoutColumnGap,
    this.sidebarWidth = LayoutConstants.sidebarListLayoutSidebarWidth,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (useSidebarLayout) {
      // On web, drop the bottom padding so no background-coloured strip shows
      // beneath the side view; the trailing sliver still provides scroll spacing.
      final EdgeInsets outerPadding = PlatformInfo.isWeb
          ? EdgeInsets.fromLTRB(padding, padding, padding, 0)
          : EdgeInsets.all(padding);
      return Padding(
        padding: outerPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: sidebarWidth,
              child: SingleChildScrollView(child: sidebar),
            ),
            SizedBox(width: columnGap),
            Expanded(
              child: RefreshIndicator(
                backgroundColor: colorScheme.surfaceContainer,
                onRefresh: onRefresh,
                child: CustomScrollView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    ...slivers,
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      backgroundColor: colorScheme.surfaceContainer,
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
              child: sidebar,
            ),
          ),
          ...slivers,
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}
