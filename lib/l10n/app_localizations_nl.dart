// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'Edubadges';

  @override
  String get loginCardButton => 'Ga naar mijn edubadges';

  @override
  String get loginCardText =>
      'Mijn badges is de plek om edubadges te ontvangen en verzamelen. Een eduID is nodig om \'mijn badges\' aan te maken en te gebruiken. Het maken van een eduID duurt minder dan 30 seconden.';

  @override
  String get loginSubtitle =>
      'Edubadges zijn digitale certificaten die aantonen welke kennis of vaardigheden iemand heeft opgedaan, binnen of buiten het formele onderwijs.';

  @override
  String get loginTitle => 'Never stop learning';

  @override
  String get tabAccount => 'Account';

  @override
  String get tabBadges => 'Edubadges';

  @override
  String get tabCatalog => 'Catalogus';

  @override
  String get tabCollections => 'Collecties';

  @override
  String get newCollection => 'Nieuwe collectie';

  @override
  String get newCollectionDescription =>
      'Maak een nieuwe collectie aan en deel deze met bekenden.';

  @override
  String get collectionName => 'Naam';

  @override
  String get collectionNamePlaceholder => 'Naam van de collectie';

  @override
  String get collectionDescription => 'Omschrijving';

  @override
  String get collectionDescriptionPlaceholder =>
      'Beschrijving van de collectie';

  @override
  String get save => 'Opslaan';

  @override
  String get cancel => 'Annuleer';

  @override
  String get collectionNameRequired => 'Naam is verplicht';

  @override
  String get addEdubadgesToCollection => 'Voeg edubadges toe aan je collectie';

  @override
  String get addEdubadgesToCollectionDescription =>
      'Bundel edubadges in je collectie om ze overzichtelijk te beheren en eenvoudig te delen.';

  @override
  String get addEdubadge => 'Edubadge toevoegen';

  @override
  String get areYouSure => 'Weet je het zeker?';

  @override
  String get deleteCollectionConfirmation =>
      'Je staat op het punt om een collectie te verwijderen.';

  @override
  String get delete => 'Verwijderen';
}
