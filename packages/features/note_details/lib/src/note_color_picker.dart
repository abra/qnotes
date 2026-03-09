part of 'note_details_screen.dart';

class _NoteColorPicker extends StatelessWidget {
  const _NoteColorPicker({required this.selected, required this.onSelected});

  final NoteColor selected;
  final ValueChanged<NoteColor> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: NoteColor.values.map((color) {
            final isSelected = color == selected;
            return GestureDetector(
              onTap: () {
                onSelected(color);
                Navigator.of(context).pop();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color == NoteColor.none
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : color.forBrightness(Theme.of(context).brightness),
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        )
                      : Border.all(color: Colors.transparent),
                ),
                child: color == NoteColor.none
                    ? Icon(
                        Icons.block,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
