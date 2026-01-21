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

  @override
  String get accountData => 'Gegevens';

  @override
  String get confirmedName => 'Bevestigde naam';

  @override
  String get providedByInstitution => 'Geleverd door je instelling';

  @override
  String get emailAddress => 'E-mailadres';

  @override
  String get institution => 'Instelling';

  @override
  String get eduid => '#eduid';

  @override
  String get memberSince => 'Lid sinds';

  @override
  String get notificationSettings => 'Notificatieinstellingen';

  @override
  String get generalNotifications => 'Algemene meldingen';

  @override
  String get givenAgreements => 'Gegeven akkoordverklaring(en)';

  @override
  String get agreementsDescription =>
      'Je kan je gegeven akkoordverklaring(en) intrekken.';

  @override
  String get deleteAccount => 'Je edubadges account verwijderen';

  @override
  String get deleteAccountDescription =>
      'Je kunt je edubadges account verwijderen als je dat wilt.\n\nWees je dan wel bewust dat hierna al je edubadges niet meer gevalideerd kunnen worden. Het verwijderen van je edubadges account betekent overigens niet dat je eduID ook verwijderd wordt.\n\nOm het proces van het verwijderen van je edubadges account te voltooien, moet je je browser sluiten nadat je account is verwijderd.';

  @override
  String get deleteMyAccount => 'Verwijder mijn account';

  @override
  String get somethingWentWrong => 'Er is iets misgegaan';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get noProfileData => 'Geen profielgegevens';

  @override
  String get logoutConfirmationTitle => 'Weet je het zeker?';

  @override
  String get logoutConfirmationMessage =>
      'Je staat op het punt om uit te loggen.';

  @override
  String get logout => 'Uitloggen';

  @override
  String get deleteAccountConfirmationTitle => 'Verwijder mijn account';

  @override
  String get deleteAccountConfirmationMessage =>
      'Wees je dan wel bewust dat hierna al je edubadges niet meer gevalideerd kunnen worden. Het verwijderen van je edubadges account betekent overigens niet dat je eduID ook verwijderd wordt.';

  @override
  String get deleteAccountConfirmationPrompt =>
      'Typ het woord \'verwijderen\' om mijn badges definitief te verwijderen';

  @override
  String get deleteAccountInputPlaceholder => 'Typ \'verwijderen\'';

  @override
  String get deleteAccountRequiredText => 'verwijderen';

  @override
  String get privacyConditions => 'Privacy voorwaarden';

  @override
  String get withdraw => 'Intrekken';

  @override
  String get viewFullText => 'Bekijk volledige tekst';

  @override
  String get viewShortText => 'Bekijk korte tekst';

  @override
  String get withdrawAgreementTitle => 'Mijn akkoordverklaring intrekken';

  @override
  String withdrawAgreementMessage(String institution) {
    return 'Weet je zeker dat je je akkoordverklaring wil intrekken voor $institution?';
  }

  @override
  String get confirm => 'Bevestig';
  String countHours(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString uur',
      one: '1 uur',
    );
    return '$_temp0';
  }

  @override
  String get noCollectionsYet => 'Nog geen collecties';

  @override
  String countEdubadges(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString edubadges',
      one: '1 edubadge',
    );
    return '$_temp0';
  }

  @override
  String get errorLoadingCollections => 'Fout bij het laden van collecties';

  @override
  String get collectionVisibleAndShareable => 'Collectie zichtbaar en deelbaar';

  @override
  String get publicCollectionRequires =>
      'Een openbare collectie vereist op zijn minst 1 openbare edubadge';

  @override
  String get privateBadgesError =>
      'Er staan één of meerdere badges op privé, maak deze openbaar om deze collectie openbaar te kunnen maken.';

  @override
  String get linkCopied => 'Link gekopieerd';

  @override
  String get copyLink => 'Kopieer link';

  @override
  String get errorLoadingCollection => 'Fout bij het laden van collectie';

  @override
  String get goBack => 'Ga terug';
}
