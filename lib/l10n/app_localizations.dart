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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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

  /// The name of the application displayed throughout the app
  ///
  /// In en, this message translates to:
  /// **'Edubadges'**
  String get appName;

  /// Button text on the login card to navigate to the user's edubadges
  ///
  /// In en, this message translates to:
  /// **'Go to your backpack'**
  String get loginCardButton;

  /// Explanatory text on the login card describing the app and eduID requirement
  ///
  /// In en, this message translates to:
  /// **'Your backpack is the place where you can receive, manage, and share your edubadges.\n\nTo sign in to your backpack, you need an eduID. Click the button below and sign in with your eduID.\n\nDon\'t have an eduID yet? You can easily create one.'**
  String get loginCardText;

  /// Subtitle on the login page explaining what edubadges are
  ///
  /// In en, this message translates to:
  /// **'Edubadges are digital certificates that demonstrate the knowledge and skills someone has acquired, within or outside formal education.'**
  String get loginSubtitle;

  /// Main title displayed on the login page
  ///
  /// In en, this message translates to:
  /// **'Never stop learning'**
  String get loginTitle;

  /// Title for the general privacy policy agreement section
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get generalAgreementTitle;

  /// Button text to expand and read more of the agreement text
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get generalAgreementButtonReadMore;

  /// Button text to accept the general terms after reading them
  ///
  /// In en, this message translates to:
  /// **'I agree'**
  String get generalAgreementButtonAgree;

  /// Navigation tab label for the account section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get tabAccount;

  /// Page subtitle for the account screen on desktop
  ///
  /// In en, this message translates to:
  /// **'Manage your data and settings'**
  String get accountSubtitle;

  /// Navigation tab label for the edubadges section
  ///
  /// In en, this message translates to:
  /// **'Edubadges'**
  String get tabBadges;

  /// Page title for the badges overview screen on desktop
  ///
  /// In en, this message translates to:
  /// **'My Edubadges'**
  String get badgesOverviewTitle;

  /// Page subtitle for the badges overview screen on desktop
  ///
  /// In en, this message translates to:
  /// **'Overview of your earned and requested edubadges'**
  String get badgesOverviewSubtitle;

  /// Navigation tab label for the catalog section
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get tabCatalog;

  /// Page subtitle for the catalog screen on desktop
  ///
  /// In en, this message translates to:
  /// **'Discover available edubadges per institution'**
  String get catalogSubtitle;

  /// Placeholder text for the catalog search input field
  ///
  /// In en, this message translates to:
  /// **'Search by name or institution...'**
  String get catalogSearchPlaceholder;

  /// Navigation tab label for the collections section
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get tabCollections;

  /// Label or button text for search functionality
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Label or button text for filter options
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Filter option to show badges from all educational levels
  ///
  /// In en, this message translates to:
  /// **'All levels'**
  String get allLevels;

  /// Filter option for MBO (Middelbaar Beroepsonderwijs - secondary vocational education) level
  ///
  /// In en, this message translates to:
  /// **'MBO'**
  String get mbo;

  /// Filter option for HBO (Hoger Beroepsonderwijs - higher professional education) level
  ///
  /// In en, this message translates to:
  /// **'HBO'**
  String get hbo;

  /// Filter option for WO (Wetenschappelijk Onderwijs - university education) level
  ///
  /// In en, this message translates to:
  /// **'WO'**
  String get wo;

  /// Filter option to show badges from all educational institutions
  ///
  /// In en, this message translates to:
  /// **'All educational institutions'**
  String get allInstitutions;

  /// Placeholder text displayed in search input fields
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchPlaceholder;

  /// Button text or title for creating a new collection
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get newCollection;

  /// Description text explaining the purpose of creating a new collection
  ///
  /// In en, this message translates to:
  /// **'Create a new collection and share it with acquaintances.'**
  String get newCollectionDescription;

  /// Label for the collection name input field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get collectionName;

  /// Placeholder text for the collection name input field
  ///
  /// In en, this message translates to:
  /// **'Name of the collection'**
  String get collectionNamePlaceholder;

  /// Label for the collection description input field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get collectionDescription;

  /// Placeholder text for the collection description input field
  ///
  /// In en, this message translates to:
  /// **'Description of the collection'**
  String get collectionDescriptionPlaceholder;

  /// Button text to save changes or create new items
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Button text to cancel an action or close a dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Error message shown when collection name is not provided
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get collectionNameRequired;

  /// Title or header for the section where users can add edubadges to a collection
  ///
  /// In en, this message translates to:
  /// **'Add edubadges to your collection'**
  String get addEdubadgesToCollection;

  /// Description explaining the benefits of adding edubadges to a collection
  ///
  /// In en, this message translates to:
  /// **'Bundle edubadges in your collection to manage them clearly and share them easily.'**
  String get addEdubadgesToCollectionDescription;

  /// Button text to add an edubadge to a collection
  ///
  /// In en, this message translates to:
  /// **'Add Edubadge'**
  String get addEdubadge;

  /// Confirmation dialog title asking for user confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// Confirmation message shown when user attempts to delete a collection
  ///
  /// In en, this message translates to:
  /// **'You are about to delete a collection.'**
  String get deleteCollectionConfirmation;

  /// Button text to delete an item
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Title for the notification permissions request dialog
  ///
  /// In en, this message translates to:
  /// **'Stay informed'**
  String get notificationPermissionsTitle;

  /// Subtitle explaining what notifications will be used for
  ///
  /// In en, this message translates to:
  /// **'Edubadge can send you a notification when something is ready for you, such as a new badge or an important update.'**
  String get notificationPermissionsSubtitle;

  /// Label informing users they can change notification settings later
  ///
  /// In en, this message translates to:
  /// **'You can always change this later in the settings.'**
  String get notificationPermissionsLabel;

  /// Button text to allow notification permissions
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get notificationPermissionsButtonAllow;

  /// Button text to deny or postpone notification permissions
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notificationPermissionsButtonDeny;

  /// Section header for account data in the account settings
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get accountData;

  /// Label for the user's confirmed name field in account settings
  ///
  /// In en, this message translates to:
  /// **'Confirmed name'**
  String get confirmedName;

  /// Label indicating information is provided by the user's educational institution
  ///
  /// In en, this message translates to:
  /// **'Provided by your institution'**
  String get providedByInstitution;

  /// Label for the email address field in account settings
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// Label for the educational institution field
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get institution;

  /// Label for the eduID identifier field
  ///
  /// In en, this message translates to:
  /// **'#eduid'**
  String get eduid;

  /// Label showing when the user became a member
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// Formatted member-since date and time for the account profile
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String memberSinceDateValue(DateTime date);

  /// Section header or link text for notification settings
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettings;

  /// Label for general notification settings toggle
  ///
  /// In en, this message translates to:
  /// **'General notifications'**
  String get generalNotifications;

  /// Title for dialog when user has denied notification permission
  ///
  /// In en, this message translates to:
  /// **'Notification permission required'**
  String get notificationPermissionDeniedTitle;

  /// Message asking user to enable notifications in system settings
  ///
  /// In en, this message translates to:
  /// **'Please enable notifications in your device settings to receive updates.'**
  String get notificationPermissionDeniedMessage;

  /// Button to open app or system settings
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// Section header for agreements the user has given
  ///
  /// In en, this message translates to:
  /// **'Given agreement(s)'**
  String get givenAgreements;

  /// Description explaining that users can withdraw their agreements
  ///
  /// In en, this message translates to:
  /// **'You can withdraw your given agreement(s).'**
  String get agreementsDescription;

  /// Display name for informal badge agreement type
  ///
  /// In en, this message translates to:
  /// **'Non-formal edubadges'**
  String get agreementTypeInformalBadge;

  /// Display name for formal badge agreement type
  ///
  /// In en, this message translates to:
  /// **'Formal edubadges'**
  String get agreementTypeFormalBadge;

  /// Display name for terms of service agreement type
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get agreementTypeTermsOfService;

  /// Display name for service agreement type
  ///
  /// In en, this message translates to:
  /// **'Service agreement'**
  String get agreementTypeServiceAgreement;

  /// Display name for unknown agreement type
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get agreementTypeUnknown;

  /// Section header or button text for account deletion
  ///
  /// In en, this message translates to:
  /// **'Delete your edubadges account'**
  String get deleteAccount;

  /// Detailed description explaining the consequences of deleting an edubadges account
  ///
  /// In en, this message translates to:
  /// **'You can delete your edubadges account if you wish.\n\nPlease note that deleting your account will also permanently remove all the edubadges you have earned. Any edubadges you have previously shared can no longer be verified.\n\nDeleting your account is permanent and cannot be undone.'**
  String get deleteAccountDescription;

  /// Button text to confirm account deletion
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

  /// Error message shown when account deletion fails
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t remove your account. Please contact support if this happens again.'**
  String get deleteAccountError;

  /// Generic error message displayed when an error occurs
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Button text to retry a failed operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Message shown when no profile data is available
  ///
  /// In en, this message translates to:
  /// **'No profile data'**
  String get noProfileData;

  /// Title for the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get logoutConfirmationTitle;

  /// Message in the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'You are about to log out.'**
  String get logoutConfirmationMessage;

  /// Button text to log out of the application
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// Title for the account deletion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccountConfirmationTitle;

  /// Warning message in the account deletion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Be aware that after this, all your edubadges can no longer be validated. Deleting your edubadges account does not mean that your eduID will also be deleted.'**
  String get deleteAccountConfirmationMessage;

  /// Prompt asking user to type 'delete' to confirm account deletion
  ///
  /// In en, this message translates to:
  /// **'Type the word \'delete\' to permanently delete my badges'**
  String get deleteAccountConfirmationPrompt;

  /// Placeholder text for the account deletion confirmation input field
  ///
  /// In en, this message translates to:
  /// **'Type \'delete\''**
  String get deleteAccountInputPlaceholder;

  /// The text that must be typed to confirm account deletion
  ///
  /// In en, this message translates to:
  /// **'delete'**
  String get deleteAccountRequiredText;

  /// Label or title for privacy conditions section
  ///
  /// In en, this message translates to:
  /// **'Privacy conditions'**
  String get privacyConditions;

  /// Button text to withdraw an agreement or consent
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// Button text to expand and view the full text of an agreement
  ///
  /// In en, this message translates to:
  /// **'View full text'**
  String get viewFullText;

  /// Button text to collapse and view the short version of text
  ///
  /// In en, this message translates to:
  /// **'View short text'**
  String get viewShortText;

  /// Title for the withdraw agreement confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Withdraw my agreement statement'**
  String get withdrawAgreementTitle;

  /// Confirmation message asking if user wants to withdraw their agreement for a specific institution
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to withdraw your agreement statement for {institution}?'**
  String withdrawAgreementMessage(String institution);

  /// Success message shown after withdrawing an agreement
  ///
  /// In en, this message translates to:
  /// **'Agreement withdrawn'**
  String get withdrawAgreementSuccess;

  /// Button text to confirm an action
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Pluralized string displaying the number of hours
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String countHours(num count);

  /// Message shown when user has no collections
  ///
  /// In en, this message translates to:
  /// **'No collections yet'**
  String get noCollectionsYet;

  /// Pluralized string displaying the number of edubadges
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 edubadge} other{{count} edubadges}}'**
  String countEdubadges(num count);

  /// Error message shown when collections fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading collections'**
  String get errorLoadingCollections;

  /// Label indicating that a collection is publicly visible and can be shared
  ///
  /// In en, this message translates to:
  /// **'Collection visible and shareable'**
  String get collectionVisibleAndShareable;

  /// Informational message explaining the requirement for making a collection public
  ///
  /// In en, this message translates to:
  /// **'A public collection requires at least 1 public edubadge'**
  String get publicCollectionRequires;

  /// Error message shown when trying to make a collection public with private badges
  ///
  /// In en, this message translates to:
  /// **'One or more badges are private, make them public to make this collection public.'**
  String get privateBadgesError;

  /// Success message shown when a link is copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// Button text to copy a link to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// Error message shown when a collection fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading collection'**
  String get errorLoadingCollection;

  /// Button text to navigate back to the previous screen
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Button text or title for editing a collection
  ///
  /// In en, this message translates to:
  /// **'Edit collection'**
  String get editCollection;

  /// Description text for the edit collection screen
  ///
  /// In en, this message translates to:
  /// **'Update your collection details'**
  String get editCollectionDescription;

  /// Button text to continue to the next step
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// Button text to add multiple edubadges
  ///
  /// In en, this message translates to:
  /// **'Add Edubadges'**
  String get addEdubadges;

  /// Error or validation message requiring at least one badge to be selected
  ///
  /// In en, this message translates to:
  /// **'Select at least one badge'**
  String get selectAtLeastOneBadge;

  /// Message shown when there are no badges available to display or select
  ///
  /// In en, this message translates to:
  /// **'No badges available'**
  String get noBadgesAvailable;

  /// Button text to add an item
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Notification message informing user about new edubadges ready to claim
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{There is 1 new edubadge ready} other{There are {count} new edubadges ready}}'**
  String newBadgeReady(num count);

  /// Section header for badges that have been requested by the user
  ///
  /// In en, this message translates to:
  /// **'Requested badges'**
  String get requestedBadges;

  /// Tab label on the badges overview for the edubadges the user has earned, with the number of badges
  ///
  /// In en, this message translates to:
  /// **'Earned ({count})'**
  String badgesTabEarned(int count);

  /// Tab label on the badges overview for the edubadges the user has requested, with the number of badges
  ///
  /// In en, this message translates to:
  /// **'Requested ({count})'**
  String badgesTabRequested(int count);

  /// Message shown when user has no edubadges in their collection
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any edubadges yet'**
  String get noEdubadgesYet;

  /// Message shown on the requested tab when the user has not requested any edubadges
  ///
  /// In en, this message translates to:
  /// **'You haven\'t requested any edubadges yet'**
  String get noRequestedBadges;

  /// Button text or title for providing feedback
  ///
  /// In en, this message translates to:
  /// **'Give feedback'**
  String get giveFeedback;

  /// Description encouraging users to provide feedback about the app
  ///
  /// In en, this message translates to:
  /// **'We\'d love to hear what you think about the app. Leave your feedback below.'**
  String get giveFeedbackDescription;

  /// Label for the feedback input field
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Placeholder text for the feedback input field
  ///
  /// In en, this message translates to:
  /// **'Type your feedback here...'**
  String get feedbackPlaceholder;

  /// Error message shown when feedback field is empty
  ///
  /// In en, this message translates to:
  /// **'Feedback is required'**
  String get feedbackRequired;

  /// Section header for information about a specific edubadge
  ///
  /// In en, this message translates to:
  /// **'About this Edubadge'**
  String get aboutThisEdubadge;

  /// Section header for edubadge details
  ///
  /// In en, this message translates to:
  /// **'The Edubadge'**
  String get theEdubadge;

  /// Label for the date when the edubadge was issued
  ///
  /// In en, this message translates to:
  /// **'Issued on'**
  String get issuedOn;

  /// Label for the date when the edubadge expires
  ///
  /// In en, this message translates to:
  /// **'Expires on'**
  String get expiresOn;

  /// Label for the type field of an edubadge
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Section header for program information related to the badge
  ///
  /// In en, this message translates to:
  /// **'The program'**
  String get badgeTheProgram;

  /// Section header for assessment information related to the badge
  ///
  /// In en, this message translates to:
  /// **'The assessment'**
  String get badgeTheAssessment;

  /// Label for the learning outcomes section describing what was learned
  ///
  /// In en, this message translates to:
  /// **'Learning outcomes'**
  String get learningOutcomes;

  /// Section title for the badge award criteria on the edubadge details page
  ///
  /// In en, this message translates to:
  /// **'Criteria'**
  String get badgeCriteria;

  /// Section title for metadata fields tied to badge evidence
  ///
  /// In en, this message translates to:
  /// **'Metadata about the evidence related to this edubadge'**
  String get badgeEvidenceMetadataTitle;

  /// Label for the narrative or personal message in badge evidence
  ///
  /// In en, this message translates to:
  /// **'Personal message'**
  String get badgeEvidencePersonalMessage;

  /// Label for the URL field in badge evidence
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get badgeEvidenceUrl;

  /// Label for the name field in badge evidence
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get badgeEvidenceName;

  /// Label for the description field in badge evidence
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get badgeEvidenceDescription;

  /// Label for the study load or time commitment required
  ///
  /// In en, this message translates to:
  /// **'Study load'**
  String get studyLoad;

  /// Label for the language field
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language option for Dutch
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get languageDutch;

  /// Language option for English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language option for French
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// Language option for German
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// Language option for Spanish
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// Assessment type option for written or exam-based assessment
  ///
  /// In en, this message translates to:
  /// **'(Written) Exam'**
  String get assessmentWrittenExam;

  /// Assessment type option for report or paper submission
  ///
  /// In en, this message translates to:
  /// **'Report / paper'**
  String get assessmentReportPaper;

  /// Assessment type option for behavioural assessment
  ///
  /// In en, this message translates to:
  /// **'Behavioural assessment'**
  String get assessmentBehaviouralAssessment;

  /// Assessment type option for professional product creation
  ///
  /// In en, this message translates to:
  /// **'Professional product'**
  String get assessmentProfessionalProduct;

  /// Assessment type option for development or reflection report
  ///
  /// In en, this message translates to:
  /// **'Development report / reflection report'**
  String get assessmentDevelopmentReport;

  /// Assessment type option for portfolio-based assessment
  ///
  /// In en, this message translates to:
  /// **'Portfolio / portfolio assessment'**
  String get assessmentPortfolioAssessment;

  /// Assessment type option for presentation or oral examination
  ///
  /// In en, this message translates to:
  /// **'Presentation / Oral exam'**
  String get assessmentOramExam;

  /// Assessment type option for personalized or custom assessment
  ///
  /// In en, this message translates to:
  /// **'Personalized type of assessment'**
  String get assessmentPersonalizedAssessment;

  /// Label indicating that an assessment was supervised
  ///
  /// In en, this message translates to:
  /// **'Supervised'**
  String get supervised;

  /// Assessment supervision type with identity verification
  ///
  /// In en, this message translates to:
  /// **'Supervised with identity verification'**
  String get assessmentSupervisedWithIdentityVerification;

  /// Assessment type that includes identity verification
  ///
  /// In en, this message translates to:
  /// **'With identity verification'**
  String get assessmentWithIdentityVerification;

  /// Label for the assessment type field
  ///
  /// In en, this message translates to:
  /// **'Assessment type'**
  String get assessmentType;

  /// Option indicating online format or delivery
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Option indicating on-site or in-person format
  ///
  /// In en, this message translates to:
  /// **'On-site'**
  String get onsite;

  /// Option indicating blended (combination of online and on-site) format
  ///
  /// In en, this message translates to:
  /// **'Blended'**
  String get blended;

  /// Label for work experience section or requirement
  ///
  /// In en, this message translates to:
  /// **'Work experience'**
  String get workExperience;

  /// Label indicating how the user participated in the program
  ///
  /// In en, this message translates to:
  /// **'Form of participation'**
  String get formOfParticipation;

  /// Label for the indicative level using European or Dutch Qualifications Framework
  ///
  /// In en, this message translates to:
  /// **'(Indicative) EQF/NLQF'**
  String get indicativeLevel;

  /// Option indicating 'never' for expiration or other temporal fields
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// Button text to claim an edubadge that has been awarded
  ///
  /// In en, this message translates to:
  /// **'Claim edubadge'**
  String get claimEdubadge;

  /// Button text to decline or reject an offer or badge
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// Title for the dialog confirming badge decline
  ///
  /// In en, this message translates to:
  /// **'Decline edubadge'**
  String get declineBadgeTitle;

  /// Warning message shown when user is about to decline a badge
  ///
  /// In en, this message translates to:
  /// **'You are about to decline this edubadge. This action is final and cannot be undone.'**
  String get declineBadgeConfirmation;

  /// Title for the confirmation dialog when a badge was awarded to a private email address
  ///
  /// In en, this message translates to:
  /// **'Claim and add to your backpack'**
  String get claimPrivateEmailTitle;

  /// Explanation shown before claiming a badge awarded to a private email address
  ///
  /// In en, this message translates to:
  /// **'After this edubadge is claimed, it will be added to your backpack and you can make the edubadge public and share it.'**
  String get claimPrivateEmailDescription;

  /// Warning that the recipient name will be written on the claimed edubadge
  ///
  /// In en, this message translates to:
  /// **'Note: this is the name that will appear on the edubadge: {name}. If this is not correct, contact the institution.'**
  String claimPrivateEmailNameNote(String name);

  /// Message showing how many edubadges remain to be claimed
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No more edu-badges to claim} =1{Still 1 edu-badge to claim} other{Still {count} edu-badges to claim}}'**
  String badgesRemainingToClaim(num count);

  /// Title for the privacy information section related to edubadges
  ///
  /// In en, this message translates to:
  /// **'Edubadges and your privacy'**
  String get badgePrivacyTitle;

  /// Button text to acknowledge reading privacy information
  ///
  /// In en, this message translates to:
  /// **'I have read this'**
  String get badgePrivacyReadButton;

  /// Button text to view the full privacy policy text
  ///
  /// In en, this message translates to:
  /// **'View full text'**
  String get badgePrivacyViewFullText;

  /// Title shown on successful badge claim
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get badgeClaimSuccessTitle;

  /// Subtitle shown on successful badge claim
  ///
  /// In en, this message translates to:
  /// **'You have claimed a new edubadge'**
  String get badgeClaimSuccessSubtitle;

  /// Button text to claim additional edubadges showing how many remain
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Claim 1 more edubadge} other{Claim {count} more edubadges}}'**
  String claimNextBadge(num count);

  /// Button text to navigate to the overview screen
  ///
  /// In en, this message translates to:
  /// **'Go to your overview'**
  String get goToOverview;

  /// Title shown when badge claim fails
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get badgeClaimErrorTitle;

  /// Subtitle explaining the badge claim error and next steps
  ///
  /// In en, this message translates to:
  /// **'Your edubadge cannot be claimed at this time. Don\'t worry, your progress has been saved. Please try again later.'**
  String get badgeClaimErrorSubtitle;

  /// Badge type label for microcredential badges
  ///
  /// In en, this message translates to:
  /// **'Microcredential'**
  String get microCredential;

  /// Badge type label for regular badges
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get regular;

  /// Badge type label for extra-curricular activities
  ///
  /// In en, this message translates to:
  /// **'Extra curricular'**
  String get extraCurricular;

  /// Toggle label for making a badge publicly visible and shareable
  ///
  /// In en, this message translates to:
  /// **'Edubadge visible and shareable'**
  String get badgeVisibleAndShareable;

  /// Description explaining the badge visibility and sharing setting
  ///
  /// In en, this message translates to:
  /// **'With this setting, you determine whether your edubadge is public and can be viewed by others when you share it.'**
  String get badgeVisibleAndShareableDescription;

  /// Label or button text for making something public
  ///
  /// In en, this message translates to:
  /// **'To make public'**
  String get toMakePublic;

  /// Warning message that badge must be public to share
  ///
  /// In en, this message translates to:
  /// **'To share this Edubadge, it must be made public.'**
  String get badgePublicShareWarning;

  /// Button text to make a badge public
  ///
  /// In en, this message translates to:
  /// **'Make public'**
  String get makePublic;

  /// Checkbox label asking if evidence should be included when making badge public
  ///
  /// In en, this message translates to:
  /// **'Include evidence/personal message in the public information for this edubadge?'**
  String get makeBadgePublicIncludeEvidence;

  /// Checkbox label asking if grade should be included when making badge public
  ///
  /// In en, this message translates to:
  /// **'Include the earned grade in the public information for this edubadge?'**
  String get makeBadgePublicIncludeGradeAchieved;

  /// Button text to make a badge private
  ///
  /// In en, this message translates to:
  /// **'Make private'**
  String get actionMakePrivate;

  /// Label for the make private action
  ///
  /// In en, this message translates to:
  /// **'Make private'**
  String get labelMakePrivate;

  /// Confirmation message when making a badge private
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to make this edubadge private?'**
  String get badgeMakePrivateWarning;

  /// Success message shown when badge link is copied
  ///
  /// In en, this message translates to:
  /// **'Edubadge link copied to clipboard'**
  String get badgeLinkCopied;

  /// Message shown when catalog search returns no results
  ///
  /// In en, this message translates to:
  /// **'No search results found'**
  String get catalogNoSearchResults;

  /// Message shown when catalog has no badges to display
  ///
  /// In en, this message translates to:
  /// **'No badges available'**
  String get catalogNoBadgesAvailable;

  /// Error message shown when institutions fail to load in catalog
  ///
  /// In en, this message translates to:
  /// **'Failed to load institutions'**
  String get catalogFailedToLoadInstitutions;

  /// Generic error message for loading failures
  ///
  /// In en, this message translates to:
  /// **'Unable to load'**
  String get unableToLoad;

  /// Subtitle message suggesting user to retry later after a loading failure
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get unableToLoadSubtitle;

  /// No description provided for @failedToLoadTermsFrom.
  ///
  /// In en, this message translates to:
  /// **'Failed to load terms from {institution}'**
  String failedToLoadTermsFrom(String institution);

  /// No description provided for @agreedOnDateVersion.
  ///
  /// In en, this message translates to:
  /// **'Agreed on {date}, version {version}'**
  String agreedOnDateVersion(DateTime date, String version);

  /// No description provided for @agreedOnUnknownVersion.
  ///
  /// In en, this message translates to:
  /// **'Agreed, version {version}'**
  String agreedOnUnknownVersion(String version);

  /// No description provided for @notYetAgreedVersion.
  ///
  /// In en, this message translates to:
  /// **'Not yet agreed, version {version}'**
  String notYetAgreedVersion(String version);

  /// API error 100: shown when the user does not have the required permissions
  ///
  /// In en, this message translates to:
  /// **'You don\'t have the required permissions.'**
  String get error100;

  /// API error 101: email registration failed because the address is already in use
  ///
  /// In en, this message translates to:
  /// **'Could not register email address. Address already in use.'**
  String get error101;

  /// API error 102: user has already added this email address and must verify it
  ///
  /// In en, this message translates to:
  /// **'You have already added this address. Please verify it.'**
  String get error102;

  /// API error 103: user attempted to remove their primary email address
  ///
  /// In en, this message translates to:
  /// **'Cannot remove primary email address.'**
  String get error103;

  /// API error 104: user attempted to remove their only email address
  ///
  /// In en, this message translates to:
  /// **'Cannot remove only email address.'**
  String get error104;

  /// API error 105: unverified email cannot be set as primary
  ///
  /// In en, this message translates to:
  /// **'Unverified email address cannot be made primary email address.'**
  String get error105;

  /// API error 201: user already requested this edubadge
  ///
  /// In en, this message translates to:
  /// **'May not request: you already requested this edubadge.'**
  String get error201;

  /// API error 202: user has already been awarded this edubadge
  ///
  /// In en, this message translates to:
  /// **'May not request: you already have been awarded this edubadge.'**
  String get error202;

  /// API error 203: request not allowed because user has no student account
  ///
  /// In en, this message translates to:
  /// **'May not request: you don\'t have a student account.'**
  String get error203;

  /// API error 204: the request identifier is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid request-id.'**
  String get error204;

  /// API error 205: the requested resource was not found
  ///
  /// In en, this message translates to:
  /// **'Request not found.'**
  String get error205;

  /// API error 206: user tried to withdraw an already accepted edubadge request
  ///
  /// In en, this message translates to:
  /// **'Accepted requests for edubadges cannot be withdrawn.'**
  String get error206;

  /// API error 207: user tried to withdraw someone else's request
  ///
  /// In en, this message translates to:
  /// **'Users can only withdraw their own requests.'**
  String get error207;

  /// API error 208: badge class identifier is missing from the request
  ///
  /// In en, this message translates to:
  /// **'Missing badge class-id.'**
  String get error208;

  /// API error 209: request operation is not allowed
  ///
  /// In en, this message translates to:
  /// **'Cannot request.'**
  String get error209;

  /// API error 210: insufficient permission in the badge class for this request
  ///
  /// In en, this message translates to:
  /// **'You do not have permission. Check your assigned role in the badge class related to this request.'**
  String get error210;

  /// API error 211: the request was already denied
  ///
  /// In en, this message translates to:
  /// **'Request has already been denied.'**
  String get error211;

  /// API error 212: cannot deny an already awarded request
  ///
  /// In en, this message translates to:
  /// **'Awarded requests can\'t be denied.'**
  String get error212;

  /// API error 213: edubadge has already been awarded
  ///
  /// In en, this message translates to:
  /// **'Can\'t award requested edubadge, it has already been awarded.'**
  String get error213;

  /// API error 214: entity cannot be changed because edubadges have already been awarded
  ///
  /// In en, this message translates to:
  /// **'Cannot change any value, edubadges have already been awarded within this entity.'**
  String get error214;

  /// API error 215: institution lacks judicial basis for formal edubadges
  ///
  /// In en, this message translates to:
  /// **'Cannot create a formal badge class for an institution without the judicial basis for formal edubadges.'**
  String get error215;

  /// API error 216: institution lacks judicial basis for non-formal edubadges
  ///
  /// In en, this message translates to:
  /// **'Cannot create an non-formal badge class for an institution without the judicial basis for non-formal edubadges.'**
  String get error216;

  /// API error 500: cannot remove the last staff member of an institution
  ///
  /// In en, this message translates to:
  /// **'Cannot remove the last staff member of this institution.'**
  String get error500;

  /// API error 501: duplicate invite for the same email address
  ///
  /// In en, this message translates to:
  /// **'There may be only one invite per email address.'**
  String get error501;

  /// API error 502: invite conflicts with existing staff membership
  ///
  /// In en, this message translates to:
  /// **'Cannot invite user for this entity: there is a conflicting staff membership.'**
  String get error502;

  /// API error 503: a conflicting invite already exists for this entity
  ///
  /// In en, this message translates to:
  /// **'Cannot invite user for this entity: there is a conflicting invite.'**
  String get error503;

  /// API error 504: cannot invite a user from a different institution
  ///
  /// In en, this message translates to:
  /// **'May not invite user from different institution.'**
  String get error504;

  /// API error 505: invite is intended for a student
  ///
  /// In en, this message translates to:
  /// **'This invite is for a student.'**
  String get error505;

  /// API error 506: invite is intended for a teacher
  ///
  /// In en, this message translates to:
  /// **'This invite is for a teacher.'**
  String get error506;

  /// API error 507: user lacks permission to invite for this entity
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to invite user for this entity.'**
  String get error507;

  /// API error 508: attempted to edit a rejected invitation
  ///
  /// In en, this message translates to:
  /// **'You cannot edit an invitation that has been rejected.'**
  String get error508;

  /// API error 509: invalid email address format
  ///
  /// In en, this message translates to:
  /// **'Not a valid email address.'**
  String get error509;

  /// API error 510: same email address entered more than once
  ///
  /// In en, this message translates to:
  /// **'You entered this email address multiple times.'**
  String get error510;

  /// API error 601: insufficient permission in the issuer portal
  ///
  /// In en, this message translates to:
  /// **'You do not have permission. Check your assigned role in the issuer portal.'**
  String get error601;

  /// API error 701: share provider was not specified
  ///
  /// In en, this message translates to:
  /// **'Unspecified share provider.'**
  String get error701;

  /// API error 702: share provider is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid share provider.'**
  String get error702;

  /// API error 801: grading table URL cannot be changed after edubadges were issued
  ///
  /// In en, this message translates to:
  /// **'Cannot change grading table URL, edubadges have already been issued.'**
  String get error801;

  /// API error 802: institution code cannot be changed after edubadges were issued
  ///
  /// In en, this message translates to:
  /// **'Cannot change institution code, edubadges have already been issued.'**
  String get error802;

  /// API error 902: URL or image format is invalid
  ///
  /// In en, this message translates to:
  /// **'Must be a valid URL or picture format.'**
  String get error902;

  /// API error 903: a required attribute is missing
  ///
  /// In en, this message translates to:
  /// **'This is a required attribute.'**
  String get error903;

  /// API error 904: no file was provided in the upload
  ///
  /// In en, this message translates to:
  /// **'No file was uploaded.'**
  String get error904;

  /// API error 905: either criteria or criteria URL must be provided
  ///
  /// In en, this message translates to:
  /// **'Either criteria or criteria URL is required.'**
  String get error905;

  /// API error 906: study load hours required or section must be removed
  ///
  /// In en, this message translates to:
  /// **'Enter the number of study load hours or remove this section.'**
  String get error906;

  /// API error 907: the name is reserved for badge classes
  ///
  /// In en, this message translates to:
  /// **'This is a reserved name for badge classes'**
  String get error907;

  /// API error 908: issuer with this English name already exists in this issuer group
  ///
  /// In en, this message translates to:
  /// **'Cannot create Issuer with this English name in this issuer group. It already exists.'**
  String get error908;

  /// API error 909: programme identifier required or section must be removed
  ///
  /// In en, this message translates to:
  /// **'Enter the programme identifier or remove this section.'**
  String get error909;

  /// API error 910: either narrative or URL must be provided
  ///
  /// In en, this message translates to:
  /// **'Either narrative or url is required.'**
  String get error910;

  /// API error 911: badge class with this name already exists in this issuer
  ///
  /// In en, this message translates to:
  /// **'Cannot create badge class with this name in this Issuer. It already exists.'**
  String get error911;

  /// API error 912: name in English or Dutch is required
  ///
  /// In en, this message translates to:
  /// **'An English or Dutch name is required.'**
  String get error912;

  /// API error 913: description in English or Dutch is required
  ///
  /// In en, this message translates to:
  /// **'An English or Dutch description is required.'**
  String get error913;

  /// API error 914: issuer with this Dutch name already exists in this issuer group
  ///
  /// In en, this message translates to:
  /// **'Cannot create Issuer with this Dutch name in this issuer group. It already exists.'**
  String get error914;

  /// API error 915: URL in Dutch or English is required
  ///
  /// In en, this message translates to:
  /// **'A Dutch or English url is required.'**
  String get error915;

  /// API error 916: issuer group with this Dutch name already exists in this institution
  ///
  /// In en, this message translates to:
  /// **'Cannot create Issuer Group with this Dutch name in this institution. It already exists.'**
  String get error916;

  /// API error 917: issuer group with this English name already exists in this institution
  ///
  /// In en, this message translates to:
  /// **'Cannot create Issuer Group with this English name in this institution. It already exists.'**
  String get error917;

  /// API error 918: image in Dutch or English is required
  ///
  /// In en, this message translates to:
  /// **'A Dutch or English image is required.'**
  String get error918;

  /// API error 919: institution with this Dutch name already exists
  ///
  /// In en, this message translates to:
  /// **'Cannot create Institution with this Dutch name. It already exists.'**
  String get error919;

  /// API error 920: institution with this English name already exists
  ///
  /// In en, this message translates to:
  /// **'Cannot create Institution with this English name. It already exists.'**
  String get error920;

  /// API error 921: the URL is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get error921;

  /// API error 922: maximum number of Related Educational Framework objects (8) exceeded
  ///
  /// In en, this message translates to:
  /// **'Too many Related Educational Framework objects. The maximum is 8.'**
  String get error922;

  /// API error 923: URL in English or Dutch is required
  ///
  /// In en, this message translates to:
  /// **'An English or Dutch url is required.'**
  String get error923;

  /// API error 924: name in English or Dutch is required
  ///
  /// In en, this message translates to:
  /// **'An English or Dutch name is required.'**
  String get error924;

  /// API error 925: description in English or Dutch is required
  ///
  /// In en, this message translates to:
  /// **'An English or Dutch description is required.'**
  String get error925;

  /// API error 926: image in English or Dutch is required
  ///
  /// In en, this message translates to:
  /// **'An English or Dutch image is required.'**
  String get error926;

  /// API error 927: email address is invalid
  ///
  /// In en, this message translates to:
  /// **'Email is invalid'**
  String get error927;

  /// API error 928: EPPN (eduPerson Principal Name) is required
  ///
  /// In en, this message translates to:
  /// **'EPPN is required'**
  String get error928;

  /// API error 929: duplicate email address
  ///
  /// In en, this message translates to:
  /// **'Email is duplicated'**
  String get error929;

  /// API error 930: duplicate EPPN
  ///
  /// In en, this message translates to:
  /// **'EPPN is duplicated'**
  String get error930;

  /// API error 931: unaccepted direct award already exists for this EPPN
  ///
  /// In en, this message translates to:
  /// **'There is already an unaccepted direct award for this EPPN.'**
  String get error931;

  /// API error 932: narrative is required to award this badge class
  ///
  /// In en, this message translates to:
  /// **'This badge class requires a narrative for awarding.'**
  String get error932;

  /// API error 933: evidence is required to award this badge class
  ///
  /// In en, this message translates to:
  /// **'This badge class requires evidence for awarding.'**
  String get error933;

  /// API error 934: programme identifier required when ECTS/EC study points are given
  ///
  /// In en, this message translates to:
  /// **'The programme identifier is required when study points in ECTS/EC are specified.'**
  String get error934;

  /// API error 935: time investment required or section must be removed
  ///
  /// In en, this message translates to:
  /// **'Enter the time investment or remove this section.'**
  String get error935;

  /// API error 936: edubadge collection with this name already exists
  ///
  /// In en, this message translates to:
  /// **'Cannot create edubadge collection with this name as it already exists.'**
  String get error936;

  /// API error 937: ECTS/EC must be non-empty and greater than zero
  ///
  /// In en, this message translates to:
  /// **'ECTS/EC can not be empty or 0.'**
  String get error937;

  /// API error 938: motivation is required for enrollment in this edubadge
  ///
  /// In en, this message translates to:
  /// **'This edubadge requires a motivation for enrollment.'**
  String get error938;

  /// API error 939: evidence URL is required for enrollment in this edubadge
  ///
  /// In en, this message translates to:
  /// **'This edubadge requires an evidence URL for enrollment.'**
  String get error939;

  /// API error 940: edubadge or unaccepted direct award already exists for this email
  ///
  /// In en, this message translates to:
  /// **'There is already an edubadge or unaccepted direct award for this email.'**
  String get error940;

  /// API error 941: an edubadge request from this email already exists
  ///
  /// In en, this message translates to:
  /// **'There is already an edubadge request from this email.'**
  String get error941;

  /// API error 942: EPPN format does not match the institution's format
  ///
  /// In en, this message translates to:
  /// **'EPPN does not match the EPPN-format of your institution.'**
  String get error942;

  /// API error 943: a claimed assertion already exists for this EPPN
  ///
  /// In en, this message translates to:
  /// **'There is already a claimed assertion for this EPPN.'**
  String get error943;

  /// API error 944: grade is required to award this badge class
  ///
  /// In en, this message translates to:
  /// **'This badge class requires a grade for awarding.'**
  String get error944;

  /// API error 945: institution type is required
  ///
  /// In en, this message translates to:
  /// **'The type of institution is required.'**
  String get error945;

  /// API error 946: visibility type is required for SURF institutions
  ///
  /// In en, this message translates to:
  /// **'Type of visibility is required for SURF institutions.'**
  String get error946;

  /// API error 947: English or Dutch image required when issuing on behalf of another organisation
  ///
  /// In en, this message translates to:
  /// **'An English or Dutch image is required when issued on behalf of other organisation.'**
  String get error947;

  /// API error 948: first name is required
  ///
  /// In en, this message translates to:
  /// **'First name is required.'**
  String get error948;

  /// API error 949: surname is required
  ///
  /// In en, this message translates to:
  /// **'Surname is required.'**
  String get error949;

  /// Generic message when an unexpected or unknown error occurs
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred.'**
  String get errorUnexpected;

  /// Longer description for unexpected errors, with support contact information
  ///
  /// In en, this message translates to:
  /// **'An unexpected error has occurred. Please try again later or contact support@edubadges.nl for support.'**
  String get errorDescription;

  /// Button text to request an edubadge (self-enrollment)
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get badgeRequestButton;

  /// Status text when the user has requested an edubadge and is waiting for it
  ///
  /// In en, this message translates to:
  /// **'Edubadge requested'**
  String get edubadgeRequested;

  /// Status text when the user has requested an edubadge, with the date of the request
  ///
  /// In en, this message translates to:
  /// **'Requested on {date}'**
  String edubadgeRequestedOn(String date);

  /// Button text to cancel a pending edubadge request
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cancelRequestButton;

  /// Title for the dialog confirming cancellation of a pending edubadge request
  ///
  /// In en, this message translates to:
  /// **'Cancel edubadge request'**
  String get cancelRequestTitle;

  /// Confirmation message asking if the user wants to cancel a pending edubadge request
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel your request for this edubadge? You can request it again later.'**
  String get cancelRequestConfirmation;

  /// Success message shown after cancelling a pending edubadge request
  ///
  /// In en, this message translates to:
  /// **'Request cancelled'**
  String get cancelRequestSuccess;

  /// Stackable field for badge class
  ///
  /// In en, this message translates to:
  /// **'Stackable'**
  String get stackable;

  /// Stackable field for badge class can be stacked
  ///
  /// In en, this message translates to:
  /// **'Yes, stackable'**
  String get stackableTrue;

  /// Stackable field for badge class can be not stacked
  ///
  /// In en, this message translates to:
  /// **'No, stand alone edubadge'**
  String get stackableFalse;

  /// Accessibility label for close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get semanticsClose;

  /// Accessibility label for back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get semanticsBack;

  /// Accessibility label for clear search button
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get semanticsClearSearch;

  /// Accessibility label for clear filter button
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get semanticsClearFilter;

  /// Accessibility label for badge image
  ///
  /// In en, this message translates to:
  /// **'Badge image'**
  String get semanticsBadgeImage;

  /// Accessibility label for institution logo image
  ///
  /// In en, this message translates to:
  /// **'Institution logo'**
  String get semanticsInstitutionLogo;

  /// Accessibility label when image failed to load
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get semanticsImageNotSupported;

  /// Accessibility label for public badge visibility control
  ///
  /// In en, this message translates to:
  /// **'Badge is public. Tap to change visibility.'**
  String get semanticsBadgePublic;

  /// Accessibility label for private badge visibility control
  ///
  /// In en, this message translates to:
  /// **'Badge is private. Tap to change visibility.'**
  String get semanticsBadgePrivate;

  /// Accessibility label for the visibility indicator on a public badge
  ///
  /// In en, this message translates to:
  /// **'Badge is public'**
  String get semanticsBadgeVisibilityPublic;

  /// Accessibility label for the visibility indicator on a private badge
  ///
  /// In en, this message translates to:
  /// **'Badge is private'**
  String get semanticsBadgeVisibilityPrivate;

  /// Accessibility label for logout button
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get semanticsLogout;

  /// Accessibility label for copy link button
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get semanticsCopyLink;

  /// Accessibility label for error icon
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get semanticsError;

  /// Accessibility label for decorative login carousel image
  ///
  /// In en, this message translates to:
  /// **'Decorative illustration'**
  String get semanticsLoginIllustration;

  /// Accessibility label for enabled state (e.g. toggle or switch)
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get semanticsEnabled;

  /// Accessibility label for disabled state (e.g. toggle or switch)
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get semanticsDisabled;

  /// Accessibility label for loading indicator
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get semanticsLoading;

  /// Section header for the quality assurance information related to the badge
  ///
  /// In en, this message translates to:
  /// **'Quality assurance'**
  String get qualityAssurance;

  /// Generic button label to expand clamped content
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// Generic button label to collapse expanded content
  ///
  /// In en, this message translates to:
  /// **'Read less'**
  String get readLess;
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
