import 'package:edubadges/core/constants/heading_level.dart';
import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final EdgeInsetsGeometry padding;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 0),
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  headingLevel: HeadingLevel.page,
                  child: Text(title, style: textTheme.titleLarge),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ...?actions,
        ],
      ),
    );
  }
}
