import 'package:edubadges/app/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class AppThemes {
  // Private constructor to prevent instantiation
  AppThemes._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
    );
  }

  static SystemUiOverlayStyle get systemUiOverlayStyle {
    return const SystemUiOverlayStyle(
      statusBarColor: AppColors.surface,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surfaceContainer,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    );
  }

  static SystemUiOverlayStyle get systemUiOverlayStyleLight {
    return const SystemUiOverlayStyle(
      statusBarColor: AppColors.surface,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surfaceContainer,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    );
  }

  /// Light color scheme
  static ColorScheme get _lightColorScheme {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      primaryContainer: AppColors.primaryContainer,
      primaryFixed: AppColors.primaryFixed,
      secondaryContainer: AppColors.secondaryContainer,
      secondaryFixed: AppColors.secondaryFixed,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      tertiaryFixed: AppColors.tertiaryFixed,
      errorContainer: AppColors.errorContainer,
      surfaceDim: AppColors.surfaceDim,
      surfaceBright: AppColors.surfaceBright,
      surfaceContainer: AppColors.surfaceContainer,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.inverseSurface,
      inversePrimary: AppColors.inversePrimary,
      surfaceTint: AppColors.surfaceTint,
    );
  }

  /// Text theme with custom typography
  static TextTheme get _textTheme {
    return const TextTheme(
      // DisplayLarge styles
      displayLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 57,
        height: 64 / 57,
        letterSpacing: -0.25,
        fontWeight: FontWeight.w400,
      ),

      // DisplayMedium styles
      displayMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 45,
        height: 52 / 45,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),

      // DisplaySmall styles
      displaySmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 36,
        height: 44 / 36,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),

      // HeadlineLarge styles
      headlineLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 32,
        height: 40 / 32,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w700,
      ),

      // HeadlineMedium styles
      headlineMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 28,
        height: 36 / 28,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),

      // HeadlineSmall styles
      headlineSmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 24,
        height: 32 / 24,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w700,
      ),

      // TitleLarge styles
      titleLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 20,
        height: 28 / 20,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w700,
      ),

      // TitleMedium styles
      titleMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 17,
        height: 24 / 17,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w700,
      ),

      // TitleSmall styles
      titleSmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w700,
      ),

      // BodyLarge styles
      bodyLarge: TextStyle(
        fontFamily: 'SourceSans3',
        fontSize: 16,
        height: 24 / 16,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),

      // BodyMedium styles
      bodyMedium: TextStyle(
        fontFamily: 'SourceSans3',
        fontSize: 15,
        height: 22 / 15,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),

      // BodySmall styles
      bodySmall: TextStyle(
        fontFamily: 'SourceSans3',
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),

      // LabelLarge styles
      labelLarge: TextStyle(
        fontFamily: 'SourceSans3',
        fontSize: 16,
        height: 20 / 16,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w600,
      ),

      // LabelMedium styles
      labelMedium: TextStyle(
        fontFamily: 'SourceSans3',
        fontSize: 14,
        height: 16 / 14,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),

      // LabelSmall styles
      labelSmall: TextStyle(
        fontFamily: 'SourceSans3',
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  /// App bar theme
  static AppBarTheme get _appBarTheme {
    return const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.onPrimary),
      titleTextStyle: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 20,
        height: 28 / 20,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    );
  }

  static MarkdownStyleSheet markdownStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return MarkdownStyleSheet(
      h1: textTheme.displayLarge?.copyWith(color: colorScheme.onSurface),
      h2: textTheme.displayMedium?.copyWith(color: colorScheme.onSurface),
      h3: textTheme.displaySmall?.copyWith(color: colorScheme.onSurface),
      h4: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
      h5: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
      h6: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
      p: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      code: textTheme.bodyMedium?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: colorScheme.surfaceContainerHighest,
        color: colorScheme.onSurface,
      ),
      codeblockDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      a: textTheme.bodyMedium?.copyWith(
        color: colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
      listBullet: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      blockquote: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      blockquoteDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
            width: 4,
          ),
        ),
      ),
      em: const TextStyle(fontStyle: FontStyle.italic),
      strong: const TextStyle(fontWeight: FontWeight.bold),
      del: TextStyle(
        decoration: TextDecoration.lineThrough,
        color: colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      tableHead: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      tableBody: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      tableBorder: TableBorder.all(color: colorScheme.outlineVariant, width: 1),
    );
  }
}

/// Extension for additional custom text styles not covered by Material 3
extension CustomTextStyles on TextTheme {
  /// Nunito SemiBold - 16/20 . 0.0
  TextStyle get m3LabelLargeProminent => const TextStyle(
    fontFamily: 'SourceSans3',
    fontSize: 16,
    height: 20 / 16,
    letterSpacing: 0.0,
    fontWeight: FontWeight.w600,
  );

  /// Nunito SemiBold - 14/16 . 0.0
  TextStyle get m3LabelMediumProminent => const TextStyle(
    fontFamily: 'SourceSans3',
    fontSize: 14,
    height: 16 / 14,
    letterSpacing: 0.0,
    fontWeight: FontWeight.w600,
  );
}
