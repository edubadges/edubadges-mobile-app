import 'package:flutter/services.dart';

/// The default test font is a uniform-width placeholder, which measures chips
/// and names very differently from production and hides real wrapping bugs.
Future<void> loadAppFonts() async {
  const Map<String, List<String>> families = <String, List<String>>{
    'Nunito': <String>[
      'assets/fonts/Nunito-Regular.ttf',
      'assets/fonts/Nunito-Bold.ttf',
    ],
    'SourceSans3': <String>[
      'assets/fonts/SourceSans3-Regular.ttf',
      'assets/fonts/SourceSans3-SemiBold.ttf',
    ],
  };
  for (final MapEntry<String, List<String>> family in families.entries) {
    final FontLoader loader = FontLoader(family.key);
    for (final String path in family.value) {
      loader.addFont(rootBundle.load(path));
    }
    await loader.load();
  }
}
