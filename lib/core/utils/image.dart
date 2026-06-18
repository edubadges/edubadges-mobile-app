import 'package:edubadges/core/constants/environment_config.dart';

String? buildImageUrl(String? imagePath) {
  if (imagePath == null) return null;

  // If already a full URL, return as is
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return imagePath;
  }

  // Combine base URL with image path
  final cleanBaseUrl = Uri.parse(EnvironmentConfig.instance.apiUrl).host;
  return 'https://$cleanBaseUrl$imagePath';
}
