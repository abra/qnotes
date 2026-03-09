part of 'note_details_bloc.dart';

sealed class NoteDetailsEvent {}

class NoteDetailsStarted extends NoteDetailsEvent {
  NoteDetailsStarted({this.noteId});
  final String? noteId;
}

class NoteDetailsTitleChanged extends NoteDetailsEvent {
  NoteDetailsTitleChanged(this.title);
  final String title;
}

class NoteDetailsContentChanged extends NoteDetailsEvent {
  NoteDetailsContentChanged(this.content);
  final String content;
}

class NoteDetailsColorChanged extends NoteDetailsEvent {
  NoteDetailsColorChanged(this.color);
  final NoteColor color;
}

class NoteDetailsPinToggled extends NoteDetailsEvent {}

class NoteDetailsSaved extends NoteDetailsEvent {}
