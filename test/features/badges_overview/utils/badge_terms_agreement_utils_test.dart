import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/badges_overview/utils/badge_terms_agreement_utils.dart';
import 'package:edubadges/shared/domain/entities/badge_class_entity.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:flutter_test/flutter_test.dart';

BadgeClassEntity _badgeClass({
  bool userHasAcceptedTerms = false,
  TermsEntity? requiredTerms,
}) {
  return BadgeClassEntity(
    id: 1,
    name: 'Test badge',
    entityId: 'badge-1',
    badgeClassType: BadgeClassType.regular,
    image: 'https://example.com/badge.png',
    userHasAcceptedTerms: userHasAcceptedTerms,
    requiredTerms: requiredTerms,
  );
}

TermsEntity _terms() {
  return const TermsEntity(
    entityId: 'terms-1',
    termsType: 'formal_badge',
    termsUrls: [
      TermsUrlEntity(
        url: 'https://example.com/terms.md',
        language: 'en',
        excerpt: false,
      ),
    ],
  );
}

void main() {
  group('shouldPromptForBadgeTerms', () {
    test('is false when the user already accepted terms', () {
      expect(
        shouldPromptForBadgeTerms(
          badgeClass: _badgeClass(
            userHasAcceptedTerms: true,
            requiredTerms: _terms(),
          ),
          profileAgreements: const [],
          languageCode: 'en',
        ),
        isFalse,
      );
    });

    test('is true when required terms are present and not accepted', () {
      expect(
        shouldPromptForBadgeTerms(
          badgeClass: _badgeClass(requiredTerms: _terms()),
          profileAgreements: const [],
          languageCode: 'en',
        ),
        isTrue,
      );
    });

    test('is false when no required terms or profile agreements exist', () {
      expect(
        shouldPromptForBadgeTerms(
          badgeClass: _badgeClass(),
          profileAgreements: const [],
          languageCode: 'en',
        ),
        isFalse,
      );
    });
  });
}
