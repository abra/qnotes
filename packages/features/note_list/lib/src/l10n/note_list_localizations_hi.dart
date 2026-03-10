// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class NoteListLocalizationsHi extends NoteListLocalizations {
  NoteListLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String selected(int count) {
    return '$count चुने गए';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count नोट हटाए गए',
      one: 'नोट हटाया गया',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'अभी कोई नोट नहीं';

  @override
  String get searchHint => 'खोजें';
}
