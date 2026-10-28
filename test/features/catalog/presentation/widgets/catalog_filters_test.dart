import 'package:edubadges/app/themes.dart';
import 'package:edubadges/features/catalog/domain/entities/catalog_institution.dart';
import 'package:edubadges/features/catalog/presentation/providers/institution_providers.dart';
import 'package:edubadges/features/catalog/presentation/widgets/catalog_filters.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpFilters(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        catalogInstitutionsProvider.overrideWith(
          (Ref ref) async => const <CatalogInstitution>[],
        ),
      ],
      child: MaterialApp(
        theme: AppThemes.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const Scaffold(
          body: SingleChildScrollView(child: CatalogFilters()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

SemanticsNode _level(WidgetTester tester, String label) =>
    tester.getSemantics(find.text(label));

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
}
