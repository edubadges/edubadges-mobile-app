import 'package:flutter/material.dart';

/// Wraps content so it can receive focus (keyboard and assistive-tech).
/// Does not add activation (no Enter/Space action). Use for sections that have
/// no focusable descendants so they can be reached.
class FocusableSection extends StatelessWidget {
  final Widget child;
  final bool autofocus;

  const FocusableSection({
    super.key,
    required this.child,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      enabled: true,
      autofocus: autofocus,
      child: Semantics(container: true, child: child),
    );
  }
}
