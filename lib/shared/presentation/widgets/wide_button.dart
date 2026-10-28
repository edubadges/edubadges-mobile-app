import 'package:edubadges/core/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class WideButton extends StatelessWidget {
  final Widget? icon;
  final String text;
  final Color? color;
  final bool secondary;
  final VoidCallback? onTap;
  final SemanticsSortKey? semanticsSortKey;
  const WideButton({
    super.key,
    required this.text,
    required this.icon,
    this.color,
    this.secondary = false,
    this.onTap,
    this.semanticsSortKey,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mainColor = color ?? colorScheme.onPrimary;

    // The ink well takes focus and handles Enter and Space itself.
    return Semantics(
      sortKey: semanticsSortKey,
      button: true,
      enabled: onTap != null,
      label: text,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(
              color: secondary ? Colors.transparent : mainColor,
              borderRadius: BorderRadius.circular(8),
              border: BoxBorder.all(
                color: secondary ? mainColor : Colors.transparent,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                if (icon != null) ExcludeSemantics(child: icon),
                ExcludeSemantics(
                  child: Text(
                    text,
                    style: textTheme.labelLarge?.copyWith(
                      color: secondary
                          ? mainColor
                          : getContrastingTextColor(mainColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
