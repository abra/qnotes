import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_list/src/note_list_bloc.dart';
import 'package:shared/shared.dart';

import 'helpers/fake_note_repository.dart';

Note _note(String id, {String? title, String content = 'body'}) => Note(
  id: id,
  title: title,
  content: content,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

void main() {
  group('NoteListBloc', () {
    late FakeNoteRepository repo;

    setUp(() => repo = FakeNoteRepository());

    test('initial state', () {
      final bloc = NoteListBloc(noteRepository: repo);
      expect(bloc.state, const NoteListState());
    });

    group('NoteListStarted', () {
      final notes = [_note('1'), _note('2')];

      blocTest<NoteListBloc, NoteListState>(
        'emits loading then success with notes',
        build: () =>
            NoteListBloc(noteRepository: FakeNoteRepository(notes: notes)),
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
          return NoteListBloc(noteRepository: r);
        },
        act: (bloc) => bloc.add(NoteListStarted()),
        expect: () => [
          const NoteListState(status: NoteListStatus.loading),
          const NoteListState(status: NoteListStatus.failure),
        ],
      );

      blocTest<NoteListBloc, NoteListState>(
        'emits success with empty list when no notes',
        build: () => NoteListBloc(noteRepository: FakeNoteRepository()),
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
    });

    group('NoteListQueryChanged', () {
      blocTest<NoteListBloc, NoteListState>(
        'updates query in state',
        build: () => NoteListBloc(noteRepository: repo),
        act: (bloc) => bloc.add(NoteListQueryChanged('hello')),
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
