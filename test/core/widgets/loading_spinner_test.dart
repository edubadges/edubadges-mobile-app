import 'package:edubadges/core/widgets/loading_spinner.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('is one status node named "Loading..."', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Center(child: LoadingSpinner()),
      ),
    );

    // Material's own loading-spinner role reaches the web as an aria-label
    // without a role; a status may carry one.
    final SemanticsNode node = tester.getSemantics(find.byType(LoadingSpinner));
    expect(node.getSemanticsData().role, SemanticsRole.status);
    expect(node, isSemantics(label: 'Loading...'));
    expect(node.childrenCount, 0);
    semantics.dispose();
  });

  testWidgets('can say what is loading', (WidgetTester tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Center(child: LoadingSpinner(label: 'Loading badges')),
      ),
    );

    expect(
      tester.getSemantics(find.byType(LoadingSpinner)),
      isSemantics(label: 'Loading badges'),
    );
    semantics.dispose();
  });
}
