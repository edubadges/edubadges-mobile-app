import 'package:edubadges/app/colors.dart';
import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/widgets/focus_ring_overlay.dart';
import 'package:edubadges/core/widgets/keyboard_activatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpApp(WidgetTester tester, Widget body) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppThemes.lightTheme,
      builder: (BuildContext context, Widget? child) =>
          FocusRingOverlay(child: child!),
      home: Scaffold(body: Center(child: body)),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pressTab(WidgetTester tester) async {
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pumpAndSettle();
}

RenderObject _ringLayer(WidgetTester tester) => tester.renderObject(
  find.descendant(
    of: find.byType(FocusRingOverlay),
    matching: find.byWidgetPredicate(
      (Widget widget) =>
          widget is CustomPaint &&
          widget.painter.runtimeType.toString() == '_FocusRingPainter',
    ),
  ),
);

/// Matches a ring drawn around [rect]: the ring path encloses the widget but
/// not the area a few pixels outside it.
PaintPattern _ringAround(Rect rect, {List<Offset> alsoExcludes = const []}) =>
    paints
      ..path(color: AppColors.surfaceContainer)
      ..path(
        color: AppColors.primary,
        includes: <Offset>[rect.center, rect.centerLeft, rect.topCenter],
        excludes: <Offset>[
          rect.inflate(6).topLeft,
          rect.inflate(6).bottomRight,
          ...alsoExcludes,
        ],
      );

const Key _tileKey = Key('tile');

void main() {
  testWidgets('shows no ring until the keyboard is used', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      TextButton(autofocus: true, onPressed: () {}, child: const Text('Go')),
    );

    expect(FocusManager.instance.primaryFocus?.context, isNotNull);
    expect(_ringLayer(tester), paintsNothing);
  });

  testWidgets('draws a ring around the widget Tab moves to', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      InkWell(
        key: _tileKey,
        onTap: () {},
        child: const SizedBox(width: 200, height: 100),
      ),
    );

    await _pressTab(tester);

    expect(
      _ringLayer(tester),
      _ringAround(tester.getRect(find.byKey(_tileKey))),
    );
  });

  testWidgets('hides the ring again on a pointer press', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      InkWell(
        key: _tileKey,
        onTap: () {},
        child: const SizedBox(width: 200, height: 100),
      ),
    );
    await _pressTab(tester);
    expect(
      _ringLayer(tester),
      _ringAround(tester.getRect(find.byKey(_tileKey))),
    );

    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    expect(_ringLayer(tester), paintsNothing);
  });

  testWidgets('follows the rounded corners of the focused ink well', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      InkWell(
        key: _tileKey,
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: const SizedBox(width: 200, height: 100),
      ),
    );

    await _pressTab(tester);

    final Rect rect = tester.getRect(find.byKey(_tileKey));
    // A square ring would pass through the tile's own corners.
    expect(
      _ringLayer(tester),
      _ringAround(rect, alsoExcludes: <Offset>[rect.topLeft]),
    );
  });

  testWidgets('uses the shape a FocusRingShape declares', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      FocusRingShape.rounded(
        borderRadius: BorderRadius.circular(20),
        child: KeyboardActivatable(
          onActivate: () {},
          child: const SizedBox(key: _tileKey, width: 200, height: 100),
        ),
      ),
    );

    await _pressTab(tester);

    final Rect rect = tester.getRect(find.byKey(_tileKey));
    expect(
      _ringLayer(tester),
      _ringAround(rect, alsoExcludes: <Offset>[rect.topLeft]),
    );
  });

  testWidgets('keeps the ring on screen around a widget taller than it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.lightTheme,
        builder: (BuildContext context, Widget? child) =>
            FocusRingOverlay(child: child!),
        home: Scaffold(
          body: ListView(
            key: _tileKey,
            children: [
              KeyboardActivatable(
                onActivate: () {},
                child: const SizedBox(height: 2000),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _pressTab(tester);

    // The widget runs past the top and bottom of the list, so the ring is
    // drawn just inside the list instead of off screen.
    final Rect viewport = tester.getRect(find.byKey(_tileKey));
    expect(
      _ringLayer(tester),
      paints
        ..path(color: AppColors.surfaceContainer)
        ..path(
          color: AppColors.primary,
          includes: <Offset>[
            viewport.center,
            Offset(viewport.center.dx, viewport.top + 2),
            Offset(viewport.center.dx, viewport.bottom - 2),
          ],
          excludes: <Offset>[
            Offset(viewport.center.dx, viewport.top + 0.5),
            Offset(viewport.center.dx, viewport.bottom - 0.5),
          ],
        ),
    );
  });

  testWidgets('leaves text fields to their own focused border', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester, const SizedBox(width: 200, child: TextField()));

    await _pressTab(tester);

    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<EditableText>(),
      isNotNull,
    );
    expect(_ringLayer(tester), paintsNothing);
  });

  testWidgets('keeps the focus fill translucent so content stays readable', (
    WidgetTester tester,
  ) async {
    expect(AppThemes.lightTheme.focusColor.a, lessThan(0.2));
    expect(AppThemes.highContrastTheme.focusColor.a, lessThan(0.2));
  });
}
