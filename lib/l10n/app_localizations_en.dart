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

  @override
  String get accountData => 'Data';

  @override
  String get confirmedName => 'Confirmed name';

  @override
  String get providedByInstitution => 'Provided by your institution';

  @override
  String get emailAddress => 'Email address';

  @override
  String get institution => 'Institution';

  @override
  String get eduid => '#eduid';

  @override
  String get memberSince => 'Member since';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get generalNotifications => 'General notifications';

  @override
  String get givenAgreements => 'Given agreement(s)';

  @override
  String get agreementsDescription =>
      'You can withdraw your given agreement(s).';

  @override
  String get deleteAccount => 'Delete your edubadges account';

  @override
  String get deleteAccountDescription =>
      'You can delete your edubadges account if you wish. Be aware that after this, all your edubadges can no longer be validated.\n\nDeleting your edubadges account does not mean that your eduID will also be deleted.\n\nTo complete the process of deleting your edubadges account, you must close your browser after your account has been deleted.';

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get noProfileData => 'No profile data';

  @override
  String get logoutConfirmationTitle => 'Are you sure?';

  @override
  String get logoutConfirmationMessage => 'You are about to log out.';

  @override
  String get logout => 'Log out';

  @override
  String get deleteAccountConfirmationTitle => 'Delete my account';

  @override
  String get deleteAccountConfirmationMessage =>
      'Be aware that after this, all your edubadges can no longer be validated. Deleting your edubadges account does not mean that your eduID will also be deleted.';

  @override
  String get deleteAccountConfirmationPrompt =>
      'Type the word \'delete\' to permanently delete my badges';

  @override
  String get deleteAccountInputPlaceholder => 'Type \'delete\'';

  @override
  String get deleteAccountRequiredText => 'delete';

  @override
  String get privacyConditions => 'Privacy conditions';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get viewFullText => 'View full text';

  @override
  String get viewShortText => 'View short text';

  @override
  String get withdrawAgreementTitle => 'Withdraw my agreement statement';

  @override
  String withdrawAgreementMessage(String institution) {
    return 'Are you sure you want to withdraw your agreement statement for $institution?';
  }

  @override
  String get confirm => 'Confirm';
  String countHours(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String get noCollectionsYet => 'No collections yet';

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
  String get errorLoadingCollections => 'Error loading collections';

  @override
  String get collectionVisibleAndShareable =>
      'Collection visible and shareable';

  @override
  String get publicCollectionRequires =>
      'A public collection requires at least 1 public edubadge';

  @override
  String get privateBadgesError =>
      'One or more badges are private, make them public to make this collection public.';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get copyLink => 'Copy link';

  @override
  String get errorLoadingCollection => 'Error loading collection';

  @override
  String get goBack => 'Go Back';

  @override
  String get editCollection => 'Edit collection';

  @override
  String get editCollectionDescription => 'Update your collection details';
}
