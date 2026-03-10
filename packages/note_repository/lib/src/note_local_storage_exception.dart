/// Thrown by [NoteLocalStorage] when a SQLite / drift operation fails.
class NoteLocalStorageException implements Exception {
  const NoteLocalStorageException({this.cause});

  final Object? cause;

  @override
  String toString() => 'NoteLocalStorageException: $cause';
}
