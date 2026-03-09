import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

part 'note_details_event.dart';
part 'note_details_state.dart';

class NoteDetailsBloc extends Bloc<NoteDetailsEvent, NoteDetailsState> {
  NoteDetailsBloc({required NoteRepository noteRepository, String? noteId})
    : _repository = noteRepository,
      super(NoteDetailsState(isNew: noteId == null)) {
    on<NoteDetailsStarted>(_onStarted);
    on<NoteDetailsTitleChanged>(_onTitleChanged);
    on<NoteDetailsContentChanged>(_onContentChanged);
    on<NoteDetailsColorChanged>(_onColorChanged);
    on<NoteDetailsPinToggled>(_onPinToggled);
    on<NoteDetailsSaved>(_onSaved);
  }

  final NoteRepository _repository;

  static final _colorChoices = NoteColor.values
      .where((c) => c != NoteColor.none)
      .toList();

  NoteColor _pickColor(NoteColor? last) {
    final candidates = last == null
        ? _colorChoices
        : _colorChoices.where((c) => c != last).toList();
    return candidates[Random().nextInt(candidates.length)];
  }

  Future<void> _onStarted(
    NoteDetailsStarted event,
    Emitter<NoteDetailsState> emit,
  ) async {
    if (event.noteId == null) {
      final lastColor = await _repository.getLastCreatedNoteColor();
      emit(state.copyWith(color: _pickColor(lastColor)));
      return;
    }

    emit(state.copyWith(status: NoteDetailsStatus.loading));
    try {
      final note = await _repository.getNoteById(event.noteId!);
      if (note == null) {
        emit(state.copyWith(status: NoteDetailsStatus.failure));
        return;
      }
      emit(
        state.copyWith(
          status: NoteDetailsStatus.success,
          title: note.title ?? '',
          content: note.content,
          color: note.color,
          isPinned: note.isPinned,
          note: note,
        ),
      );
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: NoteDetailsStatus.failure));
    }
  }

  void _onTitleChanged(
    NoteDetailsTitleChanged event,
    Emitter<NoteDetailsState> emit,
  ) {
    emit(state.copyWith(title: event.title));
  }

  void _onContentChanged(
    NoteDetailsContentChanged event,
    Emitter<NoteDetailsState> emit,
  ) {
    emit(state.copyWith(content: event.content));
  }

  void _onColorChanged(
    NoteDetailsColorChanged event,
    Emitter<NoteDetailsState> emit,
  ) {
    emit(state.copyWith(color: event.color));
  }

  void _onPinToggled(
    NoteDetailsPinToggled event,
    Emitter<NoteDetailsState> emit,
  ) {
    emit(state.copyWith(isPinned: !state.isPinned));
  }

  Future<void> _onSaved(
    NoteDetailsSaved event,
    Emitter<NoteDetailsState> emit,
  ) async {
    if (state.content.trim().isEmpty) return;

    emit(state.copyWith(status: NoteDetailsStatus.saving));
    try {
      if (state.isNew) {
        await _repository.createNote(
          title: state.title.trim().isEmpty ? null : state.title.trim(),
          content: state.content.trim(),
          color: state.color,
        );
      } else {
        await _repository.updateNote(
          state.note!.copyWith(
            title: state.title.trim().isEmpty ? null : state.title.trim(),
            content: state.content.trim(),
            color: state.color,
            isPinned: state.isPinned,
          ),
        );
      }
      emit(state.copyWith(status: NoteDetailsStatus.saved));
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: NoteDetailsStatus.failure));
    }
  }
}
