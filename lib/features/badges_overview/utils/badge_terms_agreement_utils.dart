import 'package:collection/collection.dart';
import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/features/account/data/models/agreement_route_model.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_class_entity.dart';
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

String badgeTermsTypeFromClass(BadgeClassEntity badgeClass) {
  return badgeClass.formal == true ? 'formal_badge' : 'informal_badge';
}

bool isBadgeTermsType(String termsType) {
  return termsType == 'formal_badge' || termsType == 'informal_badge';
}

TermsAgreementEntity? findTermsAgreementForBadgeClass({
  required BadgeClassEntity badgeClass,
  required List<TermsAgreementEntity> agreements,
}) {
  final Set<String> badgeIds = badgeInstitutionIds(
    badgeClass.issuer?.faculty?.institution,
  );
  final String termsType = badgeTermsTypeFromClass(badgeClass);
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
      .where(
        (TermsAgreementEntity agreement) =>
            agreement.terms.termsType == termsType,
      )
      .toList();
  if (typeMatches.length == 1) {
    return typeMatches.first;
  }
  return null;
}

AgreementRouteModel? resolveBadgeTermsAgreement({
  required TermsEntity? requiredTerms,
  required BadgeClassEntity badgeClass,
  required List<TermsAgreementEntity> profileAgreements,
  required String languageCode,
}) {
  if (requiredTerms != null && requiredTerms.termsUrls.isNotEmpty) {
    return AgreementRouteModel.fromTermsEntity(requiredTerms, languageCode);
  }
  final TermsAgreementEntity? matchingAgreement =
      findTermsAgreementForBadgeClass(
        badgeClass: badgeClass,
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

bool shouldPromptForBadgeTerms({
  required BadgeClassEntity badgeClass,
  required List<TermsAgreementEntity> profileAgreements,
  required String languageCode,
}) {
  if (badgeClass.userHasAcceptedTerms) {
    return false;
  }
  return resolveBadgeTermsAgreement(
        requiredTerms: badgeClass.requiredTerms,
        badgeClass: badgeClass,
        profileAgreements: profileAgreements,
        languageCode: languageCode,
      ) !=
      null;
}

String buildBadgeClassTermsDebugContext({
  required String routeBadgeId,
  required BadgeClassEntity badgeClass,
  required TermsEntity? requiredTerms,
  required List<TermsAgreementEntity> profileAgreements,
  String extraLines = '',
}) {
  final badge_institution.InstitutionEntity? institution =
      badgeClass.issuer?.faculty?.institution;
  final Set<String> badgeIds = badgeInstitutionIds(institution);
  final String termsType = badgeTermsTypeFromClass(badgeClass);
  final String agreementSummary = profileAgreements
      .map(
        (TermsAgreementEntity agreement) =>
            '${agreement.terms.termsType}:'
            ' id=${agreement.terms.institution?.identifier},'
            ' alt=${agreement.terms.institution?.alternativeIdentifier}',
      )
      .join('; ');
  final String extras = extraLines.isEmpty ? '' : '$extraLines\n';
  return 'BadgeTerms: no matching terms agreement\n'
      'routeBadgeId=$routeBadgeId\n'
      '$extras'
      'badgeClassEntityId=${badgeClass.entityId}\n'
      'badgeInstitutionIds=$badgeIds\n'
      'badgeTermsType=$termsType\n'
      'badgeFormal=${badgeClass.formal}\n'
      'issuerPresent=${badgeClass.issuer != null}\n'
      'userHasAcceptedTerms=${badgeClass.userHasAcceptedTerms}\n'
      'requiredTermsPresent=${requiredTerms != null}\n'
      'requiredTermsType=${requiredTerms?.termsType}\n'
      'requiredTermsUrlCount=${requiredTerms?.termsUrls.length ?? 0}\n'
      'profileAgreements=[$agreementSummary]';
}
