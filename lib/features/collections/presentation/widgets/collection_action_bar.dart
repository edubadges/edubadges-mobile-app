import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:flutter/material.dart';

/// Bottom bar holding the primary action of the collection badge screens.
///
/// The background and top border span the full width while the [child] stays
/// constrained to the content width used by [MaxWidthWrapper], so the button
/// lines up with the list above it on wide (web) layouts.
class CollectionActionBar extends StatelessWidget {
  final Widget child;

  const CollectionActionBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: MaxWidthWrapper.defaultMaxWidth,
            ),
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ),
    );
  }
}
