part of 'note_list_bloc.dart';

enum NoteListStatus { initial, loading, success, failure }

enum NoteListFailedOperation { delete, update }

const Object _kOperationFailureAbsent = Object();

class NoteListState extends Equatable {
  const NoteListState({
    this.status = NoteListStatus.initial,
    this.notes = const [],
    this.query = '',
    this.selectedIds = const {},
    this.operationFailure,
    this.noteViewMode = NoteViewMode.grid,
    this.noteListDensity = NoteListDensity.threeLines,
  });

  final NoteListStatus status;
  final List<Note> notes;
  final String query;
  final Set<String> selectedIds;
  final ({Object error, NoteListFailedOperation operation})? operationFailure;
  final NoteViewMode noteViewMode;
  final NoteListDensity noteListDensity;

  bool get isSelectionMode => selectedIds.isNotEmpty;

  List<Note> get filteredNotes {
    if (query.isEmpty) return notes;
    final q = query.toLowerCase();
    return notes
        .where(
          (n) =>
              (n.title?.toLowerCase().contains(q) ?? false) ||
              DeltaUtils.toPlainText(n.content).toLowerCase().contains(q),
        )
        .toList();
  }

  NoteListState copyWith({
    NoteListStatus? status,
    List<Note>? notes,
    String? query,
    Set<String>? selectedIds,
    Object? operationFailure = _kOperationFailureAbsent,
    NoteViewMode? noteViewMode,
    NoteListDensity? noteListDensity,
  }) => NoteListState(
    status: status ?? this.status,
    notes: notes ?? this.notes,
    query: query ?? this.query,
    selectedIds: selectedIds ?? this.selectedIds,
    operationFailure: identical(operationFailure, _kOperationFailureAbsent)
        ? this.operationFailure
        : operationFailure
              as ({Object error, NoteListFailedOperation operation})?,
    noteViewMode: noteViewMode ?? this.noteViewMode,
    noteListDensity: noteListDensity ?? this.noteListDensity,
  );

  @override
  List<Object?> get props => [
    status,
    notes,
    query,
    selectedIds,
    operationFailure,
    noteViewMode,
    noteListDensity,
  ];

  @override
  String toString() =>
      'NoteListState(status: $status, notes: ${notes.length}, '
      'query: "$query", selected: ${selectedIds.length})';
}
