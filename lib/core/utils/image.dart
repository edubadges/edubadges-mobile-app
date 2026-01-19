import 'package:edubadges/core/constants/environment_config.dart';

String? buildImageUrl(String? imagePath) {
  if (imagePath == null) return null;

  final cleanBaseUrl = Uri.parse(EnvironmentConfig.instance.apiUrl).host;
  return 'https://$cleanBaseUrl$imagePath';
}
