import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_details/src/note_details_bloc.dart';
import 'package:shared/shared.dart';

import 'helpers/fake_note_repository.dart';

final _existingNote = Note(
  id: '42',
  title: 'My note',
  content: 'Some content',
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
  isPinned: false,
  color: NoteColor.none,
);

void main() {
  group('NoteDetailsBloc', () {
    group('NoteDetailsStarted', () {
      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits state with auto-picked color for new note',
        build: () =>
            NoteDetailsBloc(noteRepository: FakeNoteRepository(), noteId: null),
        act: (bloc) => bloc.add(NoteDetailsStarted(noteId: null)),
        verify: (bloc) {
          expect(bloc.state.color, isNot(NoteColor.none));
        },
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits loading then success for existing note',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(notes: [_existingNote]),
          noteId: '42',
        ),
        act: (bloc) => bloc.add(NoteDetailsStarted(noteId: '42')),
        expect: () => [
          NoteDetailsState(isNew: false, status: NoteDetailsStatus.loading),
          NoteDetailsState(
            isNew: false,
            status: NoteDetailsStatus.success,
            note: _existingNote,
            title: 'My note',
            content: 'Some content',
          ),
        ],
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits failure when note not found',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          noteId: 'missing',
        ),
        act: (bloc) => bloc.add(NoteDetailsStarted(noteId: 'missing')),
        verify: (bloc) {
          expect(bloc.state.status, NoteDetailsStatus.failure);
          expect(bloc.state.loadError, isA<NoteNotFoundException>());
        },
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits failure on repository exception',
        build: () {
          final r = FakeNoteRepository()..shouldThrow = true;
          return NoteDetailsBloc(noteRepository: r, noteId: '99');
        },
        act: (bloc) => bloc.add(NoteDetailsStarted(noteId: '99')),
        verify: (bloc) {
          expect(bloc.state.status, NoteDetailsStatus.failure);
          expect(bloc.state.loadError, isA<NoteStorageException>());
        },
      );
    });

    group('NoteDetailsTitleChanged', () {
      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'updates title in state',
        build: () =>
            NoteDetailsBloc(noteRepository: FakeNoteRepository(), noteId: null),
        act: (bloc) => bloc.add(NoteDetailsTitleChanged('New title')),
        expect: () => [const NoteDetailsState(title: 'New title')],
      );
    });

    group('NoteDetailsContentChanged', () {
      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'updates content in state',
        build: () =>
            NoteDetailsBloc(noteRepository: FakeNoteRepository(), noteId: null),
        act: (bloc) => bloc.add(NoteDetailsContentChanged('New content')),
        expect: () => [const NoteDetailsState(content: 'New content')],
      );
    });

    group('NoteDetailsColorChanged', () {
      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'updates color in state',
        build: () =>
            NoteDetailsBloc(noteRepository: FakeNoteRepository(), noteId: null),
        act: (bloc) => bloc.add(NoteDetailsColorChanged(NoteColor.blue)),
        expect: () => [const NoteDetailsState(color: NoteColor.blue)],
      );
    });

    group('NoteDetailsPinToggled', () {
      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'toggles isPinned from false to true',
        build: () =>
            NoteDetailsBloc(noteRepository: FakeNoteRepository(), noteId: null),
        act: (bloc) => bloc.add(NoteDetailsPinToggled()),
        expect: () => [const NoteDetailsState(isPinned: true)],
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'toggles isPinned from true to false',
        build: () =>
            NoteDetailsBloc(noteRepository: FakeNoteRepository(), noteId: null),
        seed: () => const NoteDetailsState(isPinned: true),
        act: (bloc) => bloc.add(NoteDetailsPinToggled()),
        expect: () => [const NoteDetailsState(isPinned: false)],
      );
    });

    group('NoteDetailsSaved — new note', () {
      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'does nothing when content is empty',
        build: () =>
            NoteDetailsBloc(noteRepository: FakeNoteRepository(), noteId: null),
        seed: () => const NoteDetailsState(title: 'T', content: '   '),
        act: (bloc) => bloc.add(NoteDetailsSaved()),
        expect: () => <NoteDetailsState>[],
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits saving then saved for new note',
        build: () =>
            NoteDetailsBloc(noteRepository: FakeNoteRepository(), noteId: null),
        seed: () =>
            const NoteDetailsState(content: 'Hello world', title: 'My title'),
        act: (bloc) => bloc.add(NoteDetailsSaved()),
        expect: () => [
          const NoteDetailsState(
            status: NoteDetailsStatus.saving,
            content: 'Hello world',
            title: 'My title',
          ),
          const NoteDetailsState(
            status: NoteDetailsStatus.saved,
            content: 'Hello world',
            title: 'My title',
          ),
        ],
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits failure when createNote throws',
        build: () {
          final r = FakeNoteRepository()..shouldThrow = true;
          return NoteDetailsBloc(noteRepository: r, noteId: null);
        },
        seed: () => const NoteDetailsState(content: 'content'),
        act: (bloc) => bloc.add(NoteDetailsSaved()),
        verify: (bloc) {
          expect(bloc.state.status, NoteDetailsStatus.failure);
          expect(bloc.state.saveError, isA<NoteStorageException>());
        },
      );
    });

    group('NoteDetailsSaved — existing note', () {
      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits saving then saved for existing note',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(notes: [_existingNote]),
          noteId: '42',
        ),
        seed: () => NoteDetailsState(
          isNew: false,
          note: _existingNote,
          status: NoteDetailsStatus.success,
          title: 'Updated title',
          content: 'Updated content',
        ),
        act: (bloc) => bloc.add(NoteDetailsSaved()),
        expect: () => [
          NoteDetailsState(
            isNew: false,
            note: _existingNote,
            status: NoteDetailsStatus.saving,
            title: 'Updated title',
            content: 'Updated content',
          ),
          NoteDetailsState(
            isNew: false,
            note: _existingNote,
            status: NoteDetailsStatus.saved,
            title: 'Updated title',
            content: 'Updated content',
          ),
        ],
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits failure when state.note is null for existing note',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(notes: [_existingNote]),
          noteId: '42',
        ),
        seed: () => const NoteDetailsState(
          isNew: false,
          status: NoteDetailsStatus.success,
          content: 'Some content',
        ),
        act: (bloc) => bloc.add(NoteDetailsSaved()),
        verify: (bloc) {
          expect(bloc.state.status, NoteDetailsStatus.failure);
          expect(bloc.state.saveError, isA<StateError>());
        },
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits failure when updateNote throws',
        build: () {
          final r = FakeNoteRepository(notes: [_existingNote])
            ..shouldThrow = true;
          return NoteDetailsBloc(noteRepository: r, noteId: '42');
        },
        seed: () => NoteDetailsState(
          isNew: false,
          note: _existingNote,
          status: NoteDetailsStatus.success,
          title: 'T',
          content: 'C',
        ),
        act: (bloc) => bloc.add(NoteDetailsSaved()),
        verify: (bloc) {
          expect(bloc.state.status, NoteDetailsStatus.failure);
          expect(bloc.state.saveError, isA<NoteStorageException>());
        },
      );
    });
  });
}
