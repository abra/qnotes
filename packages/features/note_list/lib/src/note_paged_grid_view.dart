import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'note_card.dart';

class NotePagedGridView extends StatelessWidget {
  const NotePagedGridView({
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
    return GridView.builder(
      padding: const EdgeInsets.all(Spacing.medium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Spacing.small,
        mainAxisSpacing: Spacing.small,
        childAspectRatio: 0.82,
      ),
      itemCount: notes.length,
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
