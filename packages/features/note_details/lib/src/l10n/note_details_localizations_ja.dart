// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class NoteDetailsLocalizationsJa extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get newNote => '新しいメモ';

  @override
  String get editNote => 'メモを編集';

  @override
  String get titleHint => 'タイトル';

  @override
  String get contentHint => '入力を開始...';

  @override
  String get noteNotFound => 'Note not found';

  @override
  String get noteLoadFailed => 'Failed to load note';

  @override
  String get noteSaveFailed => 'Failed to save note';
}
