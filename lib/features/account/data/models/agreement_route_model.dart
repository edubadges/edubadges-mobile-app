import 'package:edubadges/core/constants/route_path.dart';

class AgreementRouteModel {
  final String agreementId;
  final String titleLong;
  final String textLong;
  final String titleShort;
  final String textShort;

  const AgreementRouteModel({
    required this.agreementId,
    required this.titleLong,
    required this.textLong,
    required this.titleShort,
    required this.textShort,
  });

  factory AgreementRouteModel.fromJson(Map<String, dynamic> json) {
    return AgreementRouteModel(
      agreementId: json['agreementId'] as String,
      titleLong: json['titleLong'] as String,
      textLong: json['textLong'] as String,
      titleShort: json['titleShort'] as String,
      textShort: json['textShort'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agreementId': agreementId,
      'titleLong': titleLong,
      'textLong': textLong,
      'titleShort': titleShort,
      'textShort': textShort,
    };
  }

  String buildRouteUrl() {
    final basePath = RoutePath.agreementDetails.replaceAll(
      ':id',
      Uri.encodeComponent(agreementId),
    );
    final uri = Uri.parse(basePath).replace(
      queryParameters: {
        'titleLong': titleLong,
        'textLong': textLong,
        'titleShort': titleShort,
        'textShort': textShort,
      },
    );
    return uri.toString();
  }
}

