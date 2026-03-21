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
  String get noteNotFound => 'Note introuvable';

  @override
  String get noteLoadFailed => 'Échec du chargement de la note';

  @override
  String get noteSaveFailed => 'Échec de la sauvegarde de la note';

  @override
  String get noteColor => 'Couleur de la note';

  @override
  String get imageInsertFailed => 'Échec de l\'insertion de l\'image';
}
