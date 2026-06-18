import 'package:edubadges/l10n/app_localizations.dart';

enum BadgeClassType {
  microCredential('micro_credential'),
  regular('regular'),
  extraCurricular('extra_curricular');

  final String value;

  const BadgeClassType(this.value);

  static BadgeClassType? fromString(String? value) {
    if (value == null) return null;
    
    try {
      return BadgeClassType.values.firstWhere(
        (type) => type.value == value,
      );
    } catch (_) {
      return null;
    }
  }
}

extension BadgeClassTypeLocalization on BadgeClassType {
  String getLocalizedName(AppLocalizations l10n) {
    return switch (this) {
      BadgeClassType.microCredential => l10n.microCredential,
      BadgeClassType.regular => l10n.regular,
      BadgeClassType.extraCurricular => l10n.extraCurricular,
    };
  }
}
