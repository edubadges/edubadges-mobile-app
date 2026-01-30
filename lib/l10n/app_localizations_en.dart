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
  String get generalAgreementTitle => 'Privacy Policy';

  @override
  String get generalAgreementButtonReadMore => 'Read more';

  @override
  String get generalAgreementButtonRead => 'Read';

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
  String get notificationPermissionsTitle => 'Stay informed';

  @override
  String get notificationPermissionsSubtitle =>
      'Edubadge can send you a notification when something is ready for you, such as a new badge or an important update.';

  @override
  String get notificationPermissionsLabel =>
      'You can always change this later in the settings.';

  @override
  String get notificationPermissionsButtonAllow => 'Allow notifications';

  @override
  String get notificationPermissionsButtonDeny => 'Not now';

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

  @override
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

  @override
  String get continueText => 'Continue';

  @override
  String get addEdubadges => 'Add Edubadges';

  @override
  String get selectAtLeastOneBadge => 'Select at least one badge';

  @override
  String get noBadgesAvailable => 'No badges available';

  @override
  String get add => 'Add';

  @override
  String newBadgeReady(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'There are $countString new edubadges ready',
      one: 'There is 1 new edubadge ready',
    );
    return '$_temp0';
  }

  @override
  String get requestedBadges => 'Requested badges';

  @override
  String get noEdubadgesYet => 'You don\'t have any edubadges yet';

  @override
  String get giveFeedback => 'Give feedback';

  @override
  String get giveFeedbackDescription =>
      'We\'d love to hear what you think about the app. Leave your feedback below.';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackPlaceholder => 'Type your feedback here...';

  @override
  String get feedbackRequired => 'Feedback is required';

  @override
  String get aboutThisEdubadge => 'About this Edubadge';

  @override
  String get theEdubadge => 'The Edubadge';

  @override
  String get issuedOn => 'Issued on';

  @override
  String get expiresOn => 'Expires on';

  @override
  String get type => 'Type';

  @override
  String get badgeTheProgram => 'The program';

  @override
  String get badgeTheAssessment => 'The assessment';

  @override
  String get learningOutcomes => 'Learning outcomes';

  @override
  String get studyLoad => 'Study load';

  @override
  String get language => 'Language';

  @override
  String get languageDutch => 'Dutch';

  @override
  String get languageEnglish => 'English';

  @override
  String get assessmentWrittenExam => '(Written) Exam';

  @override
  String get assessmentReportPaper => 'Report / paper';

  @override
  String get assessmentBehaviouralAssessment => 'Behavioural assessment';

  @override
  String get assessmentProfessionalProduct => 'Professional product';

  @override
  String get assessmentDevelopmentReport =>
      'Development report / reflection report';

  @override
  String get assessmentPortfolioAssessment =>
      'Portfolio / portfolio assessment';

  @override
  String get assessmentOramExam => 'Presentation / Oral exam';

  @override
  String get assessmentPersonalizedAssessment =>
      'Personalized type of assessment';

  @override
  String get supervised => 'Supervised';

  @override
  String get assessmentSupervisedWithIdentityVerification =>
      'Supervised with identity verification';

  @override
  String get assessmentWithIdentityVerification => 'With identity verification';

  @override
  String get assessmentType => 'Assessment type';

  @override
  String get online => 'Online';

  @override
  String get onsite => 'On-site';

  @override
  String get blended => 'Blended';

  @override
  String get workExperience => 'Work experience';

  @override
  String get formOfParticipation => 'Form of participation';

  @override
  String get indicativeLevel => '(Indicative) EQF/NLQF';

  @override
  String get never => 'Never';

  @override
  String get claimEdubadge => 'Claim edubadge';

  @override
  String get decline => 'Decline';

  @override
  String get declineBadgeTitle => 'Decline edubadge';

  @override
  String get declineBadgeConfirmation =>
      'You are about to decline this edubadge. This action is final and cannot be undone.';

  @override
  String badgesRemainingToClaim(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Still $countString edu-badges to claim',
      one: 'Still 1 edu-badge to claim',
      zero: 'No more edu-badges to claim',
    );
    return '$_temp0';
  }

  @override
  String get badgePrivacyTitle => 'Edubadges and your privacy';

  @override
  String get badgePrivacyReadButton => 'I have read this';

  @override
  String get badgePrivacyViewFullText => 'View full text';

  @override
  String get badgeClaimSuccessTitle => 'Congratulations!';

  @override
  String get badgeClaimSuccessSubtitle => 'You have claimed a new edubadge';

  @override
  String claimNextBadge(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Claim $countString more edubadges',
      one: 'Claim 1 more edubadge',
    );
    return '$_temp0';
  }

  @override
  String get goToOverview => 'Go to your overview';

  @override
  String get badgeClaimErrorTitle => 'Something went wrong';

  @override
  String get badgeClaimErrorSubtitle =>
      'Your edubadge cannot be claimed at this time. Don\'t worry, your progress has been saved. Please try again later.';

  @override
  String get microCredential => 'Microcredential';

  @override
  String get regular => 'Regular';

  @override
  String get extraCurricular => 'Extra curricular';

  @override
  String get badgeVisibleAndShareable => 'Edubadge visible and shareable';

  @override
  String get badgeVisibleAndShareableDescription =>
      'With this setting, you determine whether your edubadge is public and can be viewed by others when you share it.';

  @override
  String get toMakePublic => 'To make public';

  @override
  String get badgePublicShareWarning =>
      'To share this Edubadge, it must be made public.';

  @override
  String get makePublic => 'Make public';

  @override
  String get makeBadgePublicIncludeEvidence =>
      'Include evidence/personal message in the public information for this edubadge?';

  @override
  String get makeBadgePublicIncludeGradeAchieved =>
      'Include the earned grade in the public information for this edubadge?';

  @override
  String get actionMakePrivate => 'Make private';

  @override
  String get labelMakePrivate => 'Make private';

  @override
  String get badgeMakePrivateWarning =>
      'Are you sure you want to make this edubadge private?';

  @override
  String get badgeLinkCopied => 'Edubadge link copied to clipboard';
}
