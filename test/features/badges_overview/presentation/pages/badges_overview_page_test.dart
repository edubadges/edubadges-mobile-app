import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/features/badges_overview/domain/entities/badges_overview_state.dart';
import 'package:edubadges/features/badges_overview/presentation/pages/badges_overview_page.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBadgesOverviewNotifier extends BadgesOverviewNotifier {
  @override
  Future<BadgesOverviewState> build() async {
    return const BadgesOverviewState(
      claimedBadges: [],
      unclaimedBadges: [],
      requestedBadges: [],
    );
  }

  @override
  Future<void> refresh({bool silent = true}) async {}
}

Future<void> _pumpOverview(WidgetTester tester, {required Size size}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        badgesOverviewProvider.overrideWith(_FakeBadgesOverviewNotifier.new),
      ],
      child: MaterialApp(
        theme: AppThemes.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const BadgesOverviewPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('desktop tabs hug their labels and sit on the left', (
    WidgetTester tester,
  ) async {
    await _pumpOverview(tester, size: const Size(1440, 900));

    final Finder earnedTab = find.text('Earned (0)');
    final Finder requestedTab = find.text('Requested (0)');
    expect(earnedTab, findsOneWidget);
    expect(requestedTab, findsOneWidget);

    final Rect earned = tester.getRect(earnedTab);
    final Rect requested = tester.getRect(requestedTab);
    final double pageWidth = tester
        .getSize(find.byType(BadgesOverviewPage))
        .width;

    expect(earned.left, lessThan(32));
    expect(earned.right, lessThan(pageWidth / 2));
    expect(requested.left, lessThan(pageWidth / 2));
    expect(
      pageWidth,
      greaterThanOrEqualTo(LayoutConstants.badgesOverviewGridMinWidth),
    );
  });

  testWidgets('phone tabs still share the bar equally', (
    WidgetTester tester,
  ) async {
    await _pumpOverview(tester, size: const Size(390, 800));

    final Rect earned = tester.getRect(find.text('Earned (0)'));
    final Rect requested = tester.getRect(find.text('Requested (0)'));
    final double pageWidth = tester
        .getSize(find.byType(BadgesOverviewPage))
        .width;

    expect(pageWidth, lessThan(LayoutConstants.badgesOverviewGridMinWidth));
    expect(earned.center.dx, closeTo(pageWidth / 4, 24));
    expect(requested.center.dx, closeTo(pageWidth * 3 / 4, 24));
  });
}
