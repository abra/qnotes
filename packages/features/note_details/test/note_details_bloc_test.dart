import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_files/image_files.dart';
import 'package:note_details/src/note_details_bloc.dart';
import 'package:shared/shared.dart';

import 'helpers/fake_image_files.dart';
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
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: true,
        ),
        act: (bloc) => bloc.add(NoteDetailsStarted(noteId: null)),
        verify: (bloc) {
          expect(bloc.state.color, isNot(NoteColor.none));
        },
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits loading then success for existing note',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(notes: [_existingNote]),
          imageFiles: FakeImageFiles(),
          isNew: false,
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
            originalContent: 'Some content',
          ),
        ],
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits failure when note not found',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: false,
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
          return NoteDetailsBloc(
            noteRepository: r,
            imageFiles: FakeImageFiles(),
            isNew: false,
          );
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
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: true,
        ),
        act: (bloc) => bloc.add(NoteDetailsTitleChanged('New title')),
        expect: () => [const NoteDetailsState(title: 'New title')],
      );
    });

    group('NoteDetailsContentChanged', () {
      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'updates content in state',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: true,
        ),
        act: (bloc) => bloc.add(NoteDetailsContentChanged('New content')),
        expect: () => [const NoteDetailsState(content: 'New content')],
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'clears insertedImagePath (one-shot consumption)',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: true,
        ),
        seed: () => const NoteDetailsState(insertedImagePath: '/img/a.jpg'),
        act: (bloc) => bloc.add(NoteDetailsContentChanged('updated')),
        verify: (bloc) {
          expect(bloc.state.insertedImagePath, isNull);
          expect(bloc.state.content, 'updated');
        },
      );
    });

    group('NoteDetailsColorChanged', () {
      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'updates color in state',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: true,
        ),
        act: (bloc) => bloc.add(NoteDetailsColorChanged(NoteColor.blue)),
        expect: () => [const NoteDetailsState(color: NoteColor.blue)],
      );
    });

    group('NoteDetailsPinToggled', () {
      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'toggles isPinned from false to true',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: true,
        ),
        act: (bloc) => bloc.add(NoteDetailsPinToggled()),
        expect: () => [const NoteDetailsState(isPinned: true)],
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'toggles isPinned from true to false',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: true,
        ),
        seed: () => const NoteDetailsState(isPinned: true),
        act: (bloc) => bloc.add(NoteDetailsPinToggled()),
        expect: () => [const NoteDetailsState(isPinned: false)],
      );
    });

    group('NoteDetailsSaved — new note', () {
      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'does nothing when both title and content are empty',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: true,
        ),
        seed: () => const NoteDetailsState(title: '   ', content: '   '),
        act: (bloc) => bloc.add(NoteDetailsSaved()),
        expect: () => <NoteDetailsState>[],
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'saves when title is present and content is empty',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: true,
        ),
        seed: () => const NoteDetailsState(title: 'T', content: '   '),
        act: (bloc) => bloc.add(NoteDetailsSaved()),
        verify: (bloc) {
          expect(bloc.state.status, NoteDetailsStatus.saved);
          expect(bloc.state.note?.title, 'T');
          expect(bloc.state.note?.content, '');
        },
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits saved with created note in state',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: true,
        ),
        seed: () => const NoteDetailsState(
          content: 'Hello world',
          title: 'My title',
        ),
        act: (bloc) => bloc.add(NoteDetailsSaved()),
        verify: (bloc) {
          expect(bloc.state.status, NoteDetailsStatus.saved);
          expect(bloc.state.isNew, isFalse);
          expect(bloc.state.note, isNotNull);
          expect(bloc.state.note!.content, 'Hello world');
          expect(bloc.state.note!.title, 'My title');
        },
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'saves Delta JSON content as-is without trimming',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: true,
        ),
        seed: () => const NoteDetailsState(
          title: 'T',
          content: '{"ops":[{"insert":"Hello\\n"}]}',
        ),
        act: (bloc) => bloc.add(NoteDetailsSaved()),
        verify: (bloc) {
          expect(bloc.state.status, NoteDetailsStatus.saved);
          expect(bloc.state.note?.content, '{"ops":[{"insert":"Hello\\n"}]}');
        },
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'does nothing when Delta content is empty',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: true,
        ),
        seed: () => const NoteDetailsState(
          content: '{"ops":[{"insert":"\\n"}]}',
        ),
        act: (bloc) => bloc.add(NoteDetailsSaved()),
        expect: () => <NoteDetailsState>[],
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits failure when createNote throws',
        build: () {
          final r = FakeNoteRepository()..shouldThrow = true;
          return NoteDetailsBloc(
            noteRepository: r,
            imageFiles: FakeImageFiles(),
            isNew: true,
          );
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
      final updatedNote = _existingNote.copyWith(
        title: 'Updated title',
        content: 'Updated content',
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits saved with updated note in state',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(notes: [_existingNote]),
          imageFiles: FakeImageFiles(),
          isNew: false,
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
            note: updatedNote,
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
          imageFiles: FakeImageFiles(),
          isNew: false,
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
          return NoteDetailsBloc(
            noteRepository: r,
            imageFiles: FakeImageFiles(),
            isNew: false,
          );
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

      test('deletes orphan images removed during editing', () async {
        final imageFiles = FakeImageFiles();
        final noteWithImage = _existingNote.copyWith(
          content:
              '{"ops":[{"insert":{"image":"/img/old.jpg"}},{"insert":"\\n"}]}',
        );
        final bloc = NoteDetailsBloc(
          noteRepository: FakeNoteRepository(notes: [noteWithImage]),
          imageFiles: imageFiles,
          isNew: false,
        );
        bloc.add(NoteDetailsStarted(noteId: noteWithImage.id));
        await bloc.stream.firstWhere(
          (s) => s.status == NoteDetailsStatus.success,
        );
        bloc.add(
          NoteDetailsContentChanged('{"ops":[{"insert":"hello\\n"}]}'),
        );
        bloc.add(NoteDetailsSaved());
        await bloc.stream.firstWhere(
          (s) => s.status == NoteDetailsStatus.saved,
        );
        expect(imageFiles.deletedPaths, contains('/img/old.jpg'));
        await bloc.close();
      });

      test(
        'emits saved even when orphan image cleanup throws (non-fatal)',
        () async {
          final noteWithImage = _existingNote.copyWith(
            content:
                '{"ops":[{"insert":{"image":"/img/old.jpg"}},{"insert":"\\n"}]}',
          );
          final bloc = NoteDetailsBloc(
            noteRepository: FakeNoteRepository(notes: [noteWithImage]),
            imageFiles: FakeImageFiles()..shouldThrow = true,
            isNew: false,
          );
          bloc.add(NoteDetailsStarted(noteId: noteWithImage.id));
          await bloc.stream.firstWhere(
            (s) => s.status == NoteDetailsStatus.success,
          );
          bloc.add(
            NoteDetailsContentChanged('{"ops":[{"insert":"hello\\n"}]}'),
          );
          bloc.add(NoteDetailsSaved());
          await bloc.stream.firstWhere(
            (s) =>
                s.status == NoteDetailsStatus.saved ||
                s.status == NoteDetailsStatus.failure,
          );
          expect(bloc.state.status, NoteDetailsStatus.saved);
          await bloc.close();
        },
      );
    });

    group('NoteDetailsImageInserted', () {
      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits insertedImagePath on success',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: true,
        ),
        act: (bloc) => bloc.add(NoteDetailsImageInserted('/tmp/photo.jpg')),
        verify: (bloc) {
          expect(bloc.state.insertedImagePath, '/tmp/photo.jpg');
          expect(bloc.state.imageInsertError, isNull);
        },
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits imageInsertError and no insertedImagePath when saveImage throws',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles()..saveShouldThrow = true,
          isNew: true,
        ),
        act: (bloc) => bloc.add(NoteDetailsImageInserted('/tmp/photo.jpg')),
        verify: (bloc) {
          expect(bloc.state.imageInsertError, isA<ImageFilesException>());
          expect(bloc.state.insertedImagePath, isNull);
          expect(bloc.state.status, NoteDetailsStatus.initial);
        },
      );
    });

    group('NoteDetailsDeleteRequested', () {
      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits deleted when note exists in state',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(notes: [_existingNote]),
          imageFiles: FakeImageFiles(),
          isNew: false,
        ),
        seed: () => NoteDetailsState(isNew: false, note: _existingNote),
        act: (bloc) => bloc.add(NoteDetailsDeleteRequested()),
        expect: () => [
          NoteDetailsState(
            isNew: false,
            note: _existingNote,
            status: NoteDetailsStatus.deleted,
          ),
        ],
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'does nothing when note is null in state',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: true,
        ),
        seed: () => const NoteDetailsState(isNew: false),
        act: (bloc) => bloc.add(NoteDetailsDeleteRequested()),
        expect: () => <NoteDetailsState>[],
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits failure when deleteNote throws',
        build: () {
          final r = FakeNoteRepository(notes: [_existingNote])
            ..shouldThrow = true;
          return NoteDetailsBloc(
            noteRepository: r,
            imageFiles: FakeImageFiles(),
            isNew: false,
          );
        },
        seed: () => NoteDetailsState(isNew: false, note: _existingNote),
        act: (bloc) => bloc.add(NoteDetailsDeleteRequested()),
        verify: (bloc) {
          expect(bloc.state.status, NoteDetailsStatus.failure);
          expect(bloc.state.saveError, isA<NoteStorageException>());
        },
      );

      blocTest<NoteDetailsBloc, NoteDetailsState>(
        'emits deleted even when image cleanup throws (non-fatal)',
        build: () => NoteDetailsBloc(
          noteRepository: FakeNoteRepository(notes: [_existingNote]),
          imageFiles: FakeImageFiles()..shouldThrow = true,
          isNew: false,
        ),
        seed: () => NoteDetailsState(isNew: false, note: _existingNote),
        act: (bloc) => bloc.add(NoteDetailsDeleteRequested()),
        verify: (bloc) {
          expect(bloc.state.status, NoteDetailsStatus.deleted);
        },
      );
    });
  });
}
