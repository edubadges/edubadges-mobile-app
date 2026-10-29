import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/widgets/page_area_semantics.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/account/presentation/providers/account_providers.dart';
import 'package:edubadges/features/main/main_page.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeProfileNotifier extends ProfileNotifier {
  @override
  Future<ProfileEntity?> build() async => null;
}

StatefulShellBranch _branch(String path) => StatefulShellBranch(
  routes: <RouteBase>[
    GoRoute(
      path: path,
      builder: (BuildContext context, GoRouterState state) => Scaffold(
        // Pages put actions at the top right, above the first drawer item.
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {},
              tooltip: 'Give feedback',
              icon: const Icon(Icons.feedback),
            ),
          ],
        ),
        body: Center(child: Text('page $path')),
      ),
    ),
  ],
);

Future<void> _pumpMainPage(WidgetTester tester, {required Size size}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final GoRouter router = GoRouter(
    initialLocation: '/badges',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => MainPage(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          _branch('/badges'),
          _branch('/collections'),
          _branch('/catalog'),
          _branch('/account'),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [profileProvider.overrideWith(_FakeProfileNotifier.new)],
      child: MaterialApp.router(
        theme: AppThemes.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('screen readers get the navigation drawer beside the pages', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await _pumpMainPage(tester, size: const Size(1280, 800));

    expect(find.byType(NavigationDrawer), findsOneWidget);
    // The page routes beside the drawer used to drop its semantics, so these
    // labels were missing from the tree although they were on screen.
    for (final String label in <String>[
      'Edubadges',
      'Collections',
      'Catalog',
      'Account',
    ]) {
      expect(
        // Drawer items read as "<label>, Tab n of 4".
        find.bySemanticsLabel(RegExp('^$label\nTab')),
        findsOneWidget,
        reason: label,
      );
    }
    semantics.dispose();
  });

  testWidgets('Shift+Tab from the top of the page reaches the drawer', (
    WidgetTester tester,
  ) async {
    await _pumpMainPage(tester, size: const Size(1280, 800));

    // Focus starts in the page, like a skip link to the content.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<IconButton>(),
      isNotNull,
    );

    // The navigation is one step back, not behind every badge on the page.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    await tester.pumpAndSettle();
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<NavigationDrawer>(),
      isNotNull,
    );
  });

  for (final Size size in <Size>[const Size(1280, 800), const Size(390, 800)]) {
    testWidgets(
      'marks the page and the navigation as landmarks at ${size.width.toInt()}px',
      (WidgetTester tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        await _pumpMainPage(tester, size: size);

        final List<SemanticsRole> roles = <SemanticsRole>[];
        void collect(SemanticsNode node) {
          roles.add(node.getSemanticsData().role);
          node.visitChildren((SemanticsNode child) {
            collect(child);
            return true;
          });
        }

        collect(
          tester
              .binding
              .renderViews
              .first
              .owner!
              .semanticsOwner!
              .rootSemanticsNode!,
        );
        expect(
          roles.where((SemanticsRole role) => role == SemanticsRole.main),
          hasLength(1),
        );
        expect(
          roles.where((SemanticsRole role) => role == SemanticsRole.navigation),
          hasLength(1),
        );
        // So suggestions opening on a page don't move it (and take the
        // browser focus off their text field).
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is PageAreaSemantics &&
                widget.role == SemanticsRole.main,
          ),
          findsOneWidget,
        );
        semantics.dispose();
      },
    );
  }
}
