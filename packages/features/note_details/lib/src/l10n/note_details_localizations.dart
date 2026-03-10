import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'note_details_localizations_ar.dart';
import 'note_details_localizations_de.dart';
import 'note_details_localizations_en.dart';
import 'note_details_localizations_es.dart';
import 'note_details_localizations_fr.dart';
import 'note_details_localizations_hi.dart';
import 'note_details_localizations_ja.dart';
import 'note_details_localizations_pt.dart';
import 'note_details_localizations_ru.dart';
import 'note_details_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of NoteDetailsLocalizations
/// returned by `NoteDetailsLocalizations.of(context)`.
///
/// Applications need to include `NoteDetailsLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/note_details_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: NoteDetailsLocalizations.localizationsDelegates,
///   supportedLocales: NoteDetailsLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the NoteDetailsLocalizations.supportedLocales
/// property.
abstract class NoteDetailsLocalizations {
  NoteDetailsLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static NoteDetailsLocalizations? of(BuildContext context) {
    return Localizations.of<NoteDetailsLocalizations>(
      context,
      NoteDetailsLocalizations,
    );
  }

  static const LocalizationsDelegate<NoteDetailsLocalizations> delegate =
      _NoteDetailsLocalizationsDelegate();

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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get newNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleHint;

  /// No description provided for @contentHint.
  ///
  /// In en, this message translates to:
  /// **'Start typing...'**
  String get contentHint;

  /// No description provided for @noteNotFound.
  ///
  /// In en, this message translates to:
  /// **'Note not found'**
  String get noteNotFound;

  /// No description provided for @noteLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load note'**
  String get noteLoadFailed;

  /// No description provided for @noteSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save note'**
  String get noteSaveFailed;
}

class _NoteDetailsLocalizationsDelegate
    extends LocalizationsDelegate<NoteDetailsLocalizations> {
  const _NoteDetailsLocalizationsDelegate();

  @override
  Future<NoteDetailsLocalizations> load(Locale locale) {
    return SynchronousFuture<NoteDetailsLocalizations>(
      lookupNoteDetailsLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_NoteDetailsLocalizationsDelegate old) => false;
}

NoteDetailsLocalizations lookupNoteDetailsLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return NoteDetailsLocalizationsAr();
    case 'de':
      return NoteDetailsLocalizationsDe();
    case 'en':
      return NoteDetailsLocalizationsEn();
    case 'es':
      return NoteDetailsLocalizationsEs();
    case 'fr':
      return NoteDetailsLocalizationsFr();
    case 'hi':
      return NoteDetailsLocalizationsHi();
    case 'ja':
      return NoteDetailsLocalizationsJa();
    case 'pt':
      return NoteDetailsLocalizationsPt();
    case 'ru':
      return NoteDetailsLocalizationsRu();
    case 'zh':
      return NoteDetailsLocalizationsZh();
  }

  throw FlutterError(
    'NoteDetailsLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
