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
      child: NoteListView(onBackPressed: onBackPressed),
    );
  }
}

@visibleForTesting
class NoteListView extends StatelessWidget {
  const NoteListView({super.key, this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          if (onBackPressed != null) onBackPressed!();
        },
        child: const Text('Back'),
      ),
    );
  }
}
