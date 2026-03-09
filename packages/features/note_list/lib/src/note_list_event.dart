part of 'note_list_bloc.dart';

sealed class NoteListEvent {}

class NoteListStarted extends NoteListEvent {}

class NoteListNoteDeleted extends NoteListEvent {
  NoteListNoteDeleted(this.id);
  final String id;
}

class NoteListQueryChanged extends NoteListEvent {
  NoteListQueryChanged(this.query);
  final String query;
}
