import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'note_card.dart';

class NotePagedGridView extends StatelessWidget {
  const NotePagedGridView({
    super.key,
    required this.notes,
    required this.selectedIds,
    required this.isSelectionMode,
    this.onNotePressed,
    this.onNoteDeleted,
    this.onNoteLongPressed,
    this.bottomPadding = 0,
  });

  final List<Note> notes;
  final Set<String> selectedIds;
  final bool isSelectionMode;
  final ValueChanged<Note>? onNotePressed;
  final ValueChanged<String>? onNoteDeleted;
  final ValueChanged<String>? onNoteLongPressed;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        Spacing.medium,
        Spacing.medium,
        Spacing.medium,
        Spacing.medium + bottomPadding,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Spacing.small,
        mainAxisSpacing: Spacing.small,
        childAspectRatio: 1,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final isSelected = selectedIds.contains(note.id);

        return NoteCard(
          key: ValueKey(note.id),
          note: note,
          isSelected: isSelected,
          onPressed: isSelectionMode
              ? () => onNoteLongPressed?.call(note.id)
              : () => onNotePressed?.call(note),
          onLongPress: isSelectionMode
              ? null
              : () => onNoteLongPressed?.call(note.id),
          onDeleted: () => onNoteDeleted?.call(note.id),
        );
      },
    );
  }
}
