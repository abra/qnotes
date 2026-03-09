part of 'note_list_bloc.dart';

enum NoteListStatus { initial, loading, success, failure }

class NoteListState extends Equatable {
  const NoteListState({
    this.status = NoteListStatus.initial,
    this.notes = const [],
    this.query = '',
    this.selectedIds = const {},
  });

  final NoteListStatus status;
  final List<Note> notes;
  final String query;
  final Set<String> selectedIds;

  bool get isSelectionMode => selectedIds.isNotEmpty;

  List<Note> get filteredNotes {
    if (query.isEmpty) return notes;
    final q = query.toLowerCase();
    return notes
        .where(
          (n) =>
              (n.title?.toLowerCase().contains(q) ?? false) ||
              n.content.toLowerCase().contains(q),
        )
        .toList();
  }

  NoteListState copyWith({
    NoteListStatus? status,
    List<Note>? notes,
    String? query,
    Set<String>? selectedIds,
  }) => NoteListState(
    status: status ?? this.status,
    notes: notes ?? this.notes,
    query: query ?? this.query,
    selectedIds: selectedIds ?? this.selectedIds,
  );

  @override
  List<Object?> get props => [status, notes, query, selectedIds];

  @override
  String toString() =>
      'NoteListState(status: $status, notes: ${notes.length}, '
      'query: "$query", selected: ${selectedIds.length})';
}
