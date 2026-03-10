// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class NoteListLocalizationsPt extends NoteListLocalizations {
  NoteListLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String selected(int count) {
    return '$count selecionados';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas excluídas',
      one: 'Nota excluída',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'Sem notas';

  @override
  String get searchHint => 'Pesquisar';
}
