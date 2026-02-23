import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/widgets/app_snackbar.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

String errorMessageFromContext(BuildContext context, dynamic code) {
  return errorMessage(AppLocalizations.of(context), code);
}

String errorMessage(AppLocalizations l10n, dynamic code) {
  if (code == 'unexpected') return l10n.errorUnexpected;
  if (code == 'description') return l10n.errorDescription;
  if (code is! int) return l10n.errorUnexpected;

  switch (code) {
    case 100:
      return l10n.error100;
    case 101:
      return l10n.error101;
    case 102:
      return l10n.error102;
    case 103:
      return l10n.error103;
    case 104:
      return l10n.error104;
    case 105:
      return l10n.error105;
    case 201:
      return l10n.error201;
    case 202:
      return l10n.error202;
    case 203:
      return l10n.error203;
    case 204:
      return l10n.error204;
    case 205:
      return l10n.error205;
    case 206:
      return l10n.error206;
    case 207:
      return l10n.error207;
    case 208:
      return l10n.error208;
    case 209:
      return l10n.error209;
    case 210:
      return l10n.error210;
    case 211:
      return l10n.error211;
    case 212:
      return l10n.error212;
    case 213:
      return l10n.error213;
    case 214:
      return l10n.error214;
    case 215:
      return l10n.error215;
    case 216:
      return l10n.error216;
    case 500:
      return l10n.error500;
    case 501:
      return l10n.error501;
    case 502:
      return l10n.error502;
    case 503:
      return l10n.error503;
    case 504:
      return l10n.error504;
    case 505:
      return l10n.error505;
    case 506:
      return l10n.error506;
    case 507:
      return l10n.error507;
    case 508:
      return l10n.error508;
    case 509:
      return l10n.error509;
    case 510:
      return l10n.error510;
    case 601:
      return l10n.error601;
    case 701:
      return l10n.error701;
    case 702:
      return l10n.error702;
    case 801:
      return l10n.error801;
    case 802:
      return l10n.error802;
    case 902:
      return l10n.error902;
    case 903:
      return l10n.error903;
    case 904:
      return l10n.error904;
    case 905:
      return l10n.error905;
    case 906:
      return l10n.error906;
    case 907:
      return l10n.error907;
    case 908:
      return l10n.error908;
    case 909:
      return l10n.error909;
    case 910:
      return l10n.error910;
    case 911:
      return l10n.error911;
    case 912:
      return l10n.error912;
    case 913:
      return l10n.error913;
    case 914:
      return l10n.error914;
    case 915:
      return l10n.error915;
    case 916:
      return l10n.error916;
    case 917:
      return l10n.error917;
    case 918:
      return l10n.error918;
    case 919:
      return l10n.error919;
    case 920:
      return l10n.error920;
    case 921:
      return l10n.error921;
    case 922:
      return l10n.error922;
    case 923:
      return l10n.error923;
    case 924:
      return l10n.error924;
    case 925:
      return l10n.error925;
    case 926:
      return l10n.error926;
    case 927:
      return l10n.error927;
    case 928:
      return l10n.error928;
    case 929:
      return l10n.error929;
    case 930:
      return l10n.error930;
    case 931:
      return l10n.error931;
    case 932:
      return l10n.error932;
    case 933:
      return l10n.error933;
    case 934:
      return l10n.error934;
    case 935:
      return l10n.error935;
    case 936:
      return l10n.error936;
    case 937:
      return l10n.error937;
    case 938:
      return l10n.error938;
    case 939:
      return l10n.error939;
    case 940:
      return l10n.error940;
    case 941:
      return l10n.error941;
    case 942:
      return l10n.error942;
    case 943:
      return l10n.error943;
    case 944:
      return l10n.error944;
    case 945:
      return l10n.error945;
    case 946:
      return l10n.error946;
    case 947:
      return l10n.error947;
    case 948:
      return l10n.error948;
    case 949:
      return l10n.error949;
    default:
      return l10n.errorUnexpected;
  }
}

String messageFromFailure(BuildContext context, Failure failure) {
  return messageFromFailureWith(AppLocalizations.of(context), failure);
}

String messageFromFailureWith(AppLocalizations l10n, Failure failure) {
  final int? codeNum = failure.apiErrorCode ??
      (failure.code != null ? int.tryParse(failure.code!) : null);
  return codeNum != null ? errorMessage(l10n, codeNum) : l10n.somethingWentWrong;
}

void handleFailureResult<T>(
  BuildContext context,
  Either<Failure, T> result, {
  required void Function(T value) onSuccess,
  Duration? snackBarDuration,
}) {
  result.fold(
    (failure) {
      final message = messageFromFailure(context, failure);
      showAppSnackBar(
        context,
        message,
        duration: snackBarDuration ?? const Duration(seconds: 5),
      );
    },
    onSuccess,
  );
}
