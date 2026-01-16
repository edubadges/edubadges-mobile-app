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

  @override
  String get newCollection => 'New collection';

  @override
  String get newCollectionDescription =>
      'Create a new collection and share it with acquaintances.';

  @override
  String get collectionName => 'Name';

  @override
  String get collectionNamePlaceholder => 'Name of the collection';

  @override
  String get collectionDescription => 'Description';

  @override
  String get collectionDescriptionPlaceholder =>
      'Description of the collection';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get collectionNameRequired => 'Name is required';

  @override
  String get addEdubadgesToCollection => 'Add edubadges to your collection';

  @override
  String get addEdubadgesToCollectionDescription =>
      'Bundle edubadges in your collection to manage them clearly and share them easily.';

  @override
  String get addEdubadge => 'Add Edubadge';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get deleteCollectionConfirmation =>
      'You are about to delete a collection.';

  @override
  String get delete => 'Delete';
}
