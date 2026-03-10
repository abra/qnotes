// Domain models, interfaces, and value objects shared across features.
//
// Features import this package to access common types without depending
// on each other. Concrete implementations are wired in composition.dart.
//
// Structure:
//   models/      — domain entities (Note, User, ...)
//   interfaces/  — repository and service abstractions
//   value_objects/ — typed wrappers (NoteId, Email, ...)

export 'src/exceptions/note_not_found_exception.dart';
export 'src/exceptions/note_storage_exception.dart';
export 'src/interfaces/note_repository.dart';
export 'src/models/note.dart';
export 'src/models/note_color.dart';
export 'src/models/note_list_density.dart';
export 'src/models/note_view_mode.dart';
