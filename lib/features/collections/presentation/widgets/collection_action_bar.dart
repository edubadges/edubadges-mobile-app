import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:flutter/material.dart';

/// Buttons at the bottom of the collection form, stacked like the design
/// ("Opslaan", then "Annuleren").
///
/// Stays clear of the system navigation bar (Android buttons, iOS home
/// indicator) and keeps the buttons at the content width used by
/// [MaxWidthWrapper], so they line up with the form on wide (web) layouts.
class CollectionActionBar extends StatelessWidget {
  final List<Widget> children;

  const CollectionActionBar({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: MaxWidthWrapper.defaultMaxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
