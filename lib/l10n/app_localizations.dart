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
