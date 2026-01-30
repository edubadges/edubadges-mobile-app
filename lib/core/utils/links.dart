import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _createBaseAndLang(String path, WidgetRef ref) {
  String baseUrl = Uri.parse(
    EnvironmentConfig.instance.publicCollectionBaseUrl,
  ).host;
  String lang = ref.read(appLanguageProvider).code;
  return 'https://$baseUrl/$path?lang=$lang';
}

String createBadgeCatalogLink(String entityId, WidgetRef ref) {
  return _createBaseAndLang('public/$entityId', ref);
}

/// ## Badge Instance link
///
/// This is not a general link to the badge, links to a users badge.
String createBadgeInstanceLink(String entityId, WidgetRef ref) {
  return _createBaseAndLang('public/assertions/$entityId', ref);
}
