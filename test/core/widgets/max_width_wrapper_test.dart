import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _wideViewport = Size(1200, 600);
const double _viewportWidth = 1200;
const double _maxWidth = 720;
const double _horizontalMargin = (_viewportWidth - _maxWidth) / 2;

Future<void> _withMacOsPlatform(
  WidgetTester tester,
  Future<void> Function() runTest,
) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
  try {
    await runTest();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

Future<void> _setWideViewport(WidgetTester tester) async {
  final TestFlutterView view = tester.view;
  view.physicalSize = _wideViewport;
  view.devicePixelRatio = 1.0;
  addTearDown(view.resetPhysicalSize);
  addTearDown(view.resetDevicePixelRatio);
}

Widget _buildTestApp({
  required Widget child,
  ScrollController? scrollController,
  bool enableScrollbar = true,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(size: _wideViewport),
      child: Scaffold(
        body: MaxWidthWrapper(
          maxWidth: _maxWidth,
          enableScrollbar: enableScrollbar,
          scrollController: scrollController,
          child: child,
        ),
      ),
    ),
  );
}

Widget _tallListView({ScrollController? controller}) {
  return ListView.builder(
    controller: controller,
    itemCount: 50,
    itemBuilder: (BuildContext context, int index) {
      return SizedBox(
        height: 80,
        child: Center(child: Text('Item $index')),
      );
    },
  );
}

Widget _accountStyleScrollView() {
  return Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: List<Widget>.generate(
              50,
              (int index) => SizedBox(
                height: 80,
                child: Center(child: Text('Section $index')),
              ),
            ),
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: Placeholder(),
        ),
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'links child scroll controller when child has explicit controller',
    (WidgetTester tester) async {
      await _withMacOsPlatform(tester, () async {
        await _setWideViewport(tester);
        final ScrollController scrollController = ScrollController();
        addTearDown(scrollController.dispose);

        await tester.pumpWidget(
          _buildTestApp(
            scrollController: scrollController,
            child: _tallListView(controller: scrollController),
          ),
        );
        await tester.pumpAndSettle();

        expect(scrollController.hasClients, isTrue);
        expect(scrollController.offset, 0);
      });
    },
  );

  testWidgets(
    'links child via PrimaryScrollController when no explicit controller',
    (WidgetTester tester) async {
      await _withMacOsPlatform(tester, () async {
        await _setWideViewport(tester);
        await tester.pumpWidget(
          _buildTestApp(child: _accountStyleScrollView()),
        );
        await tester.pumpAndSettle();

        final ScrollableState scrollableState = tester.state<ScrollableState>(
          find.byType(Scrollable),
        );

        expect(scrollableState.position.hasContentDimensions, isTrue);
        expect(scrollableState.position.maxScrollExtent, greaterThan(0));
      });
    },
  );

  testWidgets('shared scroll controller moves content', (WidgetTester tester) async {
    await _withMacOsPlatform(tester, () async {
      await _setWideViewport(tester);
      final ScrollController scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          scrollController: scrollController,
          child: _tallListView(controller: scrollController),
        ),
      );
      await tester.pumpAndSettle();
      expect(scrollController.position.maxScrollExtent, greaterThan(0));

      scrollController.jumpTo(120);

      expect(scrollController.offset, 120);
    });
  });

  testWidgets('margin pointer scroll forwards to linked controller', (
    WidgetTester tester,
  ) async {
    await _withMacOsPlatform(tester, () async {
      await _setWideViewport(tester);
      final ScrollController scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          scrollController: scrollController,
          child: _tallListView(controller: scrollController),
        ),
      );
      await tester.pumpAndSettle();
      expect(scrollController.position.maxScrollExtent, greaterThan(0));
      expect(find.byType(Scrollbar), findsOneWidget);
      expect(scrollController.offset, 0);

      final TestPointer pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(const Offset(_horizontalMargin / 2, 300)),
      );
      await tester.pump();
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 120)));
      await tester.pump();

      expect(scrollController.offset, greaterThan(0));
    });
  });

  testWidgets('scrollbar uses the same controller as the scroll view', (
    WidgetTester tester,
  ) async {
    await _withMacOsPlatform(tester, () async {
      await _setWideViewport(tester);
      final ScrollController scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          scrollController: scrollController,
          child: _tallListView(controller: scrollController),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scrollbar), findsOneWidget);
      expect(scrollController.hasClients, isTrue);
      expect(scrollController.positions.length, 1);
    });
  });

  testWidgets(
    'margin scroll does nothing when content fits viewport',
    (WidgetTester tester) async {
      await _withMacOsPlatform(tester, () async {
        await _setWideViewport(tester);
        final ScrollController scrollController = ScrollController();
        addTearDown(scrollController.dispose);

        await tester.pumpWidget(
          _buildTestApp(
            scrollController: scrollController,
            child: ListView(
              controller: scrollController,
              children: const [
                SizedBox(height: 100, child: Center(child: Text('Short'))),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        final TestPointer pointer = TestPointer(1, PointerDeviceKind.mouse);
        await tester.sendEventToBinding(
          pointer.hover(const Offset(_horizontalMargin / 2, 300)),
        );
        await tester.pump();
        await tester.sendEventToBinding(pointer.scroll(const Offset(0, 200)));
        await tester.pump();

        expect(scrollController.offset, 0);
      });
    },
  );

  testWidgets('enableScrollbar false omits outer Scrollbar', (
    WidgetTester tester,
  ) async {
    await _withMacOsPlatform(tester, () async {
      await _setWideViewport(tester);
      await tester.pumpWidget(
        _buildTestApp(
          enableScrollbar: false,
          child: const Center(child: Text('Static')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scrollbar), findsNothing);
      expect(find.text('Static'), findsOneWidget);
    });
  });
}
