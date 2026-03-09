import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared/shared.dart';

part 'note_local_storage.g.dart';

// ---------------------------------------------------------------------------
// Table definition
// ---------------------------------------------------------------------------

class NotesTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().nullable()();
  TextColumn get content => text()();
  TextColumn get createdAt => text()(); // ISO 8601
  TextColumn get updatedAt => text()(); // ISO 8601
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  TextColumn get color => text().withDefault(const Constant('none'))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [NotesTable])
class NoteLocalStorage extends _$NoteLocalStorage {
  NoteLocalStorage() : super(_openConnection());

  @visibleForTesting
  NoteLocalStorage.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // --- queries ---

  Future<List<NotesTableData>> allNotes() =>
      (select(notesTable)..orderBy([
            (t) => OrderingTerm.desc(t.isPinned),
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
          .get();

  Future<NotesTableData?> noteById(String id) =>
      (select(notesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<String?> lastCreatedNoteColor() =>
      (select(notesTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(1))
          .map((row) => row.color)
          .getSingleOrNull();

  Future<void> insertNote(NotesTableCompanion note) =>
      into(notesTable).insert(note);

  Future<void> updateNote(NotesTableCompanion note) => (update(
    notesTable,
  )..where((t) => t.id.equals(note.id.value))).write(note);

  Future<void> deleteNote(String id) =>
      (delete(notesTable)..where((t) => t.id.equals(id))).go();
}

// ---------------------------------------------------------------------------
// Mapping helpers
// ---------------------------------------------------------------------------

extension NoteLocalStorageX on NotesTableData {
  Note toNote() => Note(
    id: id,
    title: title,
    content: content,
    createdAt: DateTime.parse(createdAt),
    updatedAt: DateTime.parse(updatedAt),
    isPinned: isPinned,
    color: NoteColor.from(color),
  );
}

// ---------------------------------------------------------------------------
// Connection
// ---------------------------------------------------------------------------

LazyDatabase _openConnection() => LazyDatabase(() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'nota.db'));
  return NativeDatabase.createInBackground(file);
});
