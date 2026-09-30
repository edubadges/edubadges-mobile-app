import 'package:edubadges/core/storage/storage_providers.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _storageKey = AppLanguageNotifier.storageKey;

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void setDeviceLocales(List<Locale> locales) {
    binding.platformDispatcher.localesTestValue = locales;
    addTearDown(binding.platformDispatcher.clearLocalesTestValue);
  }

  /// A container whose preferences are loaded, as main() does before runApp.
  Future<ProviderContainer> createContainer({
    Map<String, Object> storedValues = const {},
  }) async {
    SharedPreferences.setMockInitialValues(storedValues);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(sharedPreferencesProvider.future);
    return container;
  }

  group('AppLanguage.fromCode', () {
    test('accepts plain codes and locale tags', () {
      expect(AppLanguage.fromCode('nl'), AppLanguage.dutch);
      expect(AppLanguage.fromCode('en'), AppLanguage.english);
      expect(AppLanguage.fromCode('NL'), AppLanguage.dutch);
      expect(AppLanguage.fromCode('nl-BE'), AppLanguage.dutch);
      expect(AppLanguage.fromCode('en_GB'), AppLanguage.english);
    });

    test('returns null for anything unsupported', () {
      expect(AppLanguage.fromCode(null), isNull);
      expect(AppLanguage.fromCode(''), isNull);
      expect(AppLanguage.fromCode('fr'), isNull);
      expect(AppLanguage.fromCode('dutch'), isNull);
    });
  });

  group('appLanguageProvider without a stored choice', () {
    test('uses Dutch on a Dutch device', () async {
      setDeviceLocales(const [Locale('nl', 'NL')]);
      final container = await createContainer();

      expect(container.read(appLanguageProvider), AppLanguage.dutch);
    });

    test('uses English on an English device', () async {
      setDeviceLocales(const [Locale('en', 'US')]);
      final container = await createContainer();

      expect(container.read(appLanguageProvider), AppLanguage.english);
    });

    test('falls back to English on any other device language', () async {
      setDeviceLocales(const [Locale('de', 'DE')]);
      final container = await createContainer();

      expect(container.read(appLanguageProvider), AppLanguage.english);
    });

    test('uses the first supported language the device prefers', () async {
      setDeviceLocales(const [Locale('de'), Locale('nl'), Locale('en')]);
      final container = await createContainer();

      expect(container.read(appLanguageProvider), AppLanguage.dutch);
    });
  });

  group('appLanguageProvider with a stored choice', () {
    test('prefers the stored language over the device language', () async {
      setDeviceLocales(const [Locale('en', 'US')]);
      final container = await createContainer(
        storedValues: {_storageKey: 'nl'},
      );

      expect(container.read(appLanguageProvider), AppLanguage.dutch);
    });

    test('ignores an unsupported stored value', () async {
      setDeviceLocales(const [Locale('nl', 'NL')]);
      final container = await createContainer(
        storedValues: {_storageKey: 'fr'},
      );

      expect(container.read(appLanguageProvider), AppLanguage.dutch);
    });

    test('switches to the stored language once preferences load', () async {
      setDeviceLocales(const [Locale('en', 'US')]);
      SharedPreferences.setMockInitialValues({_storageKey: 'nl'});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final languages = <AppLanguage>[];
      container.listen<AppLanguage>(
        appLanguageProvider,
        (_, language) => languages.add(language),
        fireImmediately: true,
      );

      await container.read(sharedPreferencesProvider.future);
      await Future<void>.delayed(Duration.zero);

      expect(languages, [AppLanguage.english, AppLanguage.dutch]);
    });
  });

  group('AppLanguageNotifier.setLanguage', () {
    test('applies the language and stores it', () async {
      setDeviceLocales(const [Locale('en', 'US')]);
      final container = await createContainer();

      await container
          .read(appLanguageProvider.notifier)
          .setLanguage(AppLanguage.dutch);

      expect(container.read(appLanguageProvider), AppLanguage.dutch);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_storageKey), 'nl');
    });

    test('is restored on the next start', () async {
      setDeviceLocales(const [Locale('nl', 'NL')]);
      final firstRun = await createContainer();
      await firstRun
          .read(appLanguageProvider.notifier)
          .setLanguage(AppLanguage.english);
      final prefs = await SharedPreferences.getInstance();
      final Map<String, Object> stored = {
        for (final key in prefs.getKeys()) key: prefs.get(key)!,
      };
      firstRun.dispose();

      final secondRun = await createContainer(storedValues: stored);

      expect(secondRun.read(appLanguageProvider), AppLanguage.english);
    });
  });
}
