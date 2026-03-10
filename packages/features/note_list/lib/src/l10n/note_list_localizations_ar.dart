// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class NoteListLocalizationsAr extends NoteListLocalizations {
  NoteListLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String selected(int count) {
    return '$count محدد';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم حذف $count ملاحظات',
      one: 'تم حذف الملاحظة',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'لا توجد ملاحظات';

  @override
  String get searchHint => 'بحث';

  @override
  String get noteDeleteFailed => 'Failed to delete note';
}
