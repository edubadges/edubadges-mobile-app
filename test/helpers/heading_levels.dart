import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// The level of every heading on screen, by label. A heading without a level
/// counts as 2, which is what the web makes of it. Two headings with the same
/// label fail the test, so a duplicate cannot hide in the map.
///
/// Needs semantics on, for example with [WidgetTester.ensureSemantics].
Map<String, int> headingLevels(WidgetTester tester) {
  final Map<String, int> levels = {};
  void visit(SemanticsNode node) {
    final SemanticsData data = node.getSemanticsData();
    if (data.flagsCollection.isHeader || data.headingLevel > 0) {
      expect(
        levels.containsKey(data.label),
        isFalse,
        reason: 'more than one heading is named "${data.label}"',
      );
      levels[data.label] = data.headingLevel == 0 ? 2 : data.headingLevel;
    }
    node.visitChildren((SemanticsNode child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return levels;
}
