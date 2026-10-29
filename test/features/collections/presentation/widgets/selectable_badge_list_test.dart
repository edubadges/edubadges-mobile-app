import 'package:edubadges/app/themes.dart';
import 'package:edubadges/features/collections/presentation/widgets/selectable_badge_list.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../collections_test_helpers.dart';

/// The two-badge list from the create and edit collection screens, with the
/// selection kept in the test.
Future<Set<String>> _pumpList(WidgetTester tester) async {
  final Set<String> selected = <String>{};
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppThemes.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return CustomScrollView(
                slivers: [
                  SelectableBadgeSliverList(
                    badges: [testBadge('b1'), testBadge('b2')],
                    selectedBadgeIds: selected,
                    onToggle: (String id) => setState(() {
                      if (!selected.remove(id)) {
                        selected.add(id);
                      }
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return selected;
}

/// The badge whose row has keyboard focus.
String? _focusedBadge() => FocusManager.instance.primaryFocus?.context
    ?.findAncestorWidgetOfExactType<SelectableBadgeTile>()
    ?.badge
    .entityId;

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('each row is one tab stop', (WidgetTester tester) async {
    await _pumpList(tester);

    await _press(tester, LogicalKeyboardKey.tab);
    expect(_focusedBadge(), 'b1');

    // Not the row's checkbox.
    await _press(tester, LogicalKeyboardKey.tab);
    expect(_focusedBadge(), 'b2');
  });

  testWidgets('Enter and Space toggle the focused row', (
    WidgetTester tester,
  ) async {
    final Set<String> selected = await _pumpList(tester);

    await _press(tester, LogicalKeyboardKey.tab);
    await _press(tester, LogicalKeyboardKey.enter);
    expect(selected, {'b1'});

    await _press(tester, LogicalKeyboardKey.space);
    expect(selected, isEmpty);
  });

  testWidgets('a row is read as the badge with its checked state', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await _pumpList(tester);

    expect(
      tester.getSemantics(find.text('Badge b1')).getSemanticsData().label,
      contains('Badge b1'),
    );
    expect(
      tester.getSemantics(find.text('Badge b1')),
      isSemantics(
        hasCheckedState: true,
        isChecked: false,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    // The checkbox adds nothing of its own: it is part of the row.
    expect(
      tester.getSemantics(find.byType(Checkbox).first),
      same(tester.getSemantics(find.text('Badge b1'))),
    );

    await tester.tap(find.text('Badge b1'));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.text('Badge b1')),
      isSemantics(isChecked: true),
    );
    semantics.dispose();
  });
}
