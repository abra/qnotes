import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    this.onPressed,
    this.onLongPress,
    this.onDeleted,
    this.isSelected = false,
    this.contentMaxLines = 6,
    this.titleMaxLines = 2,
  });

  final Note note;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final VoidCallback? onDeleted;
  final bool isSelected;
  final int contentMaxLines;
  final int titleMaxLines;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final hasColor = note.color != NoteColor.none;
    final bgColor = hasColor
        ? note.color.forBrightness(brightness)
        : (brightness == Brightness.light ? Colors.white : null);

    final textColor = hasColor
        ? note.color.onColor
        : Theme.of(context).colorScheme.onSurface;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      margin: EdgeInsets.zero,
      color: bgColor,
      surfaceTintColor: Colors.transparent,
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bounded = constraints.maxHeight.isFinite;
              final contentText = Text(
                DeltaUtils.toPlainText(note.content),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: textColor),
                maxLines: contentMaxLines,
                overflow: TextOverflow.ellipsis,
              );
              return SizedBox(
                width: double.infinity,
                height: bounded ? constraints.maxHeight : null,
                child: InkWell(
                  onTap: onPressed,
                  onLongPress: onLongPress,
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.medium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: bounded
                          ? MainAxisSize.max
                          : MainAxisSize.min,
                      children: [
                        if (note.title != null || note.isPinned) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (note.title != null)
                                Expanded(
                                  child: Text(
                                    note.title!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(color: textColor),
                                    maxLines: titleMaxLines,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              else
                                const Spacer(),
                              if (note.isPinned)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: Spacing.xSmall,
                                  ),
                                  child: Icon(
                                    Icons.push_pin,
                                    size: IconSize.xSmall,
                                    color: textColor.withValues(alpha: 0.6),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: Spacing.xSmall),
                        ],
                        if (bounded)
                          Expanded(child: contentText)
                        else
                          contentText,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.15),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.xSmall),
                    child: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: IconSize.medium,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
