import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_repository/note_repository.dart';
import 'package:shared/shared.dart';

NoteLocalStorage _openInMemory() =>
    NoteLocalStorage.forTesting(NativeDatabase.memory());

Note _note({
  String id = '1',
  String content = 'hello',
  String? title,
  DateTime? createdAt,
  DateTime? updatedAt,
  bool isPinned = false,
  NoteColor color = NoteColor.none,
}) {
  final now = DateTime(2024);
  return Note(
    id: id,
    title: title,
    content: content,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
    isPinned: isPinned,
    color: color,
  );
}

void main() {
  group('NoteLocalStorage', () {
    late NoteLocalStorage storage;

    setUp(() => storage = _openInMemory());
    tearDown(() => storage.close());

    test('allNotes returns empty list initially', () async {
      expect(await storage.allNotes(), isEmpty);
    });

    test('insertNote then allNotes returns one note', () async {
      await storage.insertNote(_note(content: 'hello'));

      final notes = await storage.allNotes();
      expect(notes, hasLength(1));
      expect(notes.first.content, 'hello');
    });

    test('noteById returns null for missing id', () async {
      expect(await storage.noteById('999'), isNull);
    });

    test('noteById returns correct note', () async {
      await storage.insertNote(_note(id: '42', content: 'find me'));

      final note = await storage.noteById('42');
      expect(note?.content, 'find me');
    });

    test('updateNote persists changes', () async {
      await storage.insertNote(_note(id: '1', content: 'original'));
      await storage.updateNote(
        _note(id: '1', content: 'updated', updatedAt: DateTime(2025)),
      );

      final note = await storage.noteById('1');
      expect(note?.content, 'updated');
    });

    test('deleteNote removes the note', () async {
      await storage.insertNote(_note(id: '1', content: 'to delete'));
      await storage.deleteNote('1');

      expect(await storage.allNotes(), isEmpty);
    });
  });

  group('NoteRepository', () {
    late NoteLocalStorage storage;
    late NoteRepository repo;

    setUp(() {
      storage = _openInMemory();
      repo = NoteRepository(localStorage: storage);
    });
    tearDown(() => storage.close());

    test('getNotes returns empty list initially', () async {
      expect(await repo.getNotes(), isEmpty);
    });

    test('createNote returns note with correct fields', () async {
      final note = await repo.createNote(
        title: 'My Title',
        content: 'My Content',
        color: NoteColor.blue,
      );

      expect(note.title, 'My Title');
      expect(note.content, 'My Content');
      expect(note.color, NoteColor.blue);
      expect(note.isPinned, isFalse);
    });

    test('createNote persists to storage', () async {
      await repo.createNote(content: 'persisted');
      expect(await repo.getNotes(), hasLength(1));
    });

    test('getNoteById returns created note', () async {
      final created = await repo.createNote(content: 'lookup me');
      final found = await repo.getNoteById(created.id);

      expect(found, isNotNull);
      expect(found!.content, 'lookup me');
    });

    test('getNoteById returns null for missing id', () async {
      expect(await repo.getNoteById('nonexistent'), isNull);
    });

    test('updateNote persists changes', () async {
      final note = await repo.createNote(content: 'original');
      final updated = await repo.updateNote(
        note.copyWith(content: 'updated', isPinned: true),
      );

      expect(updated.content, 'updated');
      expect(updated.isPinned, isTrue);

      final fetched = await repo.getNoteById(note.id);
      expect(fetched?.content, 'updated');
      expect(fetched?.isPinned, isTrue);
    });

    test('deleteNote removes the note', () async {
      final note = await repo.createNote(content: 'delete me');
      await repo.deleteNote(note.id);

      expect(await repo.getNoteById(note.id), isNull);
      expect(await repo.getNotes(), isEmpty);
    });

    test('getNotes orders pinned notes first', () async {
      await repo.createNote(content: 'normal');
      final pinned = await repo.createNote(content: 'pinned');
      await repo.updateNote(pinned.copyWith(isPinned: true));

      final notes = await repo.getNotes();
      expect(notes.first.isPinned, isTrue);
    });
  });
}
