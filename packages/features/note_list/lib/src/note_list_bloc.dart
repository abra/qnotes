import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

part 'note_list_event.dart';
part 'note_list_state.dart';

class NoteListBloc extends Bloc<NoteListEvent, NoteListState> {
  NoteListBloc({required NoteRepository noteRepository})
    : _repository = noteRepository,
      super(const NoteListState()) {
    on<NoteListStarted>(_onStarted);
    on<NoteListNoteDeleted>(_onNoteDeleted);
    on<NoteListQueryChanged>(_onQueryChanged, transformer: restartable());
    on<NoteListSelectionToggled>(_onSelectionToggled);
    on<NoteListSelectionCleared>(_onSelectionCleared);
    on<NoteListSelectedDeleted>(_onSelectedDeleted);
  }

  final NoteRepository _repository;

  Future<void> _onStarted(
    NoteListStarted event,
    Emitter<NoteListState> emit,
  ) async {
    emit(state.copyWith(status: NoteListStatus.loading));
    try {
      final notes = await _repository.getNotes();
      emit(state.copyWith(status: NoteListStatus.success, notes: notes));
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: NoteListStatus.failure));
    }
  }

  Future<void> _onNoteDeleted(
    NoteListNoteDeleted event,
    Emitter<NoteListState> emit,
  ) async {
    await _repository.deleteNote(event.id);
    final notes = state.notes.where((n) => n.id != event.id).toList();
    emit(state.copyWith(notes: notes));
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
    for (final id in ids) {
      await _repository.deleteNote(id);
    }
    final notes = state.notes.where((n) => !ids.contains(n.id)).toList();
    emit(state.copyWith(notes: notes, selectedIds: {}));
  }
}
