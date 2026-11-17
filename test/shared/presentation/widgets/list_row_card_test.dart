import 'package:edubadges/app/themes.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/widgets/list_row_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/app_fonts.dart';

const String _longIssuer = 'Erasmus School of Social and Behavioural Sciences';

Future<void> _pumpCard(
  WidgetTester tester, {
  String title = 'English Grammar B1+',
  String issuerName = 'Kennis & Informatie',
  String institutionName = 'Hogeschool Rotterdam',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppThemes.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('nl'),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          // The card width on a 393 wide phone, as in the design.
          child: SizedBox(
            width: 353,
            child: ListRowCard(
              title: title,
              issuerName: issuerName,
              institutionName: institutionName,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('keeps the issuer and institution on one line', (
    WidgetTester tester,
  ) async {
    await _pumpCard(tester);

    expect(
      find.text('Kennis & Informatie van Hogeschool Rotterdam'),
      findsOneWidget,
    );
    expect(find.text('Hogeschool Rotterdam'), findsNothing);
  });

  testWidgets('a two-line title keeps the card at the design height', (
    WidgetTester tester,
  ) async {
    await _pumpCard(
      tester,
      title: 'ICT Internship Semester 5 (FTRBSTGFALL2022) and a longer tail',
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(ListRowCard)).height,
      ListRowCard.minHeight,
    );
  });

  // SURF-679: a name that does not fit on one line wraps onto a second one
  // instead of being cut off.
  testWidgets('wraps an issuer that does not fit onto a second line', (
    WidgetTester tester,
  ) async {
    await _pumpCard(tester, title: 'MC test', issuerName: _longIssuer);

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.text('$_longIssuer van Hogeschool Rotterdam')).height,
      32,
    );
    // A one-line title and two issuer lines still fit beside the image.
    expect(
      tester.getSize(find.byType(ListRowCard)).height,
      ListRowCard.minHeight,
    );
  });

  testWidgets('grows when both the title and the issuer wrap', (
    WidgetTester tester,
  ) async {
    await _pumpCard(
      tester,
      title: 'ICT Internship Semester 5 (FTRBSTGFALL2022) and a longer tail',
      issuerName: _longIssuer,
    );

    expect(tester.takeException(), isNull);
    // 16 padding + 2 title lines (40) + 2 + 2 issuer lines (32) + 16 padding.
    expect(tester.getSize(find.byType(ListRowCard)).height, 106);
  });

  testWidgets('shows only the institution when there is no issuer', (
    WidgetTester tester,
  ) async {
    await _pumpCard(tester, issuerName: '');

    expect(find.text('Hogeschool Rotterdam'), findsOneWidget);
  });
}
