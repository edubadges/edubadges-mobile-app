import 'package:edubadges/features/account/data/models/profile_model.dart';
import 'package:edubadges/features/general_terms/domain/general_terms_url_resolver.dart';
import 'package:edubadges/features/general_terms/utils/general_terms_profile_utils.dart';
import 'package:edubadges/features/login/data/models/login_user_status.dart';
import 'package:flutter_test/flutter_test.dart';

const String _surfTermsEn =
    'https://raw.githubusercontent.com/edubadges/privacy/master/surf/account-terms-en.md';
const String _surfTermsNl =
    'https://raw.githubusercontent.com/edubadges/privacy/master/surf/account-terms-nl.md';

/// `/login` for a user who has to accept terms, in the API's own spelling.
Map<String, dynamic> _loginJson(List<Object> agreements) => {
  'email': 'user@example.com',
  'first_name': 'Some',
  'last_name': 'User',
  'terms_agreed': false,
  'termsagreement_set': agreements,
};

final Map<String, dynamic> _termsOfService = {
  'agreed': false,
  'agreed_version': 1,
  'terms': {
    'terms_type': 'terms_of_service',
    'institution': null,
    'terms_urls': [
      {'url': 'https://example.com/tos-en.md', 'language': 'en'},
      {'url': 'https://example.com/tos-nl.md', 'language': 'nl'},
    ],
  },
};

LoginTermsAgreementRequired _status(List<Object> agreements) =>
    parseUserAuthStatus(_loginJson(agreements)) as LoginTermsAgreementRequired;

void main() {
  group('login status', () {
    test('reads the terms agreements the API sends', () {
      final status = _status([_termsOfService]);

      expect(status.termsAgreementSet, hasLength(1));
      expect(
        resolveGeneralTermsUrlFromLoginStatus(status, 'nl'),
        'https://example.com/tos-nl.md',
      );
    });

    // SURF-687: a brand-new account has no agreements yet.
    test('falls back to the SURF account terms without agreements', () {
      final status = _status(const []);

      expect(resolveGeneralTermsUrlFromLoginStatus(status, 'en'), _surfTermsEn);
      expect(resolveGeneralTermsUrlFromLoginStatus(status, 'nl'), _surfTermsNl);
      expect(resolveGeneralTermsUrlFromLoginStatus(status, 'de'), _surfTermsEn);
    });
  });

  group('profile', () {
    test('falls back to the SURF account terms without agreements', () {
      final profile = ProfileModel.fromJson(const {
        'entity_id': 'abc',
        'first_name': 'New',
        'last_name': 'User',
        'email': 'new@example.com',
        'date_joined': '2026-11-18T11:30:00+01:00',
        'terms_agreed': false,
        'termsagreement_set': <Object>[],
      });

      expect(generalTermsUrlFromProfile(profile, 'nl'), _surfTermsNl);
    });
  });
}
