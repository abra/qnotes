import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:note_list/src/note_list_bloc.dart';
import 'package:preferences_service/preferences_service.dart';
import 'package:shared/shared.dart';

import 'helpers/fake_image_service.dart';
import 'helpers/fake_note_repository.dart';

class _MockPreferencesService extends Mock implements PreferencesService {}

Note _note(
  String id, {
  String? title,
  String content = 'body',
  bool isPinned = false,
  DateTime? createdAt,
}) => Note(
  id: id,
  title: title,
  content: content,
  isPinned: isPinned,
  createdAt: createdAt ?? DateTime(2024),
  updatedAt: DateTime(2024),
);

void main() {
  group('NoteListBloc', () {
    late FakeNoteRepository repo;
    late _MockPreferencesService mockPrefs;
    late StreamController<Preferences> prefsController;

    setUp(() {
      repo = FakeNoteRepository();
      mockPrefs = _MockPreferencesService();
      prefsController = StreamController<Preferences>.broadcast();
      when(() => mockPrefs.current).thenReturn(const Preferences());
      when(() => mockPrefs.stream).thenAnswer((_) => prefsController.stream);
    });

    tearDown(() => prefsController.close());

    test('initial state', () {
      final bloc = NoteListBloc(
        noteRepository: repo,
        preferencesService: mockPrefs,
        imageService: FakeImageService(),
      );
      expect(bloc.state, const NoteListState());
    });

    group('NoteListStarted', () {
      final notes = [_note('1'), _note('2')];

      blocTest<NoteListBloc, NoteListState>(
        'emits loading then success with notes',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: notes),
          preferencesService: mockPrefs,
          imageService: FakeImageService(),
        ),
        act: (bloc) => bloc.add(NoteListStarted()),
        expect: () => [
          const NoteListState(status: NoteListStatus.loading),
          NoteListState(status: NoteListStatus.success, notes: notes),
        ],
      );

      blocTest<NoteListBloc, NoteListState>(
        'emits loading then failure on exception',
        build: () {
          final r = FakeNoteRepository()..shouldThrow = true;
          return NoteListBloc(
            noteRepository: r,
            preferencesService: mockPrefs,
            imageService: FakeImageService(),
          );
        },
        act: (bloc) => bloc.add(NoteListStarted()),
        expect: () => [
          const NoteListState(status: NoteListStatus.loading),
          const NoteListState(status: NoteListStatus.failure),
        ],
      );

      blocTest<NoteListBloc, NoteListState>(
        'emits success with empty list when no notes',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(),
          preferencesService: mockPrefs,
          imageService: FakeImageService(),
        ),
        act: (bloc) => bloc.add(NoteListStarted()),
        expect: () => [
          const NoteListState(status: NoteListStatus.loading),
          const NoteListState(status: NoteListStatus.success),
        ],
      );
    });

    group('NoteListNoteDeleted', () {
      final notes = [_note('1'), _note('2'), _note('3')];

      blocTest<NoteListBloc, NoteListState>(
        'removes note from state',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: List.of(notes)),
          preferencesService: mockPrefs,
          imageService: FakeImageService(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
        ),
        act: (bloc) => bloc.add(NoteListNoteDeleted('2')),
        expect: () => [
          NoteListState(
            status: NoteListStatus.success,
            notes: [_note('1'), _note('3')],
          ),
        ],
      );

      blocTest<NoteListBloc, NoteListState>(
        'clears deleteError on success',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: List.of(notes)),
          preferencesService: mockPrefs,
          imageService: FakeImageService(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
          deleteError: const NoteStorageException(cause: 'previous error'),
        ),
        act: (bloc) => bloc.add(NoteListNoteDeleted('1')),
        verify: (bloc) => expect(bloc.state.deleteError, isNull),
      );
    });

    group('NoteListNoteUpdated', () {
      final notes = [_note('1'), _note('2'), _note('3')];

      blocTest<NoteListBloc, NoteListState>(
        'replaces note with matching id',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageService: FakeImageService(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
        ),
        act: (bloc) =>
            bloc.add(NoteListNoteUpdated(_note('2', content: 'updated'))),
        expect: () => [
          NoteListState(
            status: NoteListStatus.success,
            notes: [
              _note('1'),
              _note('2', content: 'updated'),
              _note('3'),
            ],
          ),
        ],
      );

      blocTest<NoteListBloc, NoteListState>(
        'moves pinned note to top after update',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageService: FakeImageService(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: [_note('1'), _note('2')],
        ),
        act: (bloc) =>
            bloc.add(NoteListNoteUpdated(_note('2', isPinned: true))),
        verify: (bloc) => expect(bloc.state.notes.first.id, '2'),
      );

      blocTest<NoteListBloc, NoteListState>(
        'sorts by createdAt when both unpinned',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageService: FakeImageService(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: [
            _note('1', createdAt: DateTime(2024, 1, 1)),
            _note('2', createdAt: DateTime(2024, 1, 2)),
          ],
        ),
        act: (bloc) => bloc.add(
          NoteListNoteUpdated(_note('1', createdAt: DateTime(2024, 1, 3))),
        ),
        verify: (bloc) => expect(bloc.state.notes.first.id, '1'),
      );
    });

    group('NoteListNoteAdded', () {
      blocTest<NoteListBloc, NoteListState>(
        'adds note to list',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageService: FakeImageService(),
        ),
        seed: () =>
            NoteListState(status: NoteListStatus.success, notes: [_note('1')]),
        act: (bloc) => bloc.add(NoteListNoteAdded(_note('2'))),
        verify: (bloc) {
          expect(bloc.state.notes, hasLength(2));
          expect(bloc.state.notes.any((n) => n.id == '2'), isTrue);
        },
      );

      blocTest<NoteListBloc, NoteListState>(
        'places pinned note at top',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageService: FakeImageService(),
        ),
        seed: () =>
            NoteListState(status: NoteListStatus.success, notes: [_note('1')]),
        act: (bloc) => bloc.add(NoteListNoteAdded(_note('2', isPinned: true))),
        verify: (bloc) => expect(bloc.state.notes.first.id, '2'),
      );
    });

    group('NoteListNoteRemoved', () {
      final notes = [_note('1'), _note('2'), _note('3')];

      blocTest<NoteListBloc, NoteListState>(
        'removes note from list',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageService: FakeImageService(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
        ),
        act: (bloc) => bloc.add(NoteListNoteRemoved('2')),
        expect: () => [
          NoteListState(
            status: NoteListStatus.success,
            notes: [_note('1'), _note('3')],
          ),
        ],
      );

      blocTest<NoteListBloc, NoteListState>(
        'ignores unknown id',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageService: FakeImageService(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
        ),
        act: (bloc) => bloc.add(NoteListNoteRemoved('999')),
        verify: (bloc) => expect(bloc.state.notes, hasLength(3)),
      );
    });

    group('NoteListQueryChanged', () {
      blocTest<NoteListBloc, NoteListState>(
        'updates query in state',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageService: FakeImageService(),
        ),
        act: (bloc) => bloc.add(NoteListQueryChanged('hello')),
        wait: const Duration(milliseconds: 350),
        expect: () => [const NoteListState(query: 'hello')],
      );
    });

    group('filteredNotes', () {
      final notes = [
        _note('1', title: 'Flutter tips', content: 'Dart stuff'),
        _note('2', title: 'Shopping list', content: 'milk, eggs'),
        _note('3', title: null, content: 'buy groceries'),
      ];

      test('returns all notes when query is empty', () {
        final state = NoteListState(
          status: NoteListStatus.success,
          notes: notes,
        );
        expect(state.filteredNotes, notes);
      });

      test('filters by title', () {
        final state = NoteListState(
          status: NoteListStatus.success,
          notes: notes,
          query: 'flutter',
        );
        expect(state.filteredNotes, [notes[0]]);
      });

      test('filters by content', () {
        final state = NoteListState(
          status: NoteListStatus.success,
          notes: notes,
          query: 'milk',
        );
        expect(state.filteredNotes, [notes[1]]);
      });

      test('is case insensitive', () {
        final state = NoteListState(
          status: NoteListStatus.success,
          notes: notes,
          query: 'GROCERIES',
        );
        expect(state.filteredNotes, [notes[2]]);
      });

      test('returns empty list when no match', () {
        final state = NoteListState(
          status: NoteListStatus.success,
          notes: notes,
          query: 'zzz',
        );
        expect(state.filteredNotes, isEmpty);
      });
    });
  });
}
