import 'package:drift/drift.dart';
import 'package:shared/shared.dart';

import '../note_local_storage.dart';

extension NoteToDomainStorage on Note {
  NotesTableCompanion toStorageModel() => NotesTableCompanion(
    id: Value(id),
    title: Value(title),
    content: Value(content),
    createdAt: Value(createdAt.toIso8601String()),
    updatedAt: Value(updatedAt.toIso8601String()),
    isPinned: Value(isPinned),
    color: Value(color.name),
  );
}
