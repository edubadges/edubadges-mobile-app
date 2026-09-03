import 'package:edubadges/app/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class AppThemes {
  // Private constructor to prevent instantiation
  AppThemes._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      switchTheme: _switchTheme,
      tabBarTheme: _tabBarTheme,
      // High-contrast focus indicator for keyboard/screen reader (EU accessibility)
      focusColor: AppColors.primary,
    );
  }

  /// High-contrast theme for accessibility (e.g. OS "increase contrast")
  static ThemeData get highContrastTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      switchTheme: _switchTheme,
      tabBarTheme: _tabBarTheme,
      focusColor: AppColors.onSurface,
    );
  }

  static ThemeData themeForPlatform(ThemeData theme) {
    if (!kIsWeb) {
      return theme;
    }
    return theme.copyWith(pageTransitionsTheme: _webPageTransitionsTheme);
  }

  static const PageTransitionsTheme _webPageTransitionsTheme =
      PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _InstantPageTransitionsBuilder(),
          TargetPlatform.iOS: _InstantPageTransitionsBuilder(),
          TargetPlatform.macOS: _InstantPageTransitionsBuilder(),
          TargetPlatform.linux: _InstantPageTransitionsBuilder(),
          TargetPlatform.windows: _InstantPageTransitionsBuilder(),
          TargetPlatform.fuchsia: _InstantPageTransitionsBuilder(),
        },
      );

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
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
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
      displayLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 57,
        height: 64 / 57,
        letterSpacing: -0.25,
        fontWeight: FontWeight.w400,
      ),

      displayMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 45,
        height: 52 / 45,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),

      displaySmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 36,
        height: 44 / 36,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),

      headlineLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 32,
        height: 40 / 32,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w700,
      ),

      headlineMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 28,
        height: 36 / 28,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),

      headlineSmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 24,
        height: 32 / 24,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w700,
      ),

      titleLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 20,
        height: 28 / 20,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w700,
      ),

      titleMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 17,
        height: 24 / 17,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w700,
      ),

      titleSmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w700,
      ),

      bodyLarge: TextStyle(
        fontFamily: 'SourceSans3',
        fontSize: 16,
        height: 24 / 16,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),

      bodyMedium: TextStyle(
        fontFamily: 'SourceSans3',
        fontSize: 15,
        height: 22 / 15,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),

      bodySmall: TextStyle(
        fontFamily: 'SourceSans3',
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),

      labelLarge: TextStyle(
        fontFamily: 'SourceSans3',
        fontSize: 16,
        height: 20 / 16,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w600,
      ),

      labelMedium: TextStyle(
        fontFamily: 'SourceSans3',
        fontSize: 14,
        height: 16 / 14,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),

      labelSmall: TextStyle(
        fontFamily: 'SourceSans3',
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }

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
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
    );
  }

  /// Labels inherit [TextTheme.titleSmall] (Nunito Bold 14/20) from Material 3.
  static TabBarThemeData get _tabBarTheme {
    return const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.onSurfaceVariant,
      // Pill-shaped indicator hugging the label, inset 2px on either side.
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 3, color: AppColors.primary),
        borderRadius: BorderRadius.vertical(top: Radius.circular(100)),
        insets: EdgeInsets.symmetric(horizontal: 2),
      ),
      dividerColor: AppColors.outlineVariant,
    );
  }

  static SwitchThemeData get _switchTheme {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.surfaceContainer;
        }
        return AppColors.tertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return AppColors.tertiary;
      }),
      trackOutlineWidth: const WidgetStatePropertyAll(2),
      thumbIcon: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Icon(Icons.check, size: 16, color: AppColors.primary);
        }
        return const Icon(Icons.close, size: 16, color: AppColors.onTertiary);
      }),
    );
  }

  static MarkdownStyleSheet markdownStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return MarkdownStyleSheet(
      h1: textTheme.headlineLarge?.copyWith(
        color: colorScheme.onSurface,
        fontSize: 24,
      ),
      h2: textTheme.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontSize: 21,
      ),
      h3: textTheme.headlineSmall?.copyWith(
        color: colorScheme.onSurface,
        fontSize: 18,
      ),
      h4: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontSize: 15,
      ),
      h5: textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontSize: 12.75,
      ),
      h6: textTheme.titleSmall?.copyWith(
        color: colorScheme.onSurface,
        fontSize: 10.5,
      ),
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

class _InstantPageTransitionsBuilder extends PageTransitionsBuilder {
  const _InstantPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
