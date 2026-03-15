// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class NoteDetailsLocalizationsPt extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get newNote => 'Nova nota';

  @override
  String get editNote => 'Editar nota';

  @override
  String get titleHint => 'Título';

  @override
  String get contentHint => 'Comece a escrever...';

  @override
  String get noteNotFound => 'Note not found';

  @override
  String get noteLoadFailed => 'Failed to load note';

  @override
  String get noteSaveFailed => 'Failed to save note';

  @override
  String get noteColor => 'Cor da nota';
}
