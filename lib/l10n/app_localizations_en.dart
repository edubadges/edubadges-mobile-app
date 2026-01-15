// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Edubadges';

  @override
  String get loginCardButton => 'Go to my edubadges';

  @override
  String get loginCardText =>
      'My Badges is the place to receive and collect edubadges. An eduID is required to create and use \"My Badges.\" Creating an eduID takes less than 30 seconds.';

  @override
  String get loginSubtitle =>
      'Edubadges are digital certificates that demonstrate the knowledge or skills someone has acquired, within or outside formal education.';

  @override
  String get loginTitle => 'Never stop learning';

  @override
  String get tabAccount => 'Account';

  @override
  String get tabBadges => 'Edubadges';

  @override
  String get tabCatalog => 'Catalog';

  @override
  String get tabCollections => 'Collections';
}
