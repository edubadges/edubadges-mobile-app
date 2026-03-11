import 'package:edubadges/core/utils/color.dart';
import 'package:flutter/material.dart';

class WideButton extends StatelessWidget {
  final Widget? icon;
  final String text;
  final Color? color;
  final bool secondary;
  final VoidCallback? onTap;
  const WideButton({
    super.key,
    required this.text,
    required this.icon,
    this.color,
    this.secondary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mainColor = color ?? colorScheme.onPrimary;

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: text,
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
                if (icon != null) icon!,
                Text(
                  text,
                  style: textTheme.labelLarge?.copyWith(
                    color: secondary
                        ? mainColor
                        : getContrastingTextColor(mainColor),
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
