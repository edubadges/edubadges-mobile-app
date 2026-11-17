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
      child: role == SemanticsRole.main ? _InMainLandmark(child: child) : child,
    );
  }
}

/// Makes the page [child] the main landmark, unless it is shown inside one
/// already: the tab pages are, in the main page's [PageAreaSemantics], while
/// pages opened over the whole window, such as a badge's details or the login
/// page, are not. Without one, checkers report the page as content outside any
/// landmark (axe `region`).
class MainLandmark extends StatelessWidget {
  final Widget child;

  const MainLandmark({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (context.dependOnInheritedWidgetOfExactType<_InMainLandmark>() != null) {
      return child;
    }
    return Semantics(
      container: true,
      role: SemanticsRole.main,
      child: _InMainLandmark(child: child),
    );
  }
}

class _InMainLandmark extends InheritedWidget {
  const _InMainLandmark({required super.child});

  @override
  bool updateShouldNotify(_InMainLandmark oldWidget) => false;
}
