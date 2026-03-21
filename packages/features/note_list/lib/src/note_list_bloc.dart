import 'package:bloc_concurrency/bloc_concurrency.dart' show restartable;
import 'package:equatable/equatable.dart' show Equatable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_files/image_files.dart';
import 'package:note_repository/note_repository.dart';
import 'package:preferences_service/preferences_service.dart';
import 'package:shared/shared.dart';

part 'note_list_event.dart';

part 'note_list_state.dart';

class NoteListBloc extends Bloc<NoteListEvent, NoteListState> {
  NoteListBloc({
    required NoteRepository noteRepository,
    required PreferencesService preferencesService,
    required ImageFiles imageFiles,
  }) : _repository = noteRepository,
       _imageFiles = imageFiles,
       _preferencesStream = preferencesService.stream,
       super(
         NoteListState(
           noteViewMode: preferencesService.current.noteViewMode,
           noteListDensity: preferencesService.current.noteListDensity,
         ),
       ) {
    on<NoteListStarted>(_onStarted, transformer: restartable());
    on<NoteListNoteDeleted>(_onNoteDeleted);
    on<NoteListNoteUpdated>(_onNoteUpdated);
    on<NoteListNoteAdded>(_onNoteAdded);
    on<NoteListNoteRemoved>(_onNoteRemoved);
    on<NoteListQueryChanged>(_onQueryChanged, transformer: restartable());
    on<NoteListSelectionToggled>(_onSelectionToggled);
    on<NoteListSelectionCleared>(_onSelectionCleared);
    on<NoteListSelectedDeleted>(_onSelectedDeleted);
    on<NoteListSelectedPinToggled>(_onSelectedPinToggled);
  }

  final NoteRepository _repository;
  final ImageFiles _imageFiles;
  final Stream<Preferences> _preferencesStream;

  Future<void> _onStarted(
    NoteListStarted event,
    Emitter<NoteListState> emit,
  ) async {
    emit(state.copyWith(status: NoteListStatus.loading));
    try {
      final notes = await _repository.getNotes();
      emit(state.copyWith(status: NoteListStatus.success, notes: notes));
    } on NoteStorageException catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: NoteListStatus.failure));
    }

    await emit.forEach<Preferences>(
      _preferencesStream,
      onData: (prefs) => state.copyWith(
        noteViewMode: prefs.noteViewMode,
        noteListDensity: prefs.noteListDensity,
      ),
    );
  }

  Future<void> _onNoteDeleted(
    NoteListNoteDeleted event,
    Emitter<NoteListState> emit,
  ) async {
    final note = state.notes.where((n) => n.id == event.id).firstOrNull;
    try {
      await _repository.deleteNote(event.id);
    } on NoteStorageException catch (e, st) {
      addError(e, st);
      emit(
        state.copyWith(
          operationFailure: (
            error: e,
            operation: NoteListFailedOperation.delete,
          ),
        ),
      );
      return;
    }
    if (note != null) {
      await _deleteUnreferencedImages(note.content);
    }
    final notes = state.notes.where((n) => n.id != event.id).toList();
    emit(state.copyWith(notes: notes, operationFailure: null));
  }

  void _onNoteUpdated(NoteListNoteUpdated event, Emitter<NoteListState> emit) {
    final notes = [
      for (final n in state.notes)
        if (n.id == event.note.id) event.note else n,
    ];
    _sortNotes(notes);
    emit(state.copyWith(notes: notes));
  }

  void _onNoteAdded(NoteListNoteAdded event, Emitter<NoteListState> emit) {
    final notes = [...state.notes, event.note];
    _sortNotes(notes);
    emit(state.copyWith(notes: notes));
  }

  void _onNoteRemoved(NoteListNoteRemoved event, Emitter<NoteListState> emit) {
    final notes = state.notes.where((n) => n.id != event.id).toList();
    emit(state.copyWith(notes: notes));
  }

  Future<void> _onSelectedPinToggled(
    NoteListSelectedPinToggled event,
    Emitter<NoteListState> emit,
  ) async {
    final ids = state.selectedIds;
    final selected = state.notes.where((n) => ids.contains(n.id)).toList();
    final toggled = selected
        .map((n) => n.copyWith(isPinned: !n.isPinned))
        .toList();
    List<Note> updated;
    try {
      updated = await _repository.updateNotes(toggled);
    } on NoteStorageException catch (e, st) {
      addError(e, st);
      emit(
        state.copyWith(
          operationFailure: (
            error: e,
            operation: NoteListFailedOperation.update,
          ),
        ),
      );
      return;
    }
    final updatedMap = {for (final n in updated) n.id: n};
    final notes = [
      for (final n in state.notes)
        if (updatedMap.containsKey(n.id)) updatedMap[n.id]! else n,
    ];
    _sortNotes(notes);
    emit(state.copyWith(notes: notes, selectedIds: {}));
  }

  static void _sortNotes(List<Note> notes) {
    notes.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
  }

  Future<void> _onQueryChanged(
    NoteListQueryChanged event,
    Emitter<NoteListState> emit,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emit(state.copyWith(query: event.query));
  }

  void _onSelectionToggled(
    NoteListSelectionToggled event,
    Emitter<NoteListState> emit,
  ) {
    final ids = Set<String>.of(state.selectedIds);
    if (ids.contains(event.id)) {
      ids.remove(event.id);
    } else {
      ids.add(event.id);
    }
    emit(state.copyWith(selectedIds: ids));
  }

  void _onSelectionCleared(
    NoteListSelectionCleared event,
    Emitter<NoteListState> emit,
  ) {
    emit(state.copyWith(selectedIds: {}));
  }

  Future<void> _onSelectedDeleted(
    NoteListSelectedDeleted event,
    Emitter<NoteListState> emit,
  ) async {
    final ids = Set<String>.of(state.selectedIds);
    final toDelete = state.notes.where((n) => ids.contains(n.id)).toList();
    try {
      await _repository.deleteNotes(ids.toList());
    } on NoteStorageException catch (e, st) {
      addError(e, st);
      emit(
        state.copyWith(
          operationFailure: (
            error: e,
            operation: NoteListFailedOperation.delete,
          ),
        ),
      );
      return;
    }
    for (final n in toDelete) {
      await _deleteUnreferencedImages(n.content);
    }
    final notes = state.notes.where((n) => !ids.contains(n.id)).toList();
    emit(state.copyWith(notes: notes, selectedIds: {}, operationFailure: null));
  }

  /// Deletes image files from [content] only if no other note references them.
  Future<void> _deleteUnreferencedImages(String content) async {
    for (final path in DeltaUtils.allImagePaths(content)) {
      try {
        if (!await _repository.isImageReferenced(path)) {
          await _imageFiles.deleteImage(path);
        }
      } catch (e, st) {
        addError(e, st);
      }
    }
  }
}
