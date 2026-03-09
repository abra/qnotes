import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

import 'note_local_storage.dart';

/// Concrete implementation of [NoteRepository] backed by SQLite via drift.
class NotesRepository implements NoteRepository {
  NotesRepository({@visibleForTesting NoteLocalStorage? localStorage})
    : _storage = localStorage ?? NoteLocalStorage();

  final NoteLocalStorage _storage;

  @override
  Future<List<Note>> getNotes() async {
    final rows = await _storage.allNotes();
    return rows.map((r) => r.toNote()).toList();
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final row = await _storage.noteById(id);
    return row?.toNote();
  }

  @override
  Future<Note> createNote({
    String? title,
    required String content,
    NoteColor color = NoteColor.none,
  }) async {
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();

    await _storage.insertNote(
      NotesTableCompanion.insert(
        id: id,
        title: Value(title),
        content: content,
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
        color: Value(color.name),
      ),
    );

    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      color: color,
    );
  }

  @override
  Future<Note> updateNote(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());

    await _storage.updateNote(
      NotesTableCompanion(
        id: Value(updated.id),
        title: Value(updated.title),
        content: Value(updated.content),
        updatedAt: Value(updated.updatedAt.toIso8601String()),
        isPinned: Value(updated.isPinned),
        color: Value(updated.color.name),
      ),
    );

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
