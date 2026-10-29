import 'package:edubadges/app/themes.dart';
import 'package:edubadges/features/badge_details/data/models/badge_details_model.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_scope.dart';
import 'package:edubadges/features/badge_details/presentation/pages/quality_assurance_page.dart';
import 'package:edubadges/features/badge_details/presentation/providers/badge_details_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the link to the quality assurance page has a name', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          badgeDetailsModelProvider.overrideWith(
            (Ref ref, _) async => const BadgeDetailsModel(
              badgeInstance: null,
              requested: false,
              badgeClass: BadgeClassModel(
                id: 1,
                name: 'Badge',
                entityId: 'class-1',
                badgeClassType: BadgeClassType.regular,
                image: 'https://example.com/badge.png',
                qualityAssuranceUrl: 'https://example.com/qa',
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppThemes.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const QualityAssurancePage(
            badgeId: 'class-1',
            scope: BadgeDetailsScope.public,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byIcon(Icons.launch)),
      isSemantics(
        tooltip: 'Open quality assurance page',
        isButton: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });
}
