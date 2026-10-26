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

  /// Above this the three info chips sit on one row, as in the design.
  static const double badgeGridSingleChipRowMinTileWidth = 380;

  /// 16 padding + 100 image + 72 name + 8 + 32 issuer and institution + 16
  /// padding. The catalog tile draws no chip row.
  static const double badgeGridTileHeightWithoutChips = 244;

  /// One chip row and its gap on top, as in the overview design.
  static const double badgeGridTileHeight =
      badgeGridTileHeightWithoutChips + 32 + 8;

  /// Narrower tiles wrap the chips onto a second row.
  static const double badgeGridTileHeightWrapped = badgeGridTileHeight + 32 + 8;

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

  static double badgeGridTileHeightFor(
    double tileWidth, {
    required bool hasChips,
  }) {
    if (!hasChips) return badgeGridTileHeightWithoutChips;
    return tileWidth >= badgeGridSingleChipRowMinTileWidth
        ? badgeGridTileHeight
        : badgeGridTileHeightWrapped;
  }

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
