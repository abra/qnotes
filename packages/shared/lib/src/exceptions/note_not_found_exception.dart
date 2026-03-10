/// Thrown when a note with the given [id] is not found in storage.
class NoteNotFoundException implements Exception {
  const NoteNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'NoteNotFoundException: note with id "$id" not found';
}
