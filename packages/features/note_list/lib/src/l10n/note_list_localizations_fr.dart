// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class NoteListLocalizationsFr extends NoteListLocalizations {
  NoteListLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String selected(int count) {
    return '$count sélectionnés';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes supprimées',
      one: 'Note supprimée',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'Aucune note';

  @override
  String get searchHint => 'Rechercher';

  @override
  String get noteDeleteFailed => 'Failed to delete note';

  @override
  String get loadFailed => 'Échec du chargement des notes';

  @override
  String get retry => 'Réessayer';
}
