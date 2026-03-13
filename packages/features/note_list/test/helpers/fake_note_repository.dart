import 'package:note_repository/note_repository.dart';
import 'package:shared/shared.dart';

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({List<Note>? notes}) : _notes = notes ?? [];

  List<Note> _notes;
  bool shouldThrow = false;

  @override
  Future<List<Note>> getNotes() async {
    if (shouldThrow) throw const NoteStorageException(cause: 'getNotes failed');
    return List.of(_notes);
  }

  @override
  Future<Note?> getNoteById(String id) async {
    return _notes.where((n) => n.id == id).firstOrNull;
  }

  @override
  Future<Note> createNote({
    String? title,
    required String content,
    NoteColor color = NoteColor.none,
  }) async {
    final note = Note(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      content: content,
      color: color,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _notes.add(note);
    return note;
  }

  @override
  Future<Note> updateNote(Note note) async {
    _notes = [
      for (final n in _notes)
        if (n.id == note.id) note else n,
    ];
    return note;
  }

  @override
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
  }

  @override
  Future<NoteColor?> getLastCreatedNoteColor() async {
    if (_notes.isEmpty) return null;
    final last = _notes.reduce(
      (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
    );
    return last.color == NoteColor.none ? null : last.color;
  }
}
