import 'package:collection/collection.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/features/account/data/models/agreement_route_model.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:edubadges/shared/domain/entities/institution_entity.dart'
    as badge_institution;

Set<String> badgeInstitutionIds(
  badge_institution.InstitutionEntity? institution,
) {
  if (institution == null) {
    return {};
  }
  return {
    institution.identifier,
    institution.alternativeIdentifier,
  }.whereType<String>().where((String id) => id.isNotEmpty).toSet();
}

bool institutionsMatch(
  InstitutionEntity? agreementInstitution,
  Set<String> badgeIds,
) {
  if (agreementInstitution == null || badgeIds.isEmpty) {
    return false;
  }
  final Set<String> agreementIds = {
    agreementInstitution.identifier,
    agreementInstitution.alternativeIdentifier,
  }.where((String id) => id.isNotEmpty).toSet();
  return agreementIds.any(badgeIds.contains);
}

String badgeTermsType(BadgeInstanceEntity badge) {
  return badge.badgeclass.formal == true ? 'formal_badge' : 'informal_badge';
}

bool isBadgeTermsType(String termsType) {
  return termsType == 'formal_badge' || termsType == 'informal_badge';
}

TermsAgreementEntity? findTermsAgreementForBadge({
  required BadgeInstanceEntity badge,
  required List<TermsAgreementEntity> agreements,
}) {
  final Set<String> badgeIds = badgeInstitutionIds(
    badge.badgeclass.issuer?.faculty?.institution,
  );
  final String termsType = badgeTermsType(badge);
  if (badgeIds.isNotEmpty) {
    final TermsAgreementEntity? typedMatch = agreements.firstWhereOrNull(
      (TermsAgreementEntity agreement) =>
          agreement.terms.termsType == termsType &&
          institutionsMatch(agreement.terms.institution, badgeIds),
    );
    if (typedMatch != null) {
      return typedMatch;
    }
    final TermsAgreementEntity? institutionMatch = agreements.firstWhereOrNull(
      (TermsAgreementEntity agreement) =>
          isBadgeTermsType(agreement.terms.termsType) &&
          institutionsMatch(agreement.terms.institution, badgeIds),
    );
    if (institutionMatch != null) {
      return institutionMatch;
    }
  }
  final List<TermsAgreementEntity> typeMatches = agreements
      .where((TermsAgreementEntity agreement) =>
          agreement.terms.termsType == termsType)
      .toList();
  if (typeMatches.length == 1) {
    return typeMatches.first;
  }
  return null;
}

AgreementRouteModel? resolveBadgePrivacyAgreement({
  required TermsEntity? requiredTerms,
  required BadgeInstanceEntity badge,
  required List<TermsAgreementEntity> profileAgreements,
  required String languageCode,
}) {
  if (requiredTerms != null && requiredTerms.termsUrls.isNotEmpty) {
    return AgreementRouteModel.fromTermsEntity(requiredTerms, languageCode);
  }
  final TermsAgreementEntity? matchingAgreement = findTermsAgreementForBadge(
    badge: badge,
    agreements: profileAgreements,
  );
  if (matchingAgreement == null) {
    return null;
  }
  final String institutionName = getLocalizedString(
    matchingAgreement.terms.institution?.nameDutch,
    matchingAgreement.terms.institution?.nameEnglish,
    languageCode,
  );
  return AgreementRouteModel.create(
    institutionName,
    matchingAgreement,
    languageCode,
  );
}

String buildTermsAgreementDebugContext({
  required String routeBadgeId,
  required BadgeInstanceEntity badge,
  required List<TermsAgreementEntity> agreements,
}) {
  final badge_institution.InstitutionEntity? institution =
      badge.badgeclass.issuer?.faculty?.institution;
  final Set<String> badgeIds = badgeInstitutionIds(institution);
  final String termsType = badgeTermsType(badge);
  final String agreementSummary = agreements
      .map(
        (TermsAgreementEntity agreement) =>
            '${agreement.terms.termsType}:'
            ' id=${agreement.terms.institution?.identifier},'
            ' alt=${agreement.terms.institution?.alternativeIdentifier}',
      )
      .join('; ');
  return 'BadgePrivacy: no matching terms agreement\n'
      'routeBadgeId=$routeBadgeId\n'
      'matchedBadgeId=${badge.id}\n'
      'matchedBadgeEntityId=${badge.entityId}\n'
      'badgeInstitutionIds=$badgeIds\n'
      'badgeTermsType=$termsType\n'
      'badgeFormal=${badge.badgeclass.formal}\n'
      'issuerPresent=${badge.badgeclass.issuer != null}\n'
      'profileAgreements=[$agreementSummary]';
}

String buildDirectAwardTermsDebugContext({
  required String routeBadgeId,
  required BadgeInstanceEntity badge,
  required TermsEntity? requiredTerms,
  required List<TermsAgreementEntity> profileAgreements,
}) {
  final String baseContext = buildTermsAgreementDebugContext(
    routeBadgeId: routeBadgeId,
    badge: badge,
    agreements: profileAgreements,
  );
  return '$baseContext\n'
      'requiredTermsPresent=${requiredTerms != null}\n'
      'requiredTermsType=${requiredTerms?.termsType}\n'
      'requiredTermsUrlCount=${requiredTerms?.termsUrls.length ?? 0}';
}
