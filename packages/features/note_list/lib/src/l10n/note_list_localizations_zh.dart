// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class NoteListLocalizationsZh extends NoteListLocalizations {
  NoteListLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String selected(int count) {
    return '$count 已选';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已删除 $count 条笔记',
      one: '已删除笔记',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => '暂无笔记';

  @override
  String get searchHint => '搜索';

  @override
  String get noteDeleteFailed => 'Failed to delete note';

  @override
  String get loadFailed => '加载笔记失败';

  @override
  String get retry => '重试';
}
