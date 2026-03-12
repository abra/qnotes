import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart' show Uuid;

import 'note_local_storage.dart';
import 'note_local_storage_exception.dart';

const _uuid = Uuid();

/// Concrete implementation of [NoteRepository] backed by SQLite via drift.
class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl({@visibleForTesting NoteLocalStorage? localStorage})
    : _storage = localStorage ?? NoteLocalStorage();

  final NoteLocalStorage _storage;

  @override
  Future<List<Note>> getNotes() async {
    try {
      return await _storage.allNotes();
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
  }

  @override
  Future<Note?> getNoteById(String id) async {
    try {
      return await _storage.noteById(id);
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
  }

  @override
  Future<Note> createNote({
    String? title,
    required String content,
    NoteColor color = NoteColor.none,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      color: color,
    );
    try {
      await _storage.insertNote(note);
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
    return note;
  }

  @override
  Future<Note> updateNote(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    try {
      await _storage.updateNote(updated);
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
    return updated;
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await _storage.deleteNote(id);
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
  }

  @override
  Future<NoteColor?> getLastCreatedNoteColor() async {
    try {
      final raw = await _storage.lastCreatedNoteColor();
      if (raw == null) return null;
      final color = NoteColor.from(raw);
      return color == NoteColor.none ? null : color;
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
  }
}
