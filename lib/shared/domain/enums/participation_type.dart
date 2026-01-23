import 'package:edubadges/l10n/app_localizations.dart';

enum ParticipationType {
  online('online'),
  onsite('onsite'),
  blended('blended'),
  workExperience('work_experience');

  final String value;

  const ParticipationType(this.value);

  static ParticipationType? fromString(String? value) {
    if (value == null) return null;
    
    try {
      return ParticipationType.values.firstWhere(
        (type) => type.value == value,
      );
    } catch (_) {
      return null;
    }
  }
}

extension ParticipationTypeLocalization on ParticipationType {
  String getLocalizedName(AppLocalizations l10n) {
    return switch (this) {
      ParticipationType.online => l10n.online,
      ParticipationType.onsite => l10n.onsite,
      ParticipationType.blended => l10n.blended,
      ParticipationType.workExperience => l10n.workExperience,
    };
  }
}
