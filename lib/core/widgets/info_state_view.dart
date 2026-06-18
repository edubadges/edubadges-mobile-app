import 'package:edubadges/app/colors.dart';
import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/widgets/debug_error_log_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InfoStateView extends StatelessWidget {
  final String assetPath;
  final String? title;
  final String description;
  final Color? iconColor;
  final Object? error;
  final StackTrace? stackTrace;
  final String? debugContext;

  const InfoStateView({
    super.key,
    this.assetPath = Assets.iconInfo,
    this.title,
    required this.description,
    this.iconColor = AppColors.primary,
    this.error,
    this.stackTrace,
    this.debugContext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double size = title == null ? 38 : 48;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: SvgPicture.asset(
                assetPath,
                width: size,
                height: size,
                colorFilter: iconColor != null
                    ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                    : null,
              ),
            ),
            Semantics(
              liveRegion: true,
              child: Column(
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            DebugErrorLogButton(
              error: error,
              stackTrace: stackTrace,
              debugContext: debugContext,
            ),
          ],
        ),
      ),
    );
  }
}
