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
  String get loginCardButton => 'Go to your backpack';

  @override
  String get loginFailedMessage =>
      'Signing in was cancelled or did not succeed. Please try again.';

  @override
  String get loginCardText =>
      'Your backpack is the place where you can receive, manage, and share your edubadges.\n\nTo sign in to your backpack, you need an eduID. Click the button below and sign in with your eduID.\n\nDon\'t have an eduID yet? You can easily create one.';

  @override
  String get loginSubtitle =>
      'Edubadges are digital certificates that demonstrate the knowledge and skills someone has acquired, within or outside formal education.';

  @override
  String get loginTitle => 'Never stop learning';

  @override
  String get generalAgreementTitle => 'Privacy Policy';

  @override
  String get generalAgreementButtonReadMore => 'Read more';

  @override
  String get generalAgreementButtonAgree => 'I agree';

  @override
  String get tabAccount => 'Account';

  @override
  String get accountSubtitle => 'Manage your data and settings';

  @override
  String get tabBadges => 'Edubadges';

  @override
  String get badgesOverviewTitle => 'My Edubadges';

  @override
  String get badgesOverviewSubtitle =>
      'Overview of your earned and requested edubadges';

  @override
  String get tabCatalog => 'Catalog';

  @override
  String get catalogSubtitle => 'Discover available edubadges per institution';

  @override
  String get catalogSearchPlaceholder => 'Search by name or institution...';

  @override
  String get tabCollections => 'Collections';

  @override
  String get search => 'Search';

  @override
  String get filters => 'Filters';

  @override
  String get allLevels => 'All levels';

  @override
  String get mbo => 'MBO';

  @override
  String get hbo => 'HBO';

  @override
  String get wo => 'WO';

  @override
  String get allInstitutions => 'All educational institutions';

  @override
  String get searchPlaceholder => 'Search...';

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
  String get collectionNameRequired => 'This field is required';

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
  String memberSinceDateValue(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'EEEE, MMMM d, y \'at\' h:mm a',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get generalNotifications => 'General notifications';

  @override
  String get languageSettings => 'Language';

  @override
  String get notificationPermissionDeniedTitle =>
      'Notification permission required';

  @override
  String get notificationPermissionDeniedMessage =>
      'Please enable notifications in your device settings to receive updates.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get givenAgreements => 'Given agreement(s)';

  @override
  String get agreementsDescription =>
      'You can withdraw your given agreement(s).';

  @override
  String get agreementTypeInformalBadge => 'Non-formal edubadges';

  @override
  String get agreementTypeFormalBadge => 'Formal edubadges';

  @override
  String get agreementTypeTermsOfService => 'Terms of service';

  @override
  String get agreementTypeServiceAgreement => 'Service agreement';

  @override
  String get agreementTypeUnknown => 'Unknown';

  @override
  String get deleteAccount => 'Delete your edubadges account';

  @override
  String get deleteAccountDescription =>
      'You can delete your edubadges account if you wish.\n\nPlease note that deleting your account will also permanently remove all the edubadges you have earned. Any edubadges you have previously shared can no longer be verified.\n\nDeleting your account is permanent and cannot be undone.';

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get deleteAccountError =>
      'We couldn\'t remove your account. Please contact support if this happens again.';

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
  String get withdrawAgreementSuccess => 'Agreement withdrawn';

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
  String get badgesInCollection => 'Badges in collection';

  @override
  String get badgesInCollectionHelper =>
      'To create a collection you need to select at least one edubadge.';

  @override
  String get saveChangesTitle => 'Save changes?';

  @override
  String get unsavedCollectionChangesDescription =>
      'You have made changes to this collection. Do you want to save them before you leave this screen?';

  @override
  String get dontSave => 'Don\'t save';

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
  String badgesTabEarned(int count) {
    return 'Earned ($count)';
  }

  @override
  String badgesTabRequested(int count) {
    return 'Requested ($count)';
  }

  @override
  String get noEdubadgesYet => 'You don\'t have any edubadges yet';

  @override
  String get noRequestedBadges => 'You haven\'t requested any edubadges yet';

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
  String get badgeCriteria => 'Criteria';

  @override
  String get badgeEvidenceMetadataTitle =>
      'Metadata about the evidence related to this edubadge';

  @override
  String get badgeEvidencePersonalMessage => 'Personal message';

  @override
  String get badgeEvidenceUrl => 'URL';

  @override
  String get badgeEvidenceName => 'Name';

  @override
  String get badgeEvidenceDescription => 'Description';

  @override
  String get studyLoad => 'Study load';

  @override
  String get language => 'Language';

  @override
  String get languageDutch => 'Dutch';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get languageGerman => 'German';

  @override
  String get languageSpanish => 'Spanish';

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
  String get claimPrivateEmailTitle => 'Claim and add to your backpack';

  @override
  String get claimPrivateEmailDescription =>
      'After this edubadge is claimed, it will be added to your backpack and you can make the edubadge public and share it.';

  @override
  String claimPrivateEmailNameNote(String name) {
    return 'Note: this is the name that will appear on the edubadge: $name. If this is not correct, contact the institution.';
  }

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

  @override
  String get catalogNoSearchResults => 'No search results found';

  @override
  String get catalogNoBadgesAvailable => 'No badges available';

  @override
  String get catalogFailedToLoadInstitutions => 'Failed to load institutions';

  @override
  String get unableToLoad => 'Unable to load';

  @override
  String get unableToLoadSubtitle => 'Please try again later';

  @override
  String failedToLoadTermsFrom(String institution) {
    return 'Failed to load terms from $institution';
  }

  @override
  String agreedOnDateVersion(DateTime date, String version) {
    final intl.DateFormat dateDateFormat = intl.DateFormat(
      'MMM d, yyyy',
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return 'Agreed on $dateString, version $version';
  }

  @override
  String agreedOnUnknownVersion(String version) {
    return 'Agreed, version $version';
  }

  @override
  String notYetAgreedVersion(String version) {
    return 'Not yet agreed, version $version';
  }

  @override
  String get error100 => 'You don\'t have the required permissions.';

  @override
  String get error101 =>
      'Could not register email address. Address already in use.';

  @override
  String get error102 =>
      'You have already added this address. Please verify it.';

  @override
  String get error103 => 'Cannot remove primary email address.';

  @override
  String get error104 => 'Cannot remove only email address.';

  @override
  String get error105 =>
      'Unverified email address cannot be made primary email address.';

  @override
  String get error201 =>
      'May not request: you already requested this edubadge.';

  @override
  String get error202 =>
      'May not request: you already have been awarded this edubadge.';

  @override
  String get error203 => 'May not request: you don\'t have a student account.';

  @override
  String get error204 => 'Invalid request-id.';

  @override
  String get error205 => 'Request not found.';

  @override
  String get error206 => 'Accepted requests for edubadges cannot be withdrawn.';

  @override
  String get error207 => 'Users can only withdraw their own requests.';

  @override
  String get error208 => 'Missing badge class-id.';

  @override
  String get error209 => 'Cannot request.';

  @override
  String get error210 =>
      'You do not have permission. Check your assigned role in the badge class related to this request.';

  @override
  String get error211 => 'Request has already been denied.';

  @override
  String get error212 => 'Awarded requests can\'t be denied.';

  @override
  String get error213 =>
      'Can\'t award requested edubadge, it has already been awarded.';

  @override
  String get error214 =>
      'Cannot change any value, edubadges have already been awarded within this entity.';

  @override
  String get error215 =>
      'Cannot create a formal badge class for an institution without the judicial basis for formal edubadges.';

  @override
  String get error216 =>
      'Cannot create an non-formal badge class for an institution without the judicial basis for non-formal edubadges.';

  @override
  String get error500 =>
      'Cannot remove the last staff member of this institution.';

  @override
  String get error501 => 'There may be only one invite per email address.';

  @override
  String get error502 =>
      'Cannot invite user for this entity: there is a conflicting staff membership.';

  @override
  String get error503 =>
      'Cannot invite user for this entity: there is a conflicting invite.';

  @override
  String get error504 => 'May not invite user from different institution.';

  @override
  String get error505 => 'This invite is for a student.';

  @override
  String get error506 => 'This invite is for a teacher.';

  @override
  String get error507 =>
      'You do not have permission to invite user for this entity.';

  @override
  String get error508 =>
      'You cannot edit an invitation that has been rejected.';

  @override
  String get error509 => 'Not a valid email address.';

  @override
  String get error510 => 'You entered this email address multiple times.';

  @override
  String get error601 =>
      'You do not have permission. Check your assigned role in the issuer portal.';

  @override
  String get error701 => 'Unspecified share provider.';

  @override
  String get error702 => 'Invalid share provider.';

  @override
  String get error801 =>
      'Cannot change grading table URL, edubadges have already been issued.';

  @override
  String get error802 =>
      'Cannot change institution code, edubadges have already been issued.';

  @override
  String get error902 => 'Must be a valid URL or picture format.';

  @override
  String get error903 => 'This is a required attribute.';

  @override
  String get error904 => 'No file was uploaded.';

  @override
  String get error905 => 'Either criteria or criteria URL is required.';

  @override
  String get error906 =>
      'Enter the number of study load hours or remove this section.';

  @override
  String get error907 => 'This is a reserved name for badge classes';

  @override
  String get error908 =>
      'Cannot create Issuer with this English name in this issuer group. It already exists.';

  @override
  String get error909 =>
      'Enter the programme identifier or remove this section.';

  @override
  String get error910 => 'Either narrative or url is required.';

  @override
  String get error911 =>
      'Cannot create badge class with this name in this Issuer. It already exists.';

  @override
  String get error912 => 'An English or Dutch name is required.';

  @override
  String get error913 => 'An English or Dutch description is required.';

  @override
  String get error914 =>
      'Cannot create Issuer with this Dutch name in this issuer group. It already exists.';

  @override
  String get error915 => 'A Dutch or English url is required.';

  @override
  String get error916 =>
      'Cannot create Issuer Group with this Dutch name in this institution. It already exists.';

  @override
  String get error917 =>
      'Cannot create Issuer Group with this English name in this institution. It already exists.';

  @override
  String get error918 => 'A Dutch or English image is required.';

  @override
  String get error919 =>
      'Cannot create Institution with this Dutch name. It already exists.';

  @override
  String get error920 =>
      'Cannot create Institution with this English name. It already exists.';

  @override
  String get error921 => 'Invalid URL';

  @override
  String get error922 =>
      'Too many Related Educational Framework objects. The maximum is 8.';

  @override
  String get error923 => 'An English or Dutch url is required.';

  @override
  String get error924 => 'An English or Dutch name is required.';

  @override
  String get error925 => 'An English or Dutch description is required.';

  @override
  String get error926 => 'An English or Dutch image is required.';

  @override
  String get error927 => 'Email is invalid';

  @override
  String get error928 => 'EPPN is required';

  @override
  String get error929 => 'Email is duplicated';

  @override
  String get error930 => 'EPPN is duplicated';

  @override
  String get error931 =>
      'There is already an unaccepted direct award for this EPPN.';

  @override
  String get error932 => 'This badge class requires a narrative for awarding.';

  @override
  String get error933 => 'This badge class requires evidence for awarding.';

  @override
  String get error934 =>
      'The programme identifier is required when study points in ECTS/EC are specified.';

  @override
  String get error935 => 'Enter the time investment or remove this section.';

  @override
  String get error936 =>
      'Cannot create edubadge collection with this name as it already exists.';

  @override
  String get error937 => 'ECTS/EC can not be empty or 0.';

  @override
  String get error938 => 'This edubadge requires a motivation for enrollment.';

  @override
  String get error939 =>
      'This edubadge requires an evidence URL for enrollment.';

  @override
  String get error940 =>
      'There is already an edubadge or unaccepted direct award for this email.';

  @override
  String get error941 =>
      'There is already an edubadge request from this email.';

  @override
  String get error942 =>
      'EPPN does not match the EPPN-format of your institution.';

  @override
  String get error943 => 'There is already a claimed assertion for this EPPN.';

  @override
  String get error944 => 'This badge class requires a grade for awarding.';

  @override
  String get error945 => 'The type of institution is required.';

  @override
  String get error946 =>
      'Type of visibility is required for SURF institutions.';

  @override
  String get error947 =>
      'An English or Dutch image is required when issued on behalf of other organisation.';

  @override
  String get error948 => 'First name is required.';

  @override
  String get error949 => 'Surname is required.';

  @override
  String get errorUnexpected => 'Unexpected error occurred.';

  @override
  String get errorDescription =>
      'An unexpected error has occurred. Please try again later or contact support@edubadges.nl for support.';

  @override
  String get badgeRequestButton => 'Request';

  @override
  String get edubadgeRequested => 'Edubadge requested';

  @override
  String edubadgeRequestedOn(String date) {
    return 'Requested on $date';
  }

  @override
  String get cancelRequestButton => 'Cancel request';

  @override
  String get cancelRequestTitle => 'Cancel edubadge request';

  @override
  String get cancelRequestConfirmation =>
      'Are you sure you want to cancel your request for this edubadge? You can request it again later.';

  @override
  String get cancelRequestSuccess => 'Request cancelled';

  @override
  String get stackable => 'Stackable';

  @override
  String get stackableTrue => 'Yes, stackable';

  @override
  String get stackableFalse => 'No, stand alone edubadge';

  @override
  String get semanticsClose => 'Close';

  @override
  String get semanticsBack => 'Back';

  @override
  String get semanticsClearSearch => 'Clear search';

  @override
  String get semanticsClearFilter => 'Clear filter';

  @override
  String get semanticsBadgeImage => 'Badge image';

  @override
  String get semanticsInstitutionLogo => 'Institution logo';

  @override
  String get semanticsImageNotSupported => 'Image not available';

  @override
  String get semanticsBadgePublic =>
      'Badge is public. Tap to change visibility.';

  @override
  String get semanticsBadgePrivate =>
      'Badge is private. Tap to change visibility.';

  @override
  String get semanticsBadgeVisibilityPublic => 'Badge is public';

  @override
  String get semanticsBadgeVisibilityPrivate => 'Badge is private';

  @override
  String get semanticsLogout => 'Log out';

  @override
  String get semanticsCopyLink => 'Copy link';

  @override
  String get semanticsError => 'Error';

  @override
  String get semanticsLoginIllustration => 'Decorative illustration';

  @override
  String get semanticsEnabled => 'Enabled';

  @override
  String get semanticsDisabled => 'Disabled';

  @override
  String get semanticsLoading => 'Loading...';

  @override
  String get qualityAssurance => 'Quality assurance';

  @override
  String get readMore => 'Read more';

  @override
  String get readLess => 'Read less';

  @override
  String get loginConnectionError =>
      'We can\'t connect to the login service right now. Check your internet connection and try again.';

  @override
  String get sessionExpiredMessage =>
      'Your session has expired. Please log in again.';

  @override
  String get pageTitleLogin => 'Log in';

  @override
  String get pageTitleBadgeDetails => 'Edubadge details';

  @override
  String get pageTitleEnrollmentTerms => 'Terms for this edubadge';

  @override
  String get catalogLevelFilterLabel => 'Education level';
}
