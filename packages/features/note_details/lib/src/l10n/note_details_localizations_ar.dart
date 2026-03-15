// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class NoteDetailsLocalizationsAr extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get newNote => 'ملاحظة جديدة';

  @override
  String get editNote => 'تعديل الملاحظة';

  @override
  String get titleHint => 'العنوان';

  @override
  String get contentHint => 'ابدأ الكتابة...';

  @override
  String get noteNotFound => 'Note not found';

  @override
  String get noteLoadFailed => 'Failed to load note';

  @override
  String get noteSaveFailed => 'Failed to save note';

  @override
  String get noteColor => 'لون الملاحظة';
}
