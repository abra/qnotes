import 'package:shared/src/models/note.dart';
import 'package:shared/src/models/note_color.dart';

abstract interface class NoteRepository {
  /// Returns all notes ordered by [isPinned] desc, [updatedAt] desc.
  Future<List<Note>> getNotes();

  /// Returns a single note by [id], or null if not found.
  Future<Note?> getNoteById(String id);

  /// Inserts a new note and returns it with generated [id] and [createdAt].
  Future<Note> createNote({
    String? title,
    required String content,
    NoteColor color = NoteColor.none,
  });

  /// Updates an existing note and returns the updated version.
  Future<Note> updateNote(Note note);

  /// Deletes a note by [id].
  Future<void> deleteNote(String id);

  /// Returns the color of the most recently created note, or null if none exist.
  Future<NoteColor?> getLastCreatedNoteColor();
}
