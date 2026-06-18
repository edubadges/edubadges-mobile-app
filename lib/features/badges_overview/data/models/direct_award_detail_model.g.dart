// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_award_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectAwardDetailModel _$DirectAwardDetailModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'DirectAwardDetailModel',
  json,
  ($checkedConvert) {
    final val = DirectAwardDetailModel(
      id: $checkedConvert('id', (v) => (v as num).toInt()),
      userHasAcceptedTerms: $checkedConvert(
        'user_has_accepted_terms',
        (v) => v as bool? ?? false,
      ),
      requiredTerms: $checkedConvert(
        'required_terms',
        (v) => DirectAwardDetailModel._requiredTermsFromJson(v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'userHasAcceptedTerms': 'user_has_accepted_terms',
    'requiredTerms': 'required_terms',
  },
);

Map<String, dynamic> _$DirectAwardDetailModelToJson(
  DirectAwardDetailModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_has_accepted_terms': instance.userHasAcceptedTerms,
  'required_terms': ?DirectAwardDetailModel._requiredTermsToJson(
    instance.requiredTerms,
  ),
};
