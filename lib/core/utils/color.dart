
import 'package:flutter/material.dart';

Color getContrastingTextColor(Color backgroundColor) {
  final luminance = backgroundColor.computeLuminance();
  
  // Use white text on dark backgrounds, black text on light backgrounds
  // Threshold of 0.5 provides good contrast
  return luminance > 0.5 ? Colors.black : Colors.white;
}