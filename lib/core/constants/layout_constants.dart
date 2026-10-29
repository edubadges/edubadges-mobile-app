import 'dart:math' as math;

class LayoutConstants {
  LayoutConstants._();

  static const double navigationDrawerMinWidth = 840.0;

  static const double badgesOverviewGridMinWidth = navigationDrawerMinWidth;
  static const double badgesOverviewGridSpacing = 16;
  static const double badgesOverviewDesktopMaxWidth = 960;

  static const double badgeGridSpacing = 16;
  static const double badgeGridPadding = 16;

  /// Picked so two tiles fit as soon as the navigation drawer appears at
  /// [navigationDrawerMinWidth].
  static const double badgeGridTileMinWidth = 240;

  /// A third column is only worth it while the tiles stay comfortable; the
  /// design draws them at 437 and never squeezes three narrow ones in.
  static const double badgeGridExtraColumnMinTileWidth = 300;

  /// Two [TextTheme.titleMedium] lines: names are clamped to two lines, so
  /// every tile keeps the same size without a third line of white space.
  static const double badgeGridTileNameHeight = 2 * 24;

  /// 16 padding + 100 image + 8 + name + 8 + 16 padding: all of a tile but its
  /// chip rows and issuer label.
  static const double _badgeGridTileFixedHeight =
      16 + 100 + 8 + badgeGridTileNameHeight + 8 + 16;

  /// The issuer label: one [TextTheme.bodySmall] line (16) beside its 22 logo,
  /// or two lines when a name does not fit on one.
  static double badgeGridIssuerHeight(int lines) => math.max(22, 16.0 * lines);

  static const double badgeGridChipRowHeight = 32;

  static const int badgeGridMinColumns = 2;
  static const int badgesOverviewGridMaxColumns = 3;
  static const int catalogGridMaxColumns = 2;

  /// The most columns that fit in [width] while every tile stays wide enough,
  /// capped at [maxColumns]. Returns 0 below [badgeGridMinColumns], where the
  /// list of compact cards reads better than a near-empty grid.
  static int badgeGridColumnCount(double width, {required int maxColumns}) {
    if (width <= 0) return 0;
    int columns = 0;
    for (
      int candidate = badgeGridMinColumns;
      candidate <= maxColumns;
      candidate++
    ) {
      final double minTileWidth = candidate > badgeGridMinColumns
          ? badgeGridExtraColumnMinTileWidth
          : badgeGridTileMinWidth;
      if (badgeGridTileWidth(width, candidate) >= minTileWidth) {
        columns = candidate;
      }
    }
    return columns;
  }

  static double badgeGridTileWidth(double gridWidth, int columns) =>
      (gridWidth - badgeGridSpacing * (columns - 1)) / columns;

  /// Height of a tile whose chips wrap onto [chipRows] rows, each with its 8
  /// gap on top, and whose issuer label takes [issuerLines] lines. One chip
  /// row and one issuer line match the overview design; the catalog tile draws
  /// no chips.
  static double badgeGridTileHeightFor({
    required int chipRows,
    required int issuerLines,
  }) =>
      _badgeGridTileFixedHeight +
      badgeGridIssuerHeight(issuerLines) +
      chipRows * (badgeGridChipRowHeight + 8);

  static const int collectionsGridCrossAxisCount = 3;
  static const double collectionsGridMainAxisExtent = 104;

  static const double sidebarListLayoutMinWidth = navigationDrawerMinWidth;
  static const double sidebarListLayoutSidebarWidth = 380.0;
  static const double sidebarListLayoutColumnGap = 24.0;
  static const double sidebarListLayoutPadding = 16.0;

  static const int badgeDetailsSidebarFlex = 2;
  static const int badgeDetailsMainFlex = 5;

  static const double webFormModalMaxWidth = 480;
}
