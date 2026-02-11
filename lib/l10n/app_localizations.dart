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
  /// **'Go to my edubadges'**
  String get loginCardButton;

  /// Explanatory text on the login card describing the app and eduID requirement
  ///
  /// In en, this message translates to:
  /// **'My Badges is the place to receive and collect edubadges. An eduID is required to create and use \"My Badges.\" Creating an eduID takes less than 30 seconds.'**
  String get loginCardText;

  /// Subtitle on the login page explaining what edubadges are
  ///
  /// In en, this message translates to:
  /// **'Edubadges are digital certificates that demonstrate the knowledge or skills someone has acquired, within or outside formal education.'**
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

  /// Button text to read the full agreement
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get generalAgreementButtonRead;

  /// Navigation tab label for the account section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get tabAccount;

  /// Navigation tab label for the edubadges section
  ///
  /// In en, this message translates to:
  /// **'Edubadges'**
  String get tabBadges;

  /// Navigation tab label for the catalog section
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get tabCatalog;

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

  /// Section header or button text for account deletion
  ///
  /// In en, this message translates to:
  /// **'Delete your edubadges account'**
  String get deleteAccount;

  /// Detailed description explaining the consequences of deleting an edubadges account
  ///
  /// In en, this message translates to:
  /// **'You can delete your edubadges account if you wish. Be aware that after this, all your edubadges can no longer be validated.\n\nDeleting your edubadges account does not mean that your eduID will also be deleted.\n\nTo complete the process of deleting your edubadges account, you must close your browser after your account has been deleted.'**
  String get deleteAccountDescription;

  /// Button text to confirm account deletion
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

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

  /// Message shown when user has no edubadges in their collection
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any edubadges yet'**
  String get noEdubadgesYet;

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

  /// No description provided for @notYetAgreedVersion.
  ///
  /// In en, this message translates to:
  /// **'Not yet agreed, version {version}'**
  String notYetAgreedVersion(String version);
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
