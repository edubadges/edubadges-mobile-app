import 'dart:math' as math;

import 'package:flutter/painting.dart';

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
  static const double badgeGridTileNameHeight = 2 * _nameLineHeight;

  /// Line heights of the tile text: the name ([TextTheme.titleMedium]), the
  /// issuer and institution ([TextTheme.bodySmall]) and the chip labels
  /// ([TextTheme.labelMedium]).
  static const double _nameLineHeight = 24;
  static const double _issuerLineHeight = 16;
  static const double _chipLineHeight = 16;

  /// The chip icon, which sets the chip height until the label outgrows it.
  static const double _chipIconSize = 18;

  /// [badgeGridTileNameHeight] at [textScaler], so two lines of enlarged text
  /// still fit (WCAG 1.4.4).
  static double badgeGridTileNameHeightFor(TextScaler textScaler) =>
      2 * textScaler.scale(_nameLineHeight);

  /// 16 padding + 100 image + 8 + name + 8 + 16 padding: all of a tile but its
  /// chip rows and issuer label.
  static const double _badgeGridTileFixedHeight =
      16 + 100 + 8 + badgeGridTileNameHeight + 8 + 16;

  /// The issuer label: one [TextTheme.bodySmall] line (16) beside its 22 logo,
  /// or two lines when a name does not fit on one. Its lines grow with
  /// [textScaler].
  static double badgeGridIssuerHeight(
    int lines, {
    TextScaler textScaler = TextScaler.noScaling,
  }) => math.max(22, lines * textScaler.scale(_issuerLineHeight));

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
  ///
  /// Text enlarged through the browser or the system ([textScaler]) makes the
  /// tile taller by as much as its text lines grow, so nothing is cut off.
  static double badgeGridTileHeightFor({
    required int chipRows,
    required int issuerLines,
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    // How much a line outgrows the room it has at the design size.
    double growth(double lineHeight, {required double room}) =>
        math.max(0.0, textScaler.scale(lineHeight) - room);

    return _badgeGridTileFixedHeight +
        2 * growth(_nameLineHeight, room: _nameLineHeight) +
        badgeGridIssuerHeight(issuerLines, textScaler: textScaler) +
        chipRows *
            (badgeGridChipRowHeight +
                8 +
                growth(_chipLineHeight, room: _chipIconSize));
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
