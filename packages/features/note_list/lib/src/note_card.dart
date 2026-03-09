import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    this.onPressed,
    this.onDeleted,
  });

  final Note note;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = note.color == NoteColor.none
        ? (brightness == Brightness.light ? Colors.white : null)
        : note.color.forBrightness(brightness);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: bgColor,
      surfaceTintColor: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.title != null || note.isPinned) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.title != null)
                      Expanded(
                        child: Text(
                          note.title!,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const Spacer(),
                    if (note.isPinned)
                      Padding(
                        padding: const EdgeInsets.only(left: Spacing.xSmall),
                        child: Icon(
                          Icons.push_pin,
                          size: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.xSmall),
              ],
              Text(
                note.content,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
