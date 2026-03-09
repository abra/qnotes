import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'note_card.dart';

class NotePagedListView extends StatelessWidget {
  const NotePagedListView({
    super.key,
    required this.notes,
    this.onNotePressed,
    this.onNoteDeleted,
  });

  final List<Note> notes;
  final ValueChanged<Note>? onNotePressed;
  final ValueChanged<String>? onNoteDeleted;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(Spacing.medium),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: Spacing.small),
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onPressed: () => onNotePressed?.call(note),
          onDeleted: () => onNoteDeleted?.call(note.id),
        );
      },
    );
  }
}
