import 'package:edubadges/features/account/domain/entities/profile_entity.dart';

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

  factory AgreementRouteModel.fromJson(Map<String, dynamic> json) {
    return AgreementRouteModel(
      agreementId: json['agreementId'] as String,
      titleLong: json['titleLong'] as String,
      textUrlLong: json['textUrlLong'] as String,
      titleShort: json['titleShort'] as String?,
      textUrlShort: json['textUrlShort'] as String?,
    );
  }

  factory AgreementRouteModel.create(String institutionName, TermsAgreementEntity agreement, String languageCode) {
    final terms = agreement.terms;
    
    // Find long version (full text, where excerpt is false) matching language code
    final longUrls = terms.termsUrls.where((url) => !url.excerpt).toList();
    final longUrlMatch = longUrls.where((url) => url.language == languageCode).firstOrNull;
    final longUrl = (longUrlMatch ?? longUrls.firstOrNull ?? terms.termsUrls.first).url;
    
    // Find short version (excerpt, where excerpt is true) matching language code
    final shortUrls = terms.termsUrls.where((url) => url.excerpt).toList();
    final String? shortUrl;
    final String? titleShort;
    
    if (shortUrls.isEmpty) {
      // No excerpts available
      shortUrl = null;
      titleShort = null;
    } else {
      final shortUrlMatch = shortUrls.where((url) => url.language == languageCode).firstOrNull;
      shortUrl = (shortUrlMatch ?? shortUrls.first).url;
      titleShort = institutionName;
    }
    
    return AgreementRouteModel(
      agreementId: agreement.entityId,
      titleLong: institutionName,
      textUrlLong: longUrl,
      titleShort: titleShort,
      textUrlShort: shortUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agreementId': agreementId,
      'titleLong': titleLong,
      'textUrlLong': textUrlLong,
      if (titleShort != null) 'titleShort': titleShort,
      if (textUrlShort != null) 'textUrlShort': textUrlShort,
    };
  }
}

