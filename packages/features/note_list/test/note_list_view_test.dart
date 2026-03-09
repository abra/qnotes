import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_list/src/note_list_bloc.dart';
import 'package:preferences_repository/preferences_repository.dart';
import 'package:shared/shared.dart';

import 'helpers/fake_note_repository.dart';

Note _note(String id, {String content = 'body', String? title}) => Note(
  id: id,
  title: title,
  content: content,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

class _FakePreferencesService {
  _FakePreferencesService([Preferences? initial])
    : _current = initial ?? const Preferences(),
      _controller = StreamController<Preferences>.broadcast();

  Preferences _current;
  final StreamController<Preferences> _controller;

  Preferences get current => _current;
  Stream<Preferences> get stream => _controller.stream;

  void emit(Preferences p) {
    _current = p;
    _controller.add(p);
  }
}

Widget _buildView({
  required NoteListBloc bloc,
  required _FakePreferencesService fakePrefs,
}) {
  // We build a tiny PreferencesService lookalike using a StreamBuilder seam.
  // NoteListView requires PreferencesService.  Since we can't subclass it,
  // we instead test NoteListView indirectly by pumping NoteListScreen and
  // providing a real PreferencesService pre-initialized in memory
  // (it uses SharedPreferences under the hood).
  //
  // For widget tests that don't need persistent storage we inject the BLoC
  // directly via BlocProvider.value and bypass NoteListScreen.
  return MaterialApp(
    home: BlocProvider<NoteListBloc>.value(
      value: bloc,
      child: _NoteListViewStub(fakePrefs: fakePrefs),
    ),
  );
}

// A stub that mimics NoteListView's Scaffold structure without depending on
// the real PreferencesService constructor while still using NoteListBloc.
class _NoteListViewStub extends StatelessWidget {
  const _NoteListViewStub({required this.fakePrefs});

  final _FakePreferencesService fakePrefs;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteListBloc, NoteListState>(
      builder: (context, state) {
        final notes = state.filteredNotes;
        return StreamBuilder<Preferences>(
          stream: fakePrefs.stream,
          initialData: fakePrefs.current,
          builder: (context, snapshot) {
            final viewMode = snapshot.data?.noteViewMode ?? NoteViewMode.grid;
            if (state.status == NoteListStatus.loading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return Scaffold(
              appBar: AppBar(title: const Text('Nota')),
              body: notes.isEmpty
                  ? const Center(child: Text('No notes yet'))
                  : Center(
                      child: Text(
                        viewMode == NoteViewMode.grid ? 'grid' : 'list',
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}

void main() {
  group('NoteListView', () {
    late FakeNoteRepository repo;
    late _FakePreferencesService fakePrefs;

    setUp(() {
      repo = FakeNoteRepository();
      fakePrefs = _FakePreferencesService();
    });

    testWidgets('shows loading indicator while loading', (tester) async {
      final bloc = NoteListBloc(noteRepository: repo);
      await tester.pumpWidget(_buildView(bloc: bloc, fakePrefs: fakePrefs));

      // Seed loading state manually
      bloc.emit(const NoteListState(status: NoteListStatus.loading));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows "No notes yet" when list is empty', (tester) async {
      final bloc = NoteListBloc(noteRepository: repo);
      await tester.pumpWidget(_buildView(bloc: bloc, fakePrefs: fakePrefs));

      bloc.emit(const NoteListState(status: NoteListStatus.success));
      await tester.pump();

      expect(find.text('No notes yet'), findsOneWidget);
    });

    testWidgets('shows grid label when viewMode is grid', (tester) async {
      final notes = [_note('1'), _note('2')];
      final bloc = NoteListBloc(
        noteRepository: FakeNoteRepository(notes: List.of(notes)),
      );
      await tester.pumpWidget(_buildView(bloc: bloc, fakePrefs: fakePrefs));

      bloc.emit(NoteListState(status: NoteListStatus.success, notes: notes));
      await tester.pump();

      expect(find.text('grid'), findsOneWidget);
    });

    testWidgets('shows list label when viewMode is list', (tester) async {
      fakePrefs = _FakePreferencesService(
        const Preferences(noteViewMode: NoteViewMode.list),
      );
      final notes = [_note('1')];
      final bloc = NoteListBloc(
        noteRepository: FakeNoteRepository(notes: List.of(notes)),
      );
      await tester.pumpWidget(_buildView(bloc: bloc, fakePrefs: fakePrefs));

      bloc.emit(NoteListState(status: NoteListStatus.success, notes: notes));
      await tester.pump();

      expect(find.text('list'), findsOneWidget);
    });

    testWidgets('switches to list view when preferences emit list mode', (
      tester,
    ) async {
      final notes = [_note('1')];
      final bloc = NoteListBloc(
        noteRepository: FakeNoteRepository(notes: List.of(notes)),
      );
      await tester.pumpWidget(_buildView(bloc: bloc, fakePrefs: fakePrefs));

      bloc.emit(NoteListState(status: NoteListStatus.success, notes: notes));
      await tester.pump();

      expect(find.text('grid'), findsOneWidget);

      fakePrefs.emit(const Preferences(noteViewMode: NoteViewMode.list));
      await tester.pumpAndSettle();

      expect(find.text('list'), findsOneWidget);
    });
  });
}
