part of 'note_details_bloc.dart';

sealed class NoteDetailsEvent {}

class NoteDetailsStarted extends NoteDetailsEvent {
  NoteDetailsStarted({this.noteId});

  final String? noteId;

  @override
  String toString() => 'NoteDetailsStarted(noteId: $noteId)';
}

class NoteDetailsTitleChanged extends NoteDetailsEvent {
  NoteDetailsTitleChanged(this.title);

  final String title;

  @override
  String toString() => 'NoteDetailsTitleChanged(title: "$title")';
}

class NoteDetailsContentChanged extends NoteDetailsEvent {
  NoteDetailsContentChanged(this.content);

  final String content;

  @override
  String toString() =>
      'NoteDetailsContentChanged(content: "${content.length} chars")';
}

class NoteDetailsColorChanged extends NoteDetailsEvent {
  NoteDetailsColorChanged(this.color);

  final NoteColor color;

  @override
  String toString() => 'NoteDetailsColorChanged(color: $color)';
}

class NoteDetailsPinToggled extends NoteDetailsEvent {
  @override
  String toString() => 'NoteDetailsPinToggled()';
}

class NoteDetailsSaved extends NoteDetailsEvent {
  @override
  String toString() => 'NoteDetailsSaved()';
}

class NoteDetailsDeleteRequested extends NoteDetailsEvent {
  @override
  String toString() => 'NoteDetailsDeleteRequested()';
}
