// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class NoteListLocalizationsEn extends NoteListLocalizations {
  NoteListLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String selected(int count) {
    return '$count selected';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes deleted',
      one: 'Note deleted',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'No notes yet';

  @override
  String get searchHint => 'Search';
}
