// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class NoteListLocalizationsJa extends NoteListLocalizations {
  NoteListLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String selected(int count) {
    return '$count 件選択中';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のメモを削除しました',
      one: 'メモを削除しました',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'メモがありません';

  @override
  String get searchHint => '検索';
}
