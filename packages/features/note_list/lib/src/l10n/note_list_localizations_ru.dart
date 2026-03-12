// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class NoteListLocalizationsRu extends NoteListLocalizations {
  NoteListLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String selected(int count) {
    return '$count выбрано';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заметки удалены',
      one: 'Заметка удалена',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'Нет заметок';

  @override
  String get searchHint => 'Поиск';

  @override
  String get noteDeleteFailed => 'Не удалось удалить заметку';
}
