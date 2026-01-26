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
  String get generalAgreementTitle => 'Privacy voorwaarden';

  @override
  String get generalAgreementButtonReadMore => 'Lees meer';

  @override
  String get generalAgreementButtonRead => 'Gelezen';

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
  String get cancel => 'Annuleren';

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
  String get notificationPermissionsTitle => 'Blijf op de hoogte';

  @override
  String get notificationPermissionsSubtitle =>
      'Edubadge kan je een melding sturen wanneer er iets voor je klaarstaat, zoals een nieuwe badge of een belangrijke update.';

  @override
  String get notificationPermissionsLabel =>
      'Je kunt dit later altijd aanpassen in de instellingen.';

  @override
  String get notificationPermissionsButtonAllow => 'Notificaties toestaan';

  @override
  String get notificationPermissionsButtonDeny => 'Niet nu';

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

  @override
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
  String get noCollectionsYet => 'Je hebt nog geen collecties';

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

  @override
  String get editCollection => 'Bewerk collectie';

  @override
  String get editCollectionDescription =>
      'Werk de details van je collectie bij';

  @override
  String get continueText => 'Doorgaan';

  @override
  String get addEdubadges => 'Edubadges toevoegen';

  @override
  String get selectAtLeastOneBadge => 'Selecteer minimaal één badge';

  @override
  String get noBadgesAvailable => 'Geen badges beschikbaar';

  @override
  String get add => 'Toevoegen';

  @override
  String newBadgeReady(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Er staan $countString nieuwe edubadges klaar',
      one: 'Er staat 1 nieuwe edubadge klaar',
    );
    return '$_temp0';
  }

  @override
  String get requestedBadges => 'Aangevraagde edubadges';

  @override
  String get noEdubadgesYet => 'Je hebt nog geen edubadges';

  @override
  String get giveFeedback => 'Feedback geven';

  @override
  String get giveFeedbackDescription =>
      'We horen graag wat je van de app vindt. Laat hieronder je feedback achter.';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackPlaceholder => 'Typ hier je feedback...';

  @override
  String get feedbackRequired => 'Feedback is verplicht';

  @override
  String get aboutThisEdubadge => 'Over deze Edubadge';

  @override
  String get theEdubadge => 'De Edubadge';

  @override
  String get expiresOn => 'Verloopt op';

  @override
  String get type => 'Type';

  @override
  String get badgeTheProgram => 'Het programma';

  @override
  String get badgeTheAssessment => 'De beoordeling';

  @override
  String get learningOutcomes => 'Leeruitkomsten';

  @override
  String get studyLoad => 'Studielast';

  @override
  String get language => 'Taal';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get languageEnglish => 'Engels';

  @override
  String get assessmentWrittenExam => 'Tentamen';

  @override
  String get assessmentReportPaper => 'Rapport / paper';

  @override
  String get assessmentBehaviouralAssessment => 'Gedragsassessment';

  @override
  String get assessmentProfessionalProduct => 'Beroepsproduct';

  @override
  String get assessmentDevelopmentReport =>
      'Ontwikkelverslag / reflectieverslag';

  @override
  String get assessmentPortfolioAssessment =>
      'Portfolio / portfolio assessment';

  @override
  String get assessmentOramExam => 'Presentatie / mondeling examen';

  @override
  String get assessmentPersonalizedAssessment => 'Gepersonaliseerde toetsing';

  @override
  String get supervised => 'Onder toezicht';

  @override
  String get assessmentSupervisedWithIdentityVerification =>
      'Onder toezicht, met identiteit verificatie';

  @override
  String get assessmentWithIdentityVerification => 'Met identiteit verificatie';

  @override
  String get assessmentType => 'Beoordelingstype';

  @override
  String get online => 'Online';

  @override
  String get onsite => 'Op locatie';

  @override
  String get blended => 'Blended';

  @override
  String get workExperience => 'Werkervaring';

  @override
  String get formOfParticipation => 'Vorm van participatie';

  @override
  String get indicativeLevel => '(Indicatief) EQF/NLQF';

  @override
  String get never => 'Nooit';

  @override
  String get claimEdubadge => 'Claim edubadge';

  @override
  String get decline => 'Weigeren';

  @override
  String get declineBadgeTitle => 'Edubadge weigeren';

  @override
  String get declineBadgeConfirmation =>
      'Je staat op het punt deze edubadge te weigeren. Deze actie is definitief en kan niet worden teruggedraaid.';

  @override
  String badgesRemainingToClaim(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nog $countString edubadges te claimen',
      one: 'Nog 1 edubadge te claimen',
      zero: 'Geen edubadges meer te claimen',
    );
    return '$_temp0';
  }

  @override
  String get badgePrivacyTitle => 'Edubadges en jouw privacy';

  @override
  String get badgePrivacyReadButton => 'Ik heb dit gelezen';

  @override
  String get badgePrivacyViewFullText => 'Bekijk volledige tekst';

  @override
  String get badgeClaimSuccessTitle => 'Gefeliciteerd!';

  @override
  String get badgeClaimSuccessSubtitle =>
      'Je hebt een nieuwe edubadge geclaimed';

  @override
  String claimNextBadge(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Claim nog $countString edubadges',
      one: 'Claim nog 1 edubadge',
    );
    return '$_temp0';
  }

  @override
  String get goToOverview => 'Ga naar jouw overzicht';

  @override
  String get badgeClaimErrorTitle => 'Het is even niet gelukt';

  @override
  String get badgeClaimErrorSubtitle =>
      'Je edubadge kan op dit moment niet worden geclaimd. Geen zorgen, je voortgang is bewaard. Probeer het later nog eens.';
}
