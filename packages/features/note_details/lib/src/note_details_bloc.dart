import 'dart:math' show Random;

import 'package:equatable/equatable.dart' show Equatable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_service/image_service.dart';
import 'package:note_repository/note_repository.dart';
import 'package:shared/shared.dart';

part 'note_details_event.dart';
part 'note_details_state.dart';

class NoteDetailsBloc extends Bloc<NoteDetailsEvent, NoteDetailsState> {
  NoteDetailsBloc({
    required NoteRepository noteRepository,
    required ImageService imageService,
    required bool isNew,
  }) : _repository = noteRepository,
       _imageService = imageService,
       super(NoteDetailsState(isNew: isNew)) {
    on<NoteDetailsStarted>(_onStarted);
    on<NoteDetailsTitleChanged>(_onTitleChanged);
    on<NoteDetailsContentChanged>(_onContentChanged);
    on<NoteDetailsColorChanged>(_onColorChanged);
    on<NoteDetailsPinToggled>(_onPinToggled);
    on<NoteDetailsSaved>(_onSaved);
    on<NoteDetailsDeleteRequested>(_onDeleteRequested);
  }

  final NoteRepository _repository;
  final ImageService _imageService;

  static final _random = Random();

  static final _colorChoices = NoteColor.values
      .where((c) => c != NoteColor.none)
      .toList();

  NoteColor _pickColor(NoteColor? last) {
    final candidates = last == null
        ? _colorChoices
        : _colorChoices.where((c) => c != last).toList();
    return candidates[_random.nextInt(candidates.length)];
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
      if (note == null) throw NoteNotFoundException(event.noteId!);
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
    } on NoteNotFoundException catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: NoteDetailsStatus.failure, loadError: e));
    } on NoteStorageException catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: NoteDetailsStatus.failure, loadError: e));
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

  Future<void> _onDeleteRequested(
    NoteDetailsDeleteRequested event,
    Emitter<NoteDetailsState> emit,
  ) async {
    final note = state.note;
    if (note == null) return;
    try {
      await _repository.deleteNote(note.id);
      await _imageService.deleteImagesFromContent(note.content);
      emit(state.copyWith(status: NoteDetailsStatus.deleted));
    } on NoteStorageException catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: NoteDetailsStatus.failure, saveError: e));
    }
  }

  Future<void> _onSaved(
    NoteDetailsSaved event,
    Emitter<NoteDetailsState> emit,
  ) async {
    if (state.content.trim().isEmpty && state.title.trim().isEmpty) return;

    emit(state.copyWith(status: NoteDetailsStatus.saving));
    try {
      Note saved;
      if (state.isNew) {
        saved = await _repository.createNote(
          title: state.title.trim().isEmpty ? null : state.title.trim(),
          content: state.content.trim(),
          color: state.color,
        );
      } else {
        final note = state.note;
        if (note == null) {
          emit(
            state.copyWith(
              status: NoteDetailsStatus.failure,
              saveError: StateError(
                'Cannot update note: note is null in state',
              ),
            ),
          );
          return;
        }
        saved = await _repository.updateNote(
          note.copyWith(
            title: state.title.trim().isEmpty ? null : state.title.trim(),
            content: state.content.trim(),
            color: state.color,
            isPinned: state.isPinned,
          ),
        );
      }
      emit(
        state.copyWith(
          status: NoteDetailsStatus.saved,
          note: saved,
          isNew: false,
        ),
      );
    } on NoteStorageException catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: NoteDetailsStatus.failure, saveError: e));
    }
  }
}
