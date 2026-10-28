import 'package:edubadges/core/widgets/focus_ring_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps a child to make it focusable and activatable via keyboard (Enter/Space).
/// The focus ring is drawn by [FocusRingOverlay]; wrap this in a
/// [FocusRingShape] when the child is not a plain rectangle.
///
/// Not for a child that takes focus itself, such as an [InkWell] or a button:
/// that would make two tab stops for one control.
class KeyboardActivatable extends StatelessWidget {
  final Widget child;
  final VoidCallback? onActivate;
  final FocusNode? focusNode;
  final String? semanticLabel;
  final bool enabled;

  final bool wrapWithSemantics;

  final bool includeOuterTapTarget;

  const KeyboardActivatable({
    super.key,
    required this.child,
    this.onActivate,
    this.focusNode,
    this.semanticLabel,
    this.enabled = true,
    this.wrapWithSemantics = true,
    this.includeOuterTapTarget = true,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      focusNode: focusNode,
      enabled: enabled,
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                if (enabled && onActivate != null) {
                  onActivate!();
                  return null;
                }
                return null;
              },
            ),
          },
          child: _buildWrappedChild(),
        ),
      ),
    );
  }

  Widget _buildWrappedChild() {
    if (wrapWithSemantics) {
      return Semantics(
        button: true,
        enabled: enabled,
        label: semanticLabel,
        onTap: onActivate,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled && onActivate != null ? onActivate : null,
          child: child,
        ),
      );
    }
    if (includeOuterTapTarget) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled && onActivate != null ? onActivate : null,
        child: child,
      );
    }
    return child;
  }
}
