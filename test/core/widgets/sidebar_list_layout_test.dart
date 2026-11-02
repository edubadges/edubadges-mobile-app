import 'package:edubadges/core/widgets/sidebar_list_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _button(String label, double height) {
  return SizedBox(
    height: height,
    child: TextButton(onPressed: () {}, child: Text(label)),
  );
}

String? _focusedLabel() {
  final BuildContext? context = FocusManager.instance.primaryFocus?.context;
  if (context == null) {
    return null;
  }
  final TextButton? button = context
      .findAncestorWidgetOfExactType<TextButton>();
  return (button?.child as Text?)?.data;
}

void main() {
  testWidgets(
    'Tab moves through the whole sidebar before the list, whatever the '
    'heights of the controls in either column',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1400, 1000);
      addTearDown(tester.view.reset);

      final ScrollController scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      // The list's second button sits above the sidebar's second one, so
      // a plain reading order would visit it in between.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SidebarListLayout(
              useSidebarLayout: true,
              scrollController: scrollController,
              onRefresh: () async {},
              sidebar: Column(
                children: [_button('sidebar 1', 300), _button('sidebar 2', 48)],
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _button('list 1', 48),
                      _button('list 2', 48),
                      _button('list 3', 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final List<String?> order = [];
      for (int i = 0; i < 5; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        order.add(_focusedLabel());
      }

      expect(order, ['sidebar 1', 'sidebar 2', 'list 1', 'list 2', 'list 3']);
    },
  );
}
