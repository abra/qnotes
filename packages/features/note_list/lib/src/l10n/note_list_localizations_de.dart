// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class NoteListLocalizationsDe extends NoteListLocalizations {
  NoteListLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String selected(int count) {
    return '$count ausgewählt';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Notizen gelöscht',
      one: 'Notiz gelöscht',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'Keine Notizen';

  @override
  String get searchHint => 'Suchen';
}
