// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class NoteListLocalizationsEs extends NoteListLocalizations {
  NoteListLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String selected(int count) {
    return '$count seleccionados';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas eliminadas',
      one: 'Nota eliminada',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'No hay notas';

  @override
  String get searchHint => 'Buscar';

  @override
  String get noteDeleteFailed => 'Failed to delete note';

  @override
  String get loadFailed => 'Error al cargar notas';

  @override
  String get retry => 'Reintentar';
}
