// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'preferences_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class PreferencesLocalizationsJa extends PreferencesLocalizations {
  PreferencesLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get preferences => '設定';

  @override
  String get theme => 'テーマ';

  @override
  String get notesView => 'ノートの表示';

  @override
  String get listDensity => 'リスト密度';

  @override
  String get language => '言語';

  @override
  String get searchHint => '検索';
}
