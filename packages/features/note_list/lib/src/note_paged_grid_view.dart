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
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
