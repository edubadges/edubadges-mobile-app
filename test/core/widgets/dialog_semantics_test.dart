import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/widgets/adaptive_dialog.dart';
import 'package:edubadges/core/widgets/base_form_bottom_sheet.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget home) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppThemes.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: home),
    ),
  );
  await tester.pumpAndSettle();
}

/// A dialog's title names it for screen readers, which read that name when
/// the dialog opens, and is its heading.
final Matcher _namesTheDialog = isSemantics(isHeader: true, namesRoute: true);

void main() {
  testWidgets('a confirmation dialog is named by its title', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await _pump(
      tester,
      Builder(
        builder: (BuildContext context) => TextButton(
          onPressed: () => AdaptiveDialog.show(
            context: context,
            config: AdaptiveDialogConfig(
              title: 'Log out?',
              description: 'You can log in again at any time.',
              firstButtonText: 'Cancel',
              secondButtonText: 'Log out',
              onFirstButtonPressed: () {},
              onSecondButtonPressed: () {},
            ),
          ),
          child: const Text('open'),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.getSemantics(find.text('Log out?')), _namesTheDialog);
    semantics.dispose();
  });

  testWidgets('a form sheet is named by its title', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await _pump(
      tester,
      BaseFormBottomSheet(
        title: 'Give feedback',
        description: "We'd love to hear from you.",
        formKey: GlobalKey<FormState>(),
        formFields: const <Widget>[],
        onSave: () {},
        saveButtonText: 'Confirm',
        cancelButtonText: 'Cancel',
      ),
    );

    expect(tester.getSemantics(find.text('Give feedback')), _namesTheDialog);
    semantics.dispose();
  });
}
