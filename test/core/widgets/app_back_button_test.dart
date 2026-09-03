import 'dart:async';

import 'package:edubadges/core/widgets/actionable_content_layout.dart';
import 'package:edubadges/core/widgets/app_back_button.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const String _homeLocation = '/home';
const String _detailLocation = '/detail';

Widget _buildTestApp(GoRouter router) {
  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

GoRouter _buildRouter({
  required String initialLocation,
  required Widget detail,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: _homeLocation,
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Text('home')),
      ),
      GoRoute(
        path: _detailLocation,
        builder: (BuildContext context, GoRouterState state) => detail,
      ),
    ],
  );
}

Widget _detailScaffold({Widget? leading}) {
  return Scaffold(
    appBar: AppBar(automaticallyImplyLeading: false, leading: leading),
    body: const Text('detail'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppBackButton', () {
    testWidgets('pops to the previous route when there is history', (
      WidgetTester tester,
    ) async {
      final GoRouter router = _buildRouter(
        initialLocation: _homeLocation,
        detail: _detailScaffold(
          leading: const AppBackButton(fallbackLocation: _homeLocation),
        ),
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildTestApp(router));
      unawaited(router.push(_detailLocation));
      await tester.pumpAndSettle();
      expect(find.text('detail'), findsOneWidget);

      await tester.tap(find.byType(AppBackButton));
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
      expect(find.text('detail'), findsNothing);
    });

    testWidgets('navigates to the fallback when opened as a deep link', (
      WidgetTester tester,
    ) async {
      final GoRouter router = _buildRouter(
        initialLocation: _detailLocation,
        detail: _detailScaffold(
          leading: const AppBackButton(fallbackLocation: _homeLocation),
        ),
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildTestApp(router));
      await tester.pumpAndSettle();
      expect(find.text('detail'), findsOneWidget);

      await tester.tap(find.byType(AppBackButton));
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('prefers an explicit onPressed over route navigation', (
      WidgetTester tester,
    ) async {
      int pressCount = 0;
      final GoRouter router = _buildRouter(
        initialLocation: _detailLocation,
        detail: _detailScaffold(
          leading: AppBackButton(onPressed: () => pressCount++),
        ),
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildTestApp(router));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AppBackButton));
      await tester.pumpAndSettle();

      expect(pressCount, 1);
      expect(find.text('detail'), findsOneWidget);
    });

    testWidgets('exposes the localized back label as a tooltip', (
      WidgetTester tester,
    ) async {
      final GoRouter router = _buildRouter(
        initialLocation: _detailLocation,
        detail: _detailScaffold(leading: const AppBackButton()),
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildTestApp(router));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Back'), findsOneWidget);
    });
  });

  group('AppBackTextButton', () {
    testWidgets('renders a visible back label', (WidgetTester tester) async {
      final GoRouter router = _buildRouter(
        initialLocation: _detailLocation,
        detail: const Scaffold(
          body: AppBackTextButton(fallbackLocation: _homeLocation),
        ),
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildTestApp(router));
      await tester.pumpAndSettle();

      expect(find.text('Back'), findsOneWidget);

      await tester.tap(find.byType(AppBackTextButton));
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
    });
  });

  group('ActionableContentLayout', () {
    testWidgets('shows a back button on every platform', (
      WidgetTester tester,
    ) async {
      final GoRouter router = _buildRouter(
        initialLocation: _detailLocation,
        detail: const ActionableContentLayout(
          title: 'Detail',
          content: Text('detail'),
          actions: <Widget>[],
          backFallbackLocation: _homeLocation,
        ),
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildTestApp(router));
      await tester.pumpAndSettle();

      expect(find.byType(AppBackButton), findsOneWidget);

      await tester.tap(find.byType(AppBackButton));
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('hides the back button when showBackButton is false', (
      WidgetTester tester,
    ) async {
      final GoRouter router = _buildRouter(
        initialLocation: _detailLocation,
        detail: const ActionableContentLayout(
          title: 'Detail',
          content: Text('detail'),
          actions: <Widget>[],
          showBackButton: false,
        ),
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_buildTestApp(router));
      await tester.pumpAndSettle();

      expect(find.byType(AppBackButton), findsNothing);
    });
  });
}
