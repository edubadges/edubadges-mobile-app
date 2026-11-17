import 'package:edubadges/core/widgets/page_area_semantics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// The ids of the semantics nodes above the one for [finder].
List<int> _ancestors(WidgetTester tester, Finder finder) => <int>[
  for (
    SemanticsNode? node = tester.getSemantics(finder).parent;
    node != null;
    node = node.parent
  )
    node.id,
];

void main() {
  testWidgets('suggestions opening next to a page leave the page in place', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    // A nested navigator, as in each tab of the main page.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageAreaSemantics(
            role: SemanticsRole.main,
            child: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  body: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue value) => <String>[
                      'Amsterdam',
                      'Utrecht',
                    ].where((String city) => city.contains(value.text)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final Finder field = find.byType(TextField);
    final List<int> before = _ancestors(tester, field);

    await tester.enterText(field, 'U');
    await tester.pumpAndSettle();

    expect(find.text('Utrecht'), findsOneWidget);
    // On the web a moved page loses the browser focus: the field would lose
    // focus and the suggestions would close again.
    expect(_ancestors(tester, field), before);
    semantics.dispose();
  });

  group('MainLandmark', () {
    int mainLandmarks(WidgetTester tester) {
      int count = 0;
      void visit(SemanticsNode node) {
        if (node.getSemanticsData().role == SemanticsRole.main) count++;
        node.visitChildren((SemanticsNode child) {
          visit(child);
          return true;
        });
      }

      visit(
        tester
            .binding
            .renderViews
            .first
            .owner!
            .semanticsOwner!
            .rootSemanticsNode!,
      );
      return count;
    }

    testWidgets('makes a page on its own the main landmark', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: MainLandmark(child: Scaffold(body: Text('Badge details'))),
        ),
      );

      expect(mainLandmarks(tester), 1);
      semantics.dispose();
    });

    testWidgets('adds none inside the main page area or another page', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageAreaSemantics(
              role: SemanticsRole.main,
              child: Navigator(
                onGenerateRoute: (_) => MaterialPageRoute<void>(
                  builder: (_) => const MainLandmark(
                    child: MainLandmark(child: Text('Catalog')),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(mainLandmarks(tester), 1);
      semantics.dispose();
    });
  });
}
