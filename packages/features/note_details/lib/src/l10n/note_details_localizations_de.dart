// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class NoteDetailsLocalizationsDe extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get newNote => 'Neue Notiz';

  @override
  String get editNote => 'Notiz bearbeiten';

  @override
  String get titleHint => 'Titel';

  @override
  String get contentHint => 'Beginne zu tippen...';

  @override
  String get noteNotFound => 'Note not found';

  @override
  String get noteLoadFailed => 'Failed to load note';

  @override
  String get noteSaveFailed => 'Failed to save note';

  @override
  String get noteColor => 'Notizenfarbe';
}
