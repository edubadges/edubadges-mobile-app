import 'package:edubadges/app/themes.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final class EdubadgesWidgetPreview extends Preview {
  const EdubadgesWidgetPreview({
    super.name,
    super.group,
    super.size,
    super.textScaleFactor,
    super.brightness,
    super.localizations,
    super.wrapper = _defaultWrapper,
  }) : super(theme: EdubadgesWidgetPreview.themeBuilder);

  static Widget _defaultWrapper(Widget child) {
    return _PreviewAppWrapper(child: child);
  }

  static PreviewThemeData themeBuilder() {
    return PreviewThemeData(materialLight: AppThemes.lightTheme);
  }
}

class _PreviewAppWrapper extends StatelessWidget {
  final Widget child;
  const _PreviewAppWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );
  }
}
