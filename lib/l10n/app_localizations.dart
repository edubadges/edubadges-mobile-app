import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Edubadges'**
  String get appName;

  /// No description provided for @loginCardButton.
  ///
  /// In en, this message translates to:
  /// **'Go to my edubadges'**
  String get loginCardButton;

  /// No description provided for @loginCardText.
  ///
  /// In en, this message translates to:
  /// **'My Badges is the place to receive and collect edubadges. An eduID is required to create and use \"My Badges.\" Creating an eduID takes less than 30 seconds.'**
  String get loginCardText;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edubadges are digital certificates that demonstrate the knowledge or skills someone has acquired, within or outside formal education.'**
  String get loginSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Never stop learning'**
  String get loginTitle;

  /// No description provided for @generalAgreementTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get generalAgreementTitle;

  /// No description provided for @generalAgreementButtonReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get generalAgreementButtonReadMore;

  /// No description provided for @generalAgreementButtonRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get generalAgreementButtonRead;

  /// No description provided for @tabAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get tabAccount;

  /// No description provided for @tabBadges.
  ///
  /// In en, this message translates to:
  /// **'Edubadges'**
  String get tabBadges;

  /// No description provided for @tabCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get tabCatalog;

  /// No description provided for @tabCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get tabCollections;

  /// No description provided for @newCollection.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get newCollection;

  /// No description provided for @newCollectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a new collection and share it with acquaintances.'**
  String get newCollectionDescription;

  /// No description provided for @collectionName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get collectionName;

  /// No description provided for @collectionNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Name of the collection'**
  String get collectionNamePlaceholder;

  /// No description provided for @collectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get collectionDescription;

  /// No description provided for @collectionDescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Description of the collection'**
  String get collectionDescriptionPlaceholder;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @collectionNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get collectionNameRequired;

  /// No description provided for @addEdubadgesToCollection.
  ///
  /// In en, this message translates to:
  /// **'Add edubadges to your collection'**
  String get addEdubadgesToCollection;

  /// No description provided for @addEdubadgesToCollectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Bundle edubadges in your collection to manage them clearly and share them easily.'**
  String get addEdubadgesToCollectionDescription;

  /// No description provided for @addEdubadge.
  ///
  /// In en, this message translates to:
  /// **'Add Edubadge'**
  String get addEdubadge;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @deleteCollectionConfirmation.
  ///
  /// In en, this message translates to:
  /// **'You are about to delete a collection.'**
  String get deleteCollectionConfirmation;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @accountData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get accountData;

  /// No description provided for @confirmedName.
  ///
  /// In en, this message translates to:
  /// **'Confirmed name'**
  String get confirmedName;

  /// No description provided for @providedByInstitution.
  ///
  /// In en, this message translates to:
  /// **'Provided by your institution'**
  String get providedByInstitution;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @institution.
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get institution;

  /// No description provided for @eduid.
  ///
  /// In en, this message translates to:
  /// **'#eduid'**
  String get eduid;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettings;

  /// No description provided for @generalNotifications.
  ///
  /// In en, this message translates to:
  /// **'General notifications'**
  String get generalNotifications;

  /// No description provided for @givenAgreements.
  ///
  /// In en, this message translates to:
  /// **'Given agreement(s)'**
  String get givenAgreements;

  /// No description provided for @agreementsDescription.
  ///
  /// In en, this message translates to:
  /// **'You can withdraw your given agreement(s).'**
  String get agreementsDescription;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete your edubadges account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'You can delete your edubadges account if you wish. Be aware that after this, all your edubadges can no longer be validated.\n\nDeleting your edubadges account does not mean that your eduID will also be deleted.\n\nTo complete the process of deleting your edubadges account, you must close your browser after your account has been deleted.'**
  String get deleteAccountDescription;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noProfileData.
  ///
  /// In en, this message translates to:
  /// **'No profile data'**
  String get noProfileData;

  /// No description provided for @logoutConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get logoutConfirmationTitle;

  /// No description provided for @logoutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'You are about to log out.'**
  String get logoutConfirmationMessage;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @deleteAccountConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccountConfirmationTitle;

  /// No description provided for @deleteAccountConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Be aware that after this, all your edubadges can no longer be validated. Deleting your edubadges account does not mean that your eduID will also be deleted.'**
  String get deleteAccountConfirmationMessage;

  /// No description provided for @deleteAccountConfirmationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type the word \'delete\' to permanently delete my badges'**
  String get deleteAccountConfirmationPrompt;

  /// No description provided for @deleteAccountInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type \'delete\''**
  String get deleteAccountInputPlaceholder;

  /// No description provided for @deleteAccountRequiredText.
  ///
  /// In en, this message translates to:
  /// **'delete'**
  String get deleteAccountRequiredText;

  /// No description provided for @privacyConditions.
  ///
  /// In en, this message translates to:
  /// **'Privacy conditions'**
  String get privacyConditions;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @viewFullText.
  ///
  /// In en, this message translates to:
  /// **'View full text'**
  String get viewFullText;

  /// No description provided for @viewShortText.
  ///
  /// In en, this message translates to:
  /// **'View short text'**
  String get viewShortText;

  /// No description provided for @withdrawAgreementTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw my agreement statement'**
  String get withdrawAgreementTitle;

  /// No description provided for @withdrawAgreementMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to withdraw your agreement statement for {institution}?'**
  String withdrawAgreementMessage(String institution);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @countHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String countHours(num count);

  /// No description provided for @noCollectionsYet.
  ///
  /// In en, this message translates to:
  /// **'No collections yet'**
  String get noCollectionsYet;

  /// No description provided for @countEdubadges.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 edubadge} other{{count} edubadges}}'**
  String countEdubadges(num count);

  /// No description provided for @errorLoadingCollections.
  ///
  /// In en, this message translates to:
  /// **'Error loading collections'**
  String get errorLoadingCollections;

  /// No description provided for @collectionVisibleAndShareable.
  ///
  /// In en, this message translates to:
  /// **'Collection visible and shareable'**
  String get collectionVisibleAndShareable;

  /// No description provided for @publicCollectionRequires.
  ///
  /// In en, this message translates to:
  /// **'A public collection requires at least 1 public edubadge'**
  String get publicCollectionRequires;

  /// No description provided for @privateBadgesError.
  ///
  /// In en, this message translates to:
  /// **'One or more badges are private, make them public to make this collection public.'**
  String get privateBadgesError;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @errorLoadingCollection.
  ///
  /// In en, this message translates to:
  /// **'Error loading collection'**
  String get errorLoadingCollection;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @editCollection.
  ///
  /// In en, this message translates to:
  /// **'Edit collection'**
  String get editCollection;

  /// No description provided for @editCollectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Update your collection details'**
  String get editCollectionDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
