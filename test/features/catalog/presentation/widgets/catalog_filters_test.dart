import 'package:edubadges/app/themes.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_institution.dart';
import 'package:edubadges/features/catalog/presentation/providers/institution_providers.dart';
import 'package:edubadges/features/catalog/presentation/widgets/catalog_filters.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpFilters(
  WidgetTester tester, {
  List<CatalogInstitution> institutions = const <CatalogInstitution>[],
  ValueChanged<String?>? onInstitutionChanged,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        catalogInstitutionsProvider.overrideWith(
          (Ref ref) async => institutions,
        ),
      ],
      child: MaterialApp(
        theme: AppThemes.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: CatalogFilters(onInstitutionChanged: onInstitutionChanged),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

SemanticsNode _level(WidgetTester tester, String label) =>
    tester.getSemantics(find.text(label));

/// The suggestion drawn as highlighted: the field keeps the keyboard focus.
final Finder _highlighted = find.byWidgetPredicate(
  (Widget widget) => widget is Container && widget.foregroundDecoration != null,
);

Finder _ring(String name) =>
    find.ancestor(of: find.text(name), matching: _highlighted);

Future<void> _searchInstitution(WidgetTester tester, String text) async {
  await tester.enterText(find.widgetWithText(TextField, 'Institution'), text);
  await tester.pumpAndSettle();
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the level filters are radio buttons that report the choice', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await _pumpFilters(tester);

    expect(find.bySemanticsLabel('Education level'), findsOneWidget);
    expect(
      _level(tester, 'All levels'),
      isSemantics(
        label: 'All levels',
        isInMutuallyExclusiveGroup: true,
        hasCheckedState: true,
        isChecked: true,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    expect(
      _level(tester, 'MBO'),
      isSemantics(hasCheckedState: true, isChecked: false),
    );

    await tester.tap(find.text('MBO'));
    await tester.pumpAndSettle();

    expect(_level(tester, 'MBO'), isSemantics(isChecked: true));
    expect(_level(tester, 'All levels'), isSemantics(isChecked: false));
    semantics.dispose();
  });

  testWidgets('the arrow keys show which institution will be picked', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await _pumpFilters(
      tester,
      institutions: const <CatalogInstitution>[
        CatalogInstitution(entityId: 'a', nameEnglish: 'University A'),
        CatalogInstitution(entityId: 'b', nameEnglish: 'University B'),
      ],
    );

    await _searchInstitution(tester, 'University');

    expect(_ring('University A'), findsOneWidget);
    expect(_ring('University B'), findsNothing);
    expect(
      tester.getSemantics(find.text('University A')),
      isSemantics(isButton: true, isSelected: true, hasTapAction: true),
    );

    await _press(tester, LogicalKeyboardKey.arrowDown);

    expect(_ring('University A'), findsNothing);
    expect(_ring('University B'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('University B')),
      isSemantics(isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('University A')),
      isSemantics(isSelected: false),
    );
    semantics.dispose();
  });

  testWidgets('Enter picks the highlighted institution', (
    WidgetTester tester,
  ) async {
    String? picked;
    await _pumpFilters(
      tester,
      institutions: const <CatalogInstitution>[
        CatalogInstitution(entityId: 'a', nameEnglish: 'University A'),
        CatalogInstitution(entityId: 'b', nameEnglish: 'University B'),
      ],
      onInstitutionChanged: (String? id) => picked = id,
    );

    await _searchInstitution(tester, 'University');
    await _press(tester, LogicalKeyboardKey.arrowDown);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(picked, 'b');
    expect(find.widgetWithText(TextField, 'University B'), findsOneWidget);
    expect(_highlighted, findsNothing);
  });

  testWidgets('the highlighted institution stays in view in a long list', (
    WidgetTester tester,
  ) async {
    // Large text, so Page Down lands on suggestions that are not built yet.
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    String name(int i) => 'University ${i.toString().padLeft(2, '0')}';
    await _pumpFilters(
      tester,
      institutions: <CatalogInstitution>[
        for (int i = 0; i < 30; i++)
          CatalogInstitution(entityId: '$i', nameEnglish: name(i)),
      ],
    );
    await _searchInstitution(tester, 'University');

    void expectInView(int i) {
      expect(_ring(name(i)), findsOneWidget, reason: name(i));
      final Rect list = tester.getRect(find.byType(ListView));
      final Rect option = tester.getRect(_ring(name(i)));
      expect(option.top, greaterThanOrEqualTo(list.top), reason: name(i));
      expect(option.bottom, lessThanOrEqualTo(list.bottom), reason: name(i));
    }

    for (final int i in <int>[4, 8, 12, 16, 20, 24, 28, 29]) {
      await _press(tester, LogicalKeyboardKey.pageDown);
      expectInView(i);
    }
    for (final int i in <int>[25, 21, 17, 13, 9, 5, 1, 0]) {
      await _press(tester, LogicalKeyboardKey.pageUp);
      expectInView(i);
    }
  });
}
