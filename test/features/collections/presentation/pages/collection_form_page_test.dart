import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/utils/route_exit_guard.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/features/collections/presentation/pages/collection_form_page.dart';
import 'package:edubadges/features/collections/presentation/providers/collections_providers.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../collections_test_helpers.dart';

final _b1 = testBadge('b1');
final _b2 = testBadge('b2');
final _b3 = testBadge('b3', public: false);

const String _detailText = 'collection detail c1';

class _Harness {
  final GoRouter router;
  final FakeCollectionsRepository repository;
  final ProviderContainer container;

  _Harness(this.router, this.repository, this.container);
}

/// Opens the edit screen on top of a stand-in collection detail, wired like
/// `routes.dart` (onExit forwarded to the page's exit guard).
///
/// By default the collections are already loaded, as when coming from the
/// detail page. With [deepLink] the edit screen is the first route and has to
/// wait for the collections to load.
Future<_Harness> _openEditScreen(
  WidgetTester tester, {
  bool deepLink = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(420, 1400);
  addTearDown(tester.view.reset);

  final repository = FakeCollectionsRepository();
  final exitGuard = RouteExitGuard();
  final router = GoRouter(
    initialLocation: deepLink
        ? RoutePath.editCollectionPath(id: 'c1')
        : '/collection/c1',
    routes: [
      GoRoute(
        path: RoutePath.collection,
        builder: (context, state) => const Scaffold(body: Text(_detailText)),
      ),
      GoRoute(
        path: RoutePath.editCollection,
        onExit: (context, state) => exitGuard.canExit(),
        builder: (context, state) => CollectionFormPage.edit(
          collectionId: state.pathParameters['id']!,
          exitGuard: exitGuard,
        ),
      ),
    ],
  );
  addTearDown(router.dispose);

  final container = ProviderContainer(
    overrides: collectionsTestOverrides(
      repository: repository,
      collections: [
        testCollection(badges: [_b1, _b2]),
      ],
      claimedBadges: [_b1, _b2, _b3],
    ),
  );
  addTearDown(container.dispose);
  if (!deepLink) {
    await container.read(badgesOverviewProvider.future);
    await container.read(collectionsProvider.future);
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppThemes.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (!deepLink) {
    unawaited(router.push(RoutePath.editCollectionPath(id: 'c1')));
    await tester.pumpAndSettle();
  }

  expect(find.text('Edit collection'), findsOneWidget);
  return _Harness(router, repository, container);
}

const String _overviewText = 'collections overview';

/// Opens "Nieuwe collectie" on top of a stand-in collections overview, as the
/// "+" on the overview does.
Future<_Harness> _openCreateScreen(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(420, 1400);
  addTearDown(tester.view.reset);

  final repository = FakeCollectionsRepository();
  final router = GoRouter(
    initialLocation: RoutePath.collections,
    routes: [
      GoRoute(
        path: RoutePath.collections,
        builder: (context, state) => const Scaffold(body: Text(_overviewText)),
      ),
      GoRoute(
        path: RoutePath.newCollection,
        builder: (context, state) => const CollectionFormPage.create(),
      ),
    ],
  );
  addTearDown(router.dispose);

  final container = ProviderContainer(
    overrides: collectionsTestOverrides(
      repository: repository,
      collections: const [],
      claimedBadges: [_b1, _b2, _b3],
    ),
  );
  addTearDown(container.dispose);
  await container.read(badgesOverviewProvider.future);
  await container.read(collectionsProvider.future);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppThemes.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  unawaited(router.push(RoutePath.newCollection));
  await tester.pumpAndSettle();

  expect(find.text('New collection'), findsOneWidget);
  return _Harness(router, repository, container);
}

bool _isChecked(WidgetTester tester, String badgeEntityId) {
  final checkbox = find.descendant(
    of: find.byKey(ValueKey<String>(badgeEntityId)),
    matching: find.byType(Checkbox),
  );
  return tester.widget<Checkbox>(checkbox).value ?? false;
}

Future<void> _tapBadge(WidgetTester tester, String badgeEntityId) async {
  await tester.tap(find.text('Badge $badgeEntityId'));
  await tester.pumpAndSettle();
}

Future<void> _tapSave(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
  await tester.pumpAndSettle();
}

Future<void> _tapClose(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Close'));
  await tester.pumpAndSettle();
}

Finder get _unsavedChangesDialog => find.text('Save changes?');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CollectionFormPage.edit', () {
    testWidgets('prefills the form and pre-selects the collection badges', (
      tester,
    ) async {
      await _openEditScreen(tester);

      expect(find.widgetWithText(TextFormField, 'Testcollectie 2'), findsOne);
      expect(find.widgetWithText(TextFormField, 'Omschrijving'), findsOne);
      expect(find.text('Badges in collection'), findsOneWidget);
      expect(_isChecked(tester, 'b1'), isTrue);
      expect(_isChecked(tester, 'b2'), isTrue);
      expect(_isChecked(tester, 'b3'), isFalse);
    });

    testWidgets('fills the form once loaded when opened directly', (
      tester,
    ) async {
      await _openEditScreen(tester, deepLink: true);

      expect(find.widgetWithText(TextFormField, 'Testcollectie 2'), findsOne);
      expect(_isChecked(tester, 'b1'), isTrue);
      expect(_isChecked(tester, 'b3'), isFalse);

      // Nothing to pop: closing falls back to the collection detail.
      await _tapClose(tester);
      expect(find.text(_detailText), findsOneWidget);
    });

    testWidgets('saves the new badge list and closes', (tester) async {
      final harness = await _openEditScreen(tester);

      await _tapBadge(tester, 'b1'); // remove
      await _tapBadge(tester, 'b3'); // add
      expect(_isChecked(tester, 'b1'), isFalse);
      expect(_isChecked(tester, 'b3'), isTrue);

      await _tapSave(tester);

      final call = harness.repository.patchCalls.single;
      expect(call.entityId, 'c1');
      expect(call.name, 'Testcollectie 2');
      expect(call.description, 'Omschrijving');
      expect(call.badgeInstanceIds, ['b2', 'b3']);
      expect(find.text(_detailText), findsOneWidget);
      expect(_unsavedChangesDialog, findsNothing);

      final collection = harness.container
          .read(collectionsProvider)
          .requireValue
          .single;
      expect(collection.badgeInstances, [_b2, _b3]);
    });

    testWidgets('allows saving with every badge removed', (tester) async {
      final harness = await _openEditScreen(tester);

      await _tapBadge(tester, 'b1');
      await _tapBadge(tester, 'b2');
      await _tapSave(tester);

      expect(harness.repository.patchCalls.single.badgeInstanceIds, isEmpty);
      expect(find.text(_detailText), findsOneWidget);
    });

    testWidgets('requires a name', (tester) async {
      final harness = await _openEditScreen(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Testcollectie 2'),
        '   ',
      );
      await _tapSave(tester);

      expect(find.text('This field is required'), findsOneWidget);
      expect(harness.repository.patchCalls, isEmpty);
      expect(find.text('Edit collection'), findsOneWidget);
    });

    testWidgets('stays open and reports a failed save', (tester) async {
      final harness = await _openEditScreen(tester);
      harness.repository.patchResult = const Left(ServerFailure('Boom', 500));

      await _tapBadge(tester, 'b3');
      await _tapSave(tester);

      expect(harness.repository.patchCalls, hasLength(1));
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Edit collection'), findsOneWidget);
      expect(_isChecked(tester, 'b3'), isTrue);
    });

    testWidgets('saving without changes closes without a request', (
      tester,
    ) async {
      final harness = await _openEditScreen(tester);

      await _tapSave(tester);

      expect(harness.repository.patchCalls, isEmpty);
      expect(find.text(_detailText), findsOneWidget);
    });

    group('leaving', () {
      testWidgets('closes right away when nothing changed', (tester) async {
        final harness = await _openEditScreen(tester);

        await _tapClose(tester);

        expect(_unsavedChangesDialog, findsNothing);
        expect(find.text(_detailText), findsOneWidget);
        expect(harness.repository.patchCalls, isEmpty);
      });

      testWidgets('closes right away after undoing a change', (tester) async {
        await _openEditScreen(tester);

        await _tapBadge(tester, 'b3');
        await _tapBadge(tester, 'b3');
        await _tapClose(tester);

        expect(_unsavedChangesDialog, findsNothing);
        expect(find.text(_detailText), findsOneWidget);
      });

      testWidgets('"Don\'t save" discards the changes and closes', (
        tester,
      ) async {
        final harness = await _openEditScreen(tester);

        await _tapBadge(tester, 'b3');
        await _tapClose(tester);

        expect(_unsavedChangesDialog, findsOneWidget);
        expect(
          find.text(
            'You have made changes to this collection. Do you want to save '
            'them before you leave this screen?',
          ),
          findsOneWidget,
        );
        await tester.tap(find.text("Don't save"));
        await tester.pumpAndSettle();

        expect(harness.repository.patchCalls, isEmpty);
        expect(find.text(_detailText), findsOneWidget);
      });

      testWidgets('"Save" saves the changes and closes', (tester) async {
        final harness = await _openEditScreen(tester);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Testcollectie 2'),
          'Nieuwe naam',
        );
        await _tapBadge(tester, 'b2');
        await _tapClose(tester);

        await tester.tap(
          find.descendant(of: find.byType(Dialog), matching: find.text('Save')),
        );
        await tester.pumpAndSettle();

        final call = harness.repository.patchCalls.single;
        expect(call.name, 'Nieuwe naam');
        expect(call.badgeInstanceIds, ['b1']);
        expect(find.text(_detailText), findsOneWidget);
      });

      testWidgets('"Save" in the dialog still validates the name', (
        tester,
      ) async {
        final harness = await _openEditScreen(tester);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Testcollectie 2'),
          '',
        );
        await _tapClose(tester);
        await tester.tap(
          find.descendant(of: find.byType(Dialog), matching: find.text('Save')),
        );
        await tester.pumpAndSettle();

        expect(harness.repository.patchCalls, isEmpty);
        expect(find.text('This field is required'), findsOneWidget);
        expect(find.text('Edit collection'), findsOneWidget);
      });

      testWidgets('dismissing the dialog keeps the screen open', (
        tester,
      ) async {
        await _openEditScreen(tester);

        await _tapBadge(tester, 'b3');
        await _tapClose(tester);
        await tester.tapAt(const Offset(10, 10)); // barrier
        await tester.pumpAndSettle();

        expect(_unsavedChangesDialog, findsNothing);
        expect(find.text('Edit collection'), findsOneWidget);
        expect(_isChecked(tester, 'b3'), isTrue);
      });

      testWidgets('asks on system back', (tester) async {
        await _openEditScreen(tester);

        await _tapBadge(tester, 'b3');
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(_unsavedChangesDialog, findsOneWidget);
        await tester.tap(find.text("Don't save"));
        await tester.pumpAndSettle();

        expect(find.text(_detailText), findsOneWidget);
      });

      testWidgets('system back without changes closes right away', (
        tester,
      ) async {
        await _openEditScreen(tester);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(_unsavedChangesDialog, findsNothing);
        expect(find.text(_detailText), findsOneWidget);
      });

      testWidgets('asks when navigated away (browser back on web)', (
        tester,
      ) async {
        final harness = await _openEditScreen(tester);

        await _tapBadge(tester, 'b3');
        harness.router.go('/collection/c1');
        await tester.pumpAndSettle();

        expect(_unsavedChangesDialog, findsOneWidget);
        expect(find.text('Edit collection'), findsOneWidget);

        await tester.tap(find.text("Don't save"));
        await tester.pumpAndSettle();

        expect(find.text(_detailText), findsOneWidget);
        expect(harness.repository.patchCalls, isEmpty);
      });
    });
  });

  group('CollectionFormPage.create', () {
    testWidgets('starts empty with Save and Cancel', (tester) async {
      await _openCreateScreen(tester);

      expect(_isChecked(tester, 'b1'), isFalse);
      expect(_isChecked(tester, 'b2'), isFalse);
      expect(_isChecked(tester, 'b3'), isFalse);
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
      expect(find.byTooltip('Close'), findsNothing);
    });

    testWidgets('asks for a name and at least one badge', (tester) async {
      final harness = await _openCreateScreen(tester);
      final ThemeData theme = AppThemes.lightTheme;

      await _tapSave(tester);

      expect(find.text('This field is required'), findsOneWidget);
      final Text heading = tester.widget(find.text('Badges in collection'));
      expect(heading.style?.color, theme.colorScheme.error);
      expect(harness.repository.createCalls, isEmpty);
      expect(find.text('New collection'), findsOneWidget);

      // Selecting a badge clears its error.
      await _tapBadge(tester, 'b1');
      final Text headingAfter = tester.widget(
        find.text('Badges in collection'),
      );
      expect(headingAfter.style?.color, isNot(theme.colorScheme.error));
    });

    testWidgets('creates the collection with the selected badges', (
      tester,
    ) async {
      final harness = await _openCreateScreen(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name of the collection'),
        'Mijn collectie',
      );
      await _tapBadge(tester, 'b2');
      await _tapBadge(tester, 'b1');
      await _tapSave(tester);

      final call = harness.repository.createCalls.single;
      expect(call.name, 'Mijn collectie');
      expect(call.public, isFalse);
      expect(call.badgeInstanceIds, ['b2', 'b1']);
      expect(find.text(_overviewText), findsOneWidget);
    });

    testWidgets('Cancel leaves without saving or asking', (tester) async {
      final harness = await _openCreateScreen(tester);

      await _tapBadge(tester, 'b1');
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(_unsavedChangesDialog, findsNothing);
      expect(harness.repository.createCalls, isEmpty);
      expect(find.text(_overviewText), findsOneWidget);
    });

    testWidgets('stays open and reports a failed save', (tester) async {
      final harness = await _openCreateScreen(tester);
      harness.repository.createFailure = const ServerFailure('Boom', 500);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name of the collection'),
        'Mijn collectie',
      );
      await _tapBadge(tester, 'b1');
      await _tapSave(tester);

      expect(harness.repository.createCalls, hasLength(1));
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('New collection'), findsOneWidget);
      // The collections underneath keep their data.
      expect(harness.container.read(collectionsProvider).hasError, isFalse);
    });
  });
}
