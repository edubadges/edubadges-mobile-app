import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:flutter_test/flutter_test.dart';

int _overviewColumns(double width) => LayoutConstants.badgeGridColumnCount(
  width,
  maxColumns: LayoutConstants.badgesOverviewGridMaxColumns,
);

int _catalogColumns(double width) => LayoutConstants.badgeGridColumnCount(
  width,
  maxColumns: LayoutConstants.catalogGridMaxColumns,
);

void main() {
  const double tile = LayoutConstants.badgeGridTileMinWidth;
  const double wideTile = LayoutConstants.badgeGridExtraColumnMinTileWidth;
  const double gap = LayoutConstants.badgeGridSpacing;

  group('badgeGridColumnCount', () {
    test('falls back to the list below two columns', () {
      expect(_overviewColumns(0), 0);
      expect(_overviewColumns(-100), 0);
      expect(_overviewColumns(tile), 0);
      expect(_overviewColumns(2 * tile + gap - 1), 0);
    });

    test('gives two columns from the moment a second tile fits', () {
      expect(_overviewColumns(2 * tile + gap), 2);
    });

    test('holds at two columns while a third would be cramped', () {
      expect(_overviewColumns(3 * tile + 2 * gap), 2);
      expect(_overviewColumns(3 * wideTile + 2 * gap - 1), 2);
    });

    test('gives three columns once all three stay comfortable', () {
      expect(_overviewColumns(3 * wideTile + 2 * gap), 3);
    });

    test('never exceeds the maximum for the page', () {
      expect(
        _overviewColumns(4000),
        LayoutConstants.badgesOverviewGridMaxColumns,
      );
      expect(_catalogColumns(4000), LayoutConstants.catalogGridMaxColumns);
    });
  });

  group('badgeGridTileWidth', () {
    test('splits the grid width over the columns and gaps', () {
      expect(LayoutConstants.badgeGridTileWidth(1344, 3), 437 + 1 / 3);
      expect(LayoutConstants.badgeGridTileWidth(1016, 2), 500);
    });
  });

  group('badgeGridTileHeightFor', () {
    const double padding = 16 * 2;
    const double image = 100;
    const double name = 48;
    const double chipRow = 32;
    const double issuer = 32;
    const double gap = 8;

    test('drops the chip row when there are no chips', () {
      expect(
        LayoutConstants.badgeGridTileHeightFor(1000, hasChips: false),
        padding + image + gap + name + gap + issuer,
      );
      expect(
        LayoutConstants.badgeGridTileHeightFor(200, hasChips: false),
        LayoutConstants.badgeGridTileHeightWithoutChips,
      );
    });

    test('matches the design when the chips fit on one row', () {
      expect(
        LayoutConstants.badgeGridTileHeightFor(
          LayoutConstants.badgeGridSingleChipRowMinTileWidth,
          hasChips: true,
        ),
        padding + image + gap + name + gap * 2 + chipRow + issuer,
      );
    });

    test('reserves a second chip row on narrower tiles', () {
      expect(
        LayoutConstants.badgeGridTileHeightFor(
          LayoutConstants.badgeGridSingleChipRowMinTileWidth - 1,
          hasChips: true,
        ),
        padding + image + gap + name + gap * 3 + chipRow * 2 + issuer,
      );
    });
  });
}
