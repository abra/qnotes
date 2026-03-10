import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

import 'note_local_storage.dart';

/// Concrete implementation of [NoteRepository] backed by SQLite via drift.
class NotesRepository implements NoteRepository {
  NotesRepository({@visibleForTesting NoteLocalStorage? localStorage})
    : _storage = localStorage ?? NoteLocalStorage();

  final NoteLocalStorage _storage;

  @override
  Future<List<Note>> getNotes() => _storage.allNotes();

  @override
  Future<Note?> getNoteById(String id) => _storage.noteById(id);

  @override
  Future<Note> createNote({
    String? title,
    required String content,
    NoteColor color = NoteColor.none,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      color: color,
    );
    await _storage.insertNote(note);
    return note;
  }

  @override
  Future<Note> updateNote(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    await _storage.updateNote(updated);
    return updated;
  }

  @override
  Future<void> deleteNote(String id) => _storage.deleteNote(id);

  @override
  Future<NoteColor?> getLastCreatedNoteColor() async {
    final raw = await _storage.lastCreatedNoteColor();
    if (raw == null) return null;
    final color = NoteColor.from(raw);
    return color == NoteColor.none ? null : color;
  }
}
