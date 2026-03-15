import 'dart:convert';
import 'dart:io';

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
              final firstImage = DeltaUtils.firstImagePath(note.content);
              final contentStyle = Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: textColor);
              final contentText = Text.rich(
                TextSpan(
                  style: contentStyle,
                  children: _buildContentSpans(note.content, contentStyle),
                ),
                maxLines: contentMaxLines,
                overflow: TextOverflow.ellipsis,
              );
              return SizedBox(
                width: double.infinity,
                height: bounded ? constraints.maxHeight : null,
                child: InkWell(
                  onTap: onPressed,
                  onLongPress: onLongPress,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
                    children: [
                      if (firstImage != null)
                        SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: Image.file(
                            File(firstImage),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ),
                      Expanded(
                        flex: bounded ? 1 : 0,
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
                                          color: textColor.withValues(
                                            alpha: 0.6,
                                          ),
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
                    ],
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

List<InlineSpan> _buildContentSpans(String content, TextStyle baseStyle) {
  List<dynamic>? ops;
  try {
    final decoded = jsonDecode(content);
    if (decoded is Map) ops = decoded['ops'] as List<dynamic>?;
    if (decoded is List) ops = decoded as List<dynamic>;
  } catch (_) {}
  if (ops == null) return [TextSpan(text: content, style: baseStyle)];

  final result = <InlineSpan>[];
  final pendingLine = <InlineSpan>[];
  int orderedCounter = 0;
  bool firstLine = true;

  void flushLine(Map<dynamic, dynamic>? blockAttrs) {
    final listType = blockAttrs?['list'] as String?;
    if (!firstLine) result.add(const TextSpan(text: '\n'));
    firstLine = false;
    String prefix = '';
    switch (listType) {
      case 'bullet':
        prefix = '• ';
        orderedCounter = 0;
      case 'ordered':
        orderedCounter++;
        prefix = '$orderedCounter. ';
      case 'checked':
      case 'unchecked':
        result.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                listType == 'checked'
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: baseStyle.fontSize ?? 12,
                color: baseStyle.color,
              ),
            ),
          ),
        );
        orderedCounter = 0;
        result.addAll(pendingLine);
        pendingLine.clear();
        return;
      default:
        orderedCounter = 0;
    }
    if (prefix.isNotEmpty) {
      result.add(TextSpan(text: prefix, style: baseStyle));
    }
    result.addAll(pendingLine);
    pendingLine.clear();
  }

  for (final op in ops) {
    if (op is! Map) continue;
    final insert = op['insert'];
    final attrs = op['attributes'] as Map<dynamic, dynamic>?;
    if (insert is! String) continue; // skip image embeds
    if (insert == '\n') {
      flushLine(attrs);
    } else {
      final lines = insert.split('\n');
      for (int i = 0; i < lines.length; i++) {
        final part = lines[i];
        if (part.isNotEmpty) {
          pendingLine.add(
            TextSpan(text: part, style: _applyInlineStyle(baseStyle, attrs)),
          );
        }
        if (i < lines.length - 1) flushLine(null);
      }
    }
  }

  if (pendingLine.isNotEmpty) flushLine(null);
  return result;
}

TextStyle _applyInlineStyle(TextStyle base, Map<dynamic, dynamic>? attrs) {
  if (attrs == null) return base;
  var style = base;
  if (attrs['bold'] == true)
    style = style.copyWith(fontWeight: FontWeight.bold);
  if (attrs['italic'] == true)
    style = style.copyWith(fontStyle: FontStyle.italic);
  if (attrs['underline'] == true) {
    style = style.copyWith(decoration: TextDecoration.underline);
  }
  if (attrs['strike'] == true) {
    style = style.copyWith(decoration: TextDecoration.lineThrough);
  }
  return style;
}
