// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agreement_route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgreementRouteModel _$AgreementRouteModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AgreementRouteModel', json, ($checkedConvert) {
      final val = AgreementRouteModel(
        agreementId: $checkedConvert('agreementId', (v) => v as String),
        titleLong: $checkedConvert('titleLong', (v) => v as String),
        textUrlLong: $checkedConvert('textUrlLong', (v) => v as String),
        titleShort: $checkedConvert('titleShort', (v) => v as String?),
        textUrlShort: $checkedConvert('textUrlShort', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$AgreementRouteModelToJson(
  AgreementRouteModel instance,
) => <String, dynamic>{
  'agreementId': instance.agreementId,
  'titleLong': instance.titleLong,
  'textUrlLong': instance.textUrlLong,
  'titleShort': ?instance.titleShort,
  'textUrlShort': ?instance.textUrlShort,
};
