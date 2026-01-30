import 'package:edubadges/core/utils/color.dart';
import 'package:flutter/material.dart';

void showSnackBar({
  required String text,
  Duration duration = const Duration(seconds: 3),
  required BuildContext context,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: getContrastingTextColor(
            Theme.of(context).snackBarTheme.backgroundColor ?? Colors.black,
          ),
        ),
      ),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
