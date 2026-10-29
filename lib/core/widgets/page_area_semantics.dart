import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// The semantics node around a [Navigator]: the area its pages are shown in.
///
/// Every page route wraps its content in an ordering annotation
/// (`Semantics(sortKey: OrdinalSortKey(0))`). While the page is alone in its
/// overlay, that annotation is merged into the node above it. When a popup
/// opens next to the page (such as autocomplete suggestions), Flutter gives
/// the annotation a node of its own, inserted above the page. On the web that
/// moves the page's whole element tree, and the browser takes focus off
/// whatever had it, such as the text field the suggestions belong to, which
/// closes them again.
///
/// With explicit child nodes the annotation always has its own node, so a
/// popup only adds a sibling and the page stays where it is.
class PageAreaSemantics extends StatelessWidget {
  /// The landmark the area is, if any, such as [SemanticsRole.main].
  final SemanticsRole? role;
  final Widget child;

  const PageAreaSemantics({super.key, this.role, required this.child});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: role,
      child: child,
    );
  }
}
