import 'package:edubadges/core/utils/string.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'agreement_route_model.g.dart';

@JsonSerializable()
class AgreementRouteModel {
  final String agreementId;
  final String titleLong;
  final String textUrlLong;
  final String? titleShort;
  final String? textUrlShort;

  const AgreementRouteModel({
    required this.agreementId,
    required this.titleLong,
    required this.textUrlLong,
    this.titleShort,
    this.textUrlShort,
  });

  factory AgreementRouteModel.fromJson(Map<String, dynamic> json) =>
      _$AgreementRouteModelFromJson(json);

  factory AgreementRouteModel.create(
    String institutionName,
    TermsAgreementEntity agreement,
    String languageCode,
  ) {
    return _fromTerms(
      terms: agreement.terms,
      institutionName: institutionName,
      languageCode: languageCode,
      agreementId: agreement.entityId,
    );
  }

  factory AgreementRouteModel.fromTermsEntity(
    TermsEntity terms,
    String languageCode,
  ) {
    final String institutionName = getLocalizedString(
      terms.institution?.nameDutch,
      terms.institution?.nameEnglish,
      languageCode,
    );
    return _fromTerms(
      terms: terms,
      institutionName: institutionName,
      languageCode: languageCode,
      agreementId: terms.entityId,
    );
  }

  static AgreementRouteModel _fromTerms({
    required TermsEntity terms,
    required String institutionName,
    required String languageCode,
    required String agreementId,
  }) {
    final longUrls = terms.termsUrls.where((url) => !url.excerpt).toList();
    final longUrlMatch = longUrls
        .where((url) => url.language == languageCode)
        .firstOrNull;
    final longUrl =
        (longUrlMatch ?? longUrls.firstOrNull ?? terms.termsUrls.first).url;
    final shortUrls = terms.termsUrls.where((url) => url.excerpt).toList();
    final String? shortUrl;
    final String? titleShort;
    if (shortUrls.isEmpty) {
      shortUrl = null;
      titleShort = null;
    } else {
      final shortUrlMatch = shortUrls
          .where((url) => url.language == languageCode)
          .firstOrNull;
      shortUrl = (shortUrlMatch ?? shortUrls.first).url;
      titleShort = institutionName;
    }
    return AgreementRouteModel(
      agreementId: agreementId,
      titleLong: institutionName,
      textUrlLong: longUrl,
      titleShort: titleShort,
      textUrlShort: shortUrl,
    );
  }

  Map<String, dynamic> toJson() => _$AgreementRouteModelToJson(this);
}
