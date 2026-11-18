import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:edubadges/features/account/data/models/profile_model.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/general_terms/domain/general_terms_constants.dart';
import 'package:edubadges/features/general_terms/domain/general_terms_url_resolver.dart';

/// Extracts the localized markdown URL for general terms from a profile response.
String generalTermsUrlFromProfile(ProfileModel profile, String languageCode) {
  final agreement = profile.termsagreementSet.firstWhereOrNull(
    (a) => a.terms.termsType == GeneralTermsConstants.termsOfServiceType,
  );
  // A new account has no agreements until it accepts the terms.
  final urls = agreement?.terms.termsUrls ?? const <TermsUrlEntity>[];
  return (urls.isEmpty ? defaultTermsOfServiceUrls : urls).urlForLanguage(
    languageCode,
  );
}

/// Fetches the terms markdown URL from `/profile` without using Riverpod providers.
///
/// Sets [GeneralTermsConstants.skipRedirectExtraKey] so this request does not
/// re-trigger the general-terms redirect interceptor.
Future<String> fetchGeneralTermsMarkdownUrlFromProfile(
  Dio dio,
  String languageCode,
) async {
  final response = await dio.get<Map<String, dynamic>>(
    '/profile',
    queryParameters: const {'format': 'json'},
    options: Options(
      extra: const {
        GeneralTermsConstants.skipRedirectExtraKey: true,
      },
    ),
  );
  if (response.statusCode == 200 && response.data != null) {
    final profile = ProfileModel.fromJson(response.data!);
    return generalTermsUrlFromProfile(profile, languageCode);
  }
  throw Exception('Failed to load profile for terms URL');
}
