import 'package:edubadges/app/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    );
  }

  static SystemUiOverlayStyle get systemUiOverlayStyleLight {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
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
