// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class NoteDetailsLocalizationsFr extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get newNote => 'Nouvelle note';

  @override
  String get editNote => 'Modifier la note';

  @override
  String get titleHint => 'Titre';

  @override
  String get contentHint => 'Commencez à écrire...';

  @override
  String get noteNotFound => 'Note not found';

  @override
  String get noteLoadFailed => 'Failed to load note';

  @override
  String get noteSaveFailed => 'Failed to save note';

  @override
  String get noteColor => 'Couleur de la note';
}
