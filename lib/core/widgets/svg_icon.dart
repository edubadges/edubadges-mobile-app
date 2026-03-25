import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;
  /// Descriptive text for assistive technologies. Use for meaningful icons.
  /// Omit or pass null when the icon is purely decorative (e.g. next to text that already describes the action).
  final String? semanticLabel;
  /// Set to true to hide this icon from assistive technologies (decorative only).
  final bool excludeFromSemantics;

  const SvgIcon({
    super.key,
    required this.assetPath,
    required this.size,
    this.color,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    final picture = SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
    if (excludeFromSemantics) {
      return ExcludeSemantics(child: picture);
    }
    if (semanticLabel != null && semanticLabel!.isNotEmpty) {
      return Semantics(label: semanticLabel, child: picture);
    }
    return picture;
  }
}
