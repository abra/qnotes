/// Thrown when a storage operation fails unexpectedly.
class NoteStorageException implements Exception {
  const NoteStorageException({this.cause});

  final Object? cause;

  @override
  String toString() => 'NoteStorageException: $cause';
}
