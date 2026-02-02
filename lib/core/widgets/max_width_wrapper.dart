import 'package:flutter/material.dart';

class MaxWidthWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const MaxWidthWrapper({
    super.key,
    required this.child,
    this.maxWidth = 720.0
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = constraints.maxWidth > maxWidth
            ? maxWidth
            : constraints.maxWidth;

        return Center(
          child: Container(
            width: effectiveWidth,
            child: child,
          ),
        );
      },
    );
  }
}