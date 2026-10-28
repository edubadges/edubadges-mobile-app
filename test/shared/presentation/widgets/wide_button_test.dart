import 'package:edubadges/app/themes.dart';
import 'package:edubadges/shared/presentation/widgets/wide_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpButtons(WidgetTester tester, VoidCallback onTap) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppThemes.lightTheme,
      home: Scaffold(
        body: Column(
          children: [
            WideButton(text: 'Copy link', icon: null, onTap: onTap),
            TextButton(onPressed: () {}, child: const Text('Next')),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('is a single tab stop that Enter activates', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await _pumpButtons(tester, () => taps++);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<WideButton>(),
      isNotNull,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(taps, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<TextButton>(),
      isNotNull,
    );
  });

  testWidgets('the node that takes focus carries the label', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await _pumpButtons(tester, () {});

    expect(
      tester.getSemantics(
        find.descendant(
          of: find.byType(WideButton),
          matching: find.byType(InkWell),
        ),
      ),
      matchesSemantics(
        label: 'Copy link',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });
}
