import 'package:aroma_networking/aroma_networking.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/utils/logger.dart';

final networkConfigProvider = Provider<AromaNetworkConfig>((ref) {
  return AromaNetworkConfig(
    baseUrl: EnvironmentConfig.instance.apiUrl,
    getAccessToken: () async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    },
    onUnauthorized: () async {
      await FirebaseAuth.instance.signOut();
    },
    logger: logger,
    // TODO: Add aromaErrorController if using aroma_error package
    // aromaErrorController: ref.watch(aromaErrorControllerProvider),
  );
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(networkConfigProvider);
  return config.createDio();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(networkConfigProvider);
  final dio = ref.watch(dioProvider);
  return ApiClient(baseUrl: config.baseUrl, dio: dio);
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});
