import 'package:shared/shared.dart';

import '../note_local_storage.dart';

extension NotesTableDataToDomain on NotesTableData {
  Note toDomainModel() => Note(
    id: id,
    title: title,
    content: content,
    createdAt: DateTime.parse(createdAt),
    updatedAt: DateTime.parse(updatedAt),
    isPinned: isPinned,
    color: NoteColor.from(color),
  );
}
