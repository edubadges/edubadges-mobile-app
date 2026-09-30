import 'package:dio/dio.dart';
import 'package:edubadges/core/network/network_config.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/core/storage/storage_providers.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'a language switch changes the request headers, not the Dio instance',
    () async {
      binding.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
      addTearDown(binding.platformDispatcher.clearLocalesTestValue);
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer(
        overrides: [
          networkConfigProvider.overrideWithValue(
            NetworkConfig(baseUrl: 'https://api.example.test'),
          ),
          packageInfoProvider.overrideWith(
            (ref) => PackageInfo(
              appName: 'Edubadges',
              packageName: 'nl.edubadges',
              version: '1.0.0',
              buildNumber: '1',
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sharedPreferencesProvider.future);

      final Dio dio = container.read(dioProvider);
      final apiClient = container.read(apiClientProvider);
      final requests = <RequestOptions>[];
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            handler.resolve(Response<dynamic>(requestOptions: options));
          },
        ),
      );

      await dio.get<dynamic>('/badges');
      expect(requests.last.headers['Accept-Language'], 'en');
      expect(requests.last.headers['x-language'], 'en');

      await container
          .read(appLanguageProvider.notifier)
          .setLanguage(AppLanguage.dutch);
      await dio.get<dynamic>('/badges');

      expect(requests.last.headers['Accept-Language'], 'nl');
      expect(requests.last.headers['x-language'], 'nl');
      // Rebuilding Dio would swap out the token handling and rebuild every
      // provider on top of the API client, auth included.
      expect(container.read(dioProvider), same(dio));
      expect(container.read(apiClientProvider), same(apiClient));
    },
  );
}
