// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'preferences_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class PreferencesLocalizationsRu extends PreferencesLocalizations {
  PreferencesLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get preferences => 'Настройки';

  @override
  String get theme => 'Тема';

  @override
  String get notesView => 'Вид заметок';

  @override
  String get listDensity => 'Плотность списка';

  @override
  String get language => 'Язык';

  @override
  String get searchHint => 'Поиск';
}
