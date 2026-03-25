import 'package:edubadges/core/utils/logger.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const LinkText({super.key, required this.text, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final defaultStyle =
        style ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final linkStyle = defaultStyle.copyWith(
      color: colorScheme.primary,
      decoration: TextDecoration.underline,
    );

    final linkPattern = RegExp(r'\[([^\]]+)\]\(([^\)]+)\)');
    final matches = linkPattern.allMatches(text);

    if (matches.isEmpty) {
      return Text(text, style: defaultStyle, textAlign: textAlign);
    }

    final textSpans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        textSpans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: defaultStyle,
          ),
        );
      }

      final linkText = match.group(1) ?? '';
      final linkUrl = match.group(2) ?? '';

      textSpans.add(
        TextSpan(
          text: linkText,
          style: linkStyle,
          recognizer: TapGestureRecognizer()..onTap = () => _launchUrl(linkUrl),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      textSpans.add(
        TextSpan(text: text.substring(lastEnd), style: defaultStyle),
      );
    }

    return Semantics(
      container: true,
      child: RichText(
        textAlign: textAlign ?? TextAlign.start,
        text: TextSpan(style: defaultStyle, children: textSpans),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);

      final launchMode = uri.scheme == 'mailto'
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication;

      if (uri.scheme == 'mailto') {
        await launchUrl(uri, mode: launchMode);
      } else if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: launchMode);
      }
    } catch (e) {
      logger.e('Error launching URL: $e');
    }
  }
}
