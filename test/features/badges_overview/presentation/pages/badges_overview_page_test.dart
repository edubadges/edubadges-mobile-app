import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/constants/layout_constants.dart';
import 'package:edubadges/features/badges_overview/domain/entities/badges_overview_state.dart';
import 'package:edubadges/features/badges_overview/presentation/pages/badges_overview_page.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../collections/collections_test_helpers.dart';

class _FakeBadgesOverviewNotifier extends BadgesOverviewNotifier {
  final List<BadgeInstanceEntity> claimedBadges;

  _FakeBadgesOverviewNotifier({this.claimedBadges = const []});

  @override
  Future<BadgesOverviewState> build() async {
    return BadgesOverviewState(
      claimedBadges: claimedBadges,
      unclaimedBadges: const [],
      requestedBadges: const [],
    );
  }

  @override
  Future<void> refresh({bool silent = true}) async {}
}

Future<void> _pumpOverview(
  WidgetTester tester, {
  required Size size,
  List<BadgeInstanceEntity> claimedBadges = const [],
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        badgesOverviewProvider.overrideWith(
          () => _FakeBadgesOverviewNotifier(claimedBadges: claimedBadges),
        ),
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

/// The badge whose card holds keyboard focus, from the key the overview puts
/// on each badge, or null when focus is elsewhere.
String? _focusedBadgeKey() {
  String? badgeKey;
  FocusManager.instance.primaryFocus?.context?.visitAncestorElements((
    Element element,
  ) {
    final Key? key = element.widget.key;
    if (key is ValueKey<String> && key.value.startsWith('claimed_badge_')) {
      badgeKey = key.value;
      return false;
    }
    return true;
  });
  return badgeKey;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Badge cards build image URLs from the configured API host.
    if (!EnvironmentConfig.instance.isInitialized) {
      EnvironmentConfig.instance.init(
        apiUrl: 'https://api.example.test',
        openIdUrl: 'https://login.example.test',
        openIdClientId: 'test-client',
        enableAnalytics: false,
        enableCrashlytics: false,
        publicCollectionBaseUrl: 'https://example.test',
        piwikProBaseUrl: 'https://analytics.example.test',
        piwikProSiteId: 'test-site',
      );
    }
  });

  testWidgets('each badge is a single tab stop', (WidgetTester tester) async {
    await _pumpOverview(
      tester,
      size: const Size(390, 800),
      claimedBadges: [testBadge('a'), testBadge('b')],
    );

    // Tabs through one full round of the page.
    final Set<FocusNode> visited = <FocusNode>{};
    final Map<String, int> stopsPerBadge = <String, int>{};
    for (int i = 0; i < 20; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      if (!visited.add(FocusManager.instance.primaryFocus!)) break;
      final String? badgeKey = _focusedBadgeKey();
      if (badgeKey != null) {
        stopsPerBadge.update(
          badgeKey,
          (int stops) => stops + 1,
          ifAbsent: () => 1,
        );
      }
    }

    expect(stopsPerBadge, <String, int>{
      'claimed_badge_a': 1,
      'claimed_badge_b': 1,
    });
  });

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

  testWidgets('the phone layout has a page heading for screen readers', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await _pumpOverview(tester, size: const Size(390, 800));

    expect(
      tester.getSemantics(find.bySemanticsLabel('My Edubadges')),
      isSemantics(label: 'My Edubadges', isHeader: true),
    );
    semantics.dispose();
  });
}
