import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/shared/presentation/widgets/badge_grid_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const List<BadgeInfoChipData> _chips = <BadgeInfoChipData>[
  BadgeInfoChipData(icon: Assets.iconTimeInvestment, label: '480 uur'),
  BadgeInfoChipData(icon: Assets.iconCollections, label: '8,0'),
  BadgeInfoChipData(icon: Assets.iconDate, label: '22 aug, 2025'),
];

const String _longName =
    'Desk Research | Advanced Beginner Desk Research for Applied Sciences '
    'and Related Disciplines';

/// Content width the badges overview grid gets for a given browser width. The
/// grid spans the full content width, so only the navigation drawer and its own
/// padding come off.
double _overviewGridWidth(double browserWidth) {
  const double navigationDrawerWidth = 304;
  return browserWidth -
      navigationDrawerWidth -
      LayoutConstants.badgeGridPadding * 2;
}

/// Web resolves the host desktop platform, which changes theme metrics such as
/// tap target size and visual density.
Future<void> _withDesktopPlatform(Future<void> Function() runTest) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
  try {
    await runTest();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

/// Pumps a grid sized the way the badges overview sizes it, and returns the
/// chip rows it reserved.
Future<int> _pumpGrid(
  WidgetTester tester, {
  required double gridWidth,
  required int columns,
  String name = 'English Grammar B1+',
  List<BadgeInfoChipData> chips = _chips,
  double textScale = 1,
}) async {
  int chipRows = 0;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppThemes.lightTheme,
      // Text enlarged in the browser settings, which Flutter web reads as the
      // text scale.
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: gridWidth,
            height: 800,
            child: Builder(
              builder: (BuildContext context) {
                chipRows = BadgeGridTile.chipRowsFor(
                  context,
                  <List<BadgeInfoChipData>>[chips],
                  LayoutConstants.badgeGridTileWidth(gridWidth, columns),
                );
                return CustomScrollView(
                  slivers: [
                    SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: LayoutConstants.badgeGridSpacing,
                        mainAxisSpacing: LayoutConstants.badgeGridSpacing,
                        mainAxisExtent: LayoutConstants.badgeGridTileHeightFor(
                          chipRows: chipRows,
                          textScaler: MediaQuery.textScalerOf(context),
                        ),
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) => BadgeGridTile(
                          name: name,
                          issuerName: 'Kennis & Informatie',
                          institutionName: 'Hogeschool Rotterdam',
                          // Real badges carry a logo, which makes the institution
                          // row taller than its text alone.
                          institutionImageUrl: 'https://example.org/logo.png',
                          chips: chips,
                          isPublic: index.isEven,
                          visibilityLabel: 'Badge is public',
                          onTap: () {},
                        ),
                        childCount: 6,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return chipRows;
}

/// The default test font is a uniform-width placeholder, which measures chips
/// and names very differently from production and hides real wrapping bugs.
Future<void> _loadAppFonts() async {
  const Map<String, List<String>> families = <String, List<String>>{
    'Nunito': <String>[
      'assets/fonts/Nunito-Regular.ttf',
      'assets/fonts/Nunito-Bold.ttf',
    ],
    'SourceSans3': <String>[
      'assets/fonts/SourceSans3-Regular.ttf',
      'assets/fonts/SourceSans3-SemiBold.ttf',
    ],
  };
  for (final MapEntry<String, List<String>> family in families.entries) {
    final FontLoader loader = FontLoader(family.key);
    for (final String path in family.value) {
      loader.addFont(rootBundle.load(path));
    }
    await loader.load();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadAppFonts);

  for (final double browserWidth in <double>[840, 1024, 1440, 1728]) {
    testWidgets('lays out without overflow at ${browserWidth.toInt()}px', (
      WidgetTester tester,
    ) async {
      await _withDesktopPlatform(() async {
        tester.view.physicalSize = Size(browserWidth, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final double gridWidth = _overviewGridWidth(browserWidth);
        final int columns = LayoutConstants.badgeGridColumnCount(
          gridWidth,
          maxColumns: LayoutConstants.badgesOverviewGridMaxColumns,
        );
        expect(columns, greaterThanOrEqualTo(2));

        final int chipRows = await _pumpGrid(
          tester,
          gridWidth: gridWidth,
          columns: columns,
        );

        expect(tester.takeException(), isNull);

        final List<Rect> firstRow = tester
            .widgetList<BadgeGridTile>(find.byType(BadgeGridTile))
            .take(columns)
            .map((BadgeGridTile tile) => tester.getRect(find.byWidget(tile)))
            .toList();
        expect(firstRow.map((Rect rect) => rect.top).toSet().length, 1);
        expect(
          firstRow.last.height,
          LayoutConstants.badgeGridTileHeightFor(chipRows: chipRows),
        );

        // Chips outside the clipped region are invisible but still report a
        // rect inside the tile, so assert against the visible region itself:
        // a tile too short for the wrapped chips drops information silently.
        final Rect chipRegion = tester.getRect(find.byType(OverflowBox).first);
        for (final BadgeInfoChipData chip in _chips) {
          final Rect chipRect = tester.getRect(find.text(chip.label).first);
          expect(
            chipRect.bottom,
            lessThanOrEqualTo(chipRegion.bottom),
            reason: 'chip "${chip.label}" is clipped at $columns columns',
          );
        }
      });
    });
  }

  testWidgets('keeps names, chips and issuers whole at 200% text', (
    WidgetTester tester,
  ) async {
    await _withDesktopPlatform(() async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final double gridWidth = _overviewGridWidth(1440);
      await _pumpGrid(
        tester,
        gridWidth: gridWidth,
        columns: LayoutConstants.badgeGridColumnCount(
          gridWidth,
          maxColumns: LayoutConstants.badgesOverviewGridMaxColumns,
        ),
        textScale: 2,
      );

      expect(tester.takeException(), isNull);

      // Both name lines fit their box instead of the second being cut off.
      final RenderParagraph name = tester.renderObject<RenderParagraph>(
        find.text('English Grammar B1+').first,
      );
      expect(
        name.size.height,
        greaterThanOrEqualTo(name.getMinIntrinsicHeight(name.size.width) - 0.5),
      );

      final Rect tile = tester.getRect(find.byType(BadgeGridTile).first);
      final Rect chipRegion = tester.getRect(find.byType(OverflowBox).first);
      for (final BadgeInfoChipData chip in _chips) {
        expect(
          tester.getRect(find.text(chip.label).first).bottom,
          lessThanOrEqualTo(chipRegion.bottom),
          reason: 'chip "${chip.label}" is clipped',
        );
      }
      expect(
        tester.getRect(find.text('Hogeschool Rotterdam').first).bottom,
        lessThanOrEqualTo(tile.bottom),
      );
    });
  });

  test('the grid widens the tiles as the window grows', () {
    int columns(double browserWidth) => LayoutConstants.badgeGridColumnCount(
      _overviewGridWidth(browserWidth),
      maxColumns: LayoutConstants.badgesOverviewGridMaxColumns,
    );
    double tileWidth(double browserWidth) => LayoutConstants.badgeGridTileWidth(
      _overviewGridWidth(browserWidth),
      columns(browserWidth),
    );

    expect(columns(840), 2);
    expect(columns(1024), 2);
    expect(columns(1440), 3);
    expect(columns(1728), 3);

    // The design draws the tiles at 437 in a 1728 frame; a 304 drawer instead
    // of the 320 in the design leaves a little more room.
    expect(tileWidth(1728), closeTo(453, 1));
    expect(tileWidth(1440), greaterThan(tileWidth(1024)));
  });

  testWidgets('a long name stays inside the tile', (WidgetTester tester) async {
    await _withDesktopPlatform(() async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpGrid(
        tester,
        gridWidth: _overviewGridWidth(1440),
        columns: 3,
        name: _longName,
      );

      expect(tester.takeException(), isNull);

      final Rect tile = tester.getRect(find.byType(BadgeGridTile).first);
      final Rect text = tester.getRect(find.text(_longName).first);
      expect(text.bottom, lessThanOrEqualTo(tile.bottom));
    });
  });

  testWidgets('the chipless catalog tile fits its shorter height exactly', (
    WidgetTester tester,
  ) async {
    await _withDesktopPlatform(() async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpGrid(
        tester,
        gridWidth: 768,
        columns: LayoutConstants.catalogGridMaxColumns,
        chips: const <BadgeInfoChipData>[],
      );

      // The border is drawn in front of the tile rather than inset into it, so
      // the content gets the full height minus padding and nothing overflows.
      expect(tester.takeException(), isNull);

      final Rect tile = tester.getRect(find.byType(BadgeGridTile).first);
      expect(tile.height, LayoutConstants.badgeGridTileHeightWithoutChips);

      final Rect institution = tester.getRect(
        find.text('Hogeschool Rotterdam').first,
      );
      expect(institution.bottom, lessThanOrEqualTo(tile.bottom - 16));
    });
  });

  testWidgets('wrapping chips are clipped rather than overflowing', (
    WidgetTester tester,
  ) async {
    await _withDesktopPlatform(() async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpGrid(
        tester,
        gridWidth: _overviewGridWidth(1440),
        columns: 3,
        chips: const <BadgeInfoChipData>[
          ..._chips,
          BadgeInfoChipData(
            icon: Assets.iconDate,
            label: 'Verloopt 1 jan, 2030',
          ),
          BadgeInfoChipData(icon: Assets.iconType, label: 'Micro-credential'),
        ],
      );

      expect(tester.takeException(), isNull);
    });
  });

  // SURF-680: a fixed width threshold reserved a second chip row on every
  // tile narrower than 380, leaving a blank band when the chips fit on one.
  testWidgets('reserves no chip row the badges do not need', (
    WidgetTester tester,
  ) async {
    await _withDesktopPlatform(() async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const List<BadgeInfoChipData> chips = <BadgeInfoChipData>[
        BadgeInfoChipData(icon: Assets.iconCollections, label: '9'),
        BadgeInfoChipData(icon: Assets.iconDate, label: '16 Oct, 2026'),
      ];
      final int chipRows = await _pumpGrid(
        tester,
        gridWidth: _overviewGridWidth(1440),
        columns: 3,
        chips: chips,
      );

      expect(chipRows, 1);
      expect(tester.takeException(), isNull);

      final Rect date = tester.getRect(find.text('16 Oct, 2026').first);
      final Rect issuer = tester.getRect(
        find.text('Kennis & Informatie').first,
      );
      // The chip row's own 6 padding plus the 8 gap above the issuer.
      expect(issuer.top - date.bottom, lessThan(32));
    });
  });

  testWidgets('counts the rows the chips wrap onto', (
    WidgetTester tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.lightTheme,
        home: Builder(
          builder: (BuildContext builderContext) {
            context = builderContext;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(BadgeGridTile.chipRowsFor(context, const [_chips], 500), 1);
    expect(BadgeGridTile.chipRowsFor(context, const [_chips], 300), 2);
    expect(
      BadgeGridTile.chipRowsFor(context, const [<BadgeInfoChipData>[]], 300),
      0,
    );
    // The grid takes the badge that needs the most rows.
    expect(
      BadgeGridTile.chipRowsFor(context, const [
        <BadgeInfoChipData>[],
        _chips,
      ], 300),
      2,
    );
  });

  testWidgets('a tappable tile is one button named after the badge first', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.lightTheme,
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: LayoutConstants.badgeGridTileHeightFor(chipRows: 1),
            child: BadgeGridTile(
              name: 'English Grammar B1+',
              issuerName: 'Kennis & Informatie',
              institutionName: 'Hogeschool Rotterdam',
              chips: _chips.take(1).toList(),
              isPublic: false,
              visibilityLabel: 'Badge is private',
              onTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The node that takes keyboard focus used to be named by the shield alone.
    final SemanticsNode node = tester.getSemantics(find.byType(InkWell));
    expect(
      node,
      isSemantics(isButton: true, isFocusable: true, hasTapAction: true),
    );
    final String label = node.getSemanticsData().label;
    expect(label, startsWith('English Grammar B1+'));
    expect(label, contains('Hogeschool Rotterdam'));
    expect(label, endsWith('Badge is private'));
    semantics.dispose();
  });
}
