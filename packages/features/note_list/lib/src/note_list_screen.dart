import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_list/src/note_list_bloc.dart';
import 'package:note_list/src/note_list_state.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({super.key, this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NoteListBloc>(
      create: (_) => NoteListBloc(NoteListState()),
      child: _NoteListView(onBackPressed: onBackPressed),
    );
  }
}

class _NoteListView extends StatelessWidget {
  const _NoteListView({this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () { if (onBackPressed != null) onBackPressed!(); },
        child: const Text('Back'),
      ),
    );
  }
}
