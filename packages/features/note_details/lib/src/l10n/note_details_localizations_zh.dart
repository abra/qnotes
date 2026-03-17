// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class NoteDetailsLocalizationsZh extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get newNote => '新建笔记';

  @override
  String get editNote => '编辑笔记';

  @override
  String get titleHint => '标题';

  @override
  String get contentHint => '开始输入...';

  @override
  String get noteNotFound => '笔记未找到';

  @override
  String get noteLoadFailed => '加载笔记失败';

  @override
  String get noteSaveFailed => '保存笔记失败';

  @override
  String get noteColor => '笔记颜色';
}
