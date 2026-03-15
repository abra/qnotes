import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'theme/note_color_x.dart';

/// Four coloured rounded squares arranged in a 2×2 grid,
/// mirroring the app's grid note view.
class NotaLogo extends StatelessWidget {
  const NotaLogo({super.key, this.size = 20});

  final double size;

  static const _colors = [
    NoteColor.blue,
    NoteColor.orange,
    NoteColor.green,
    NoteColor.pink,
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final gap = size * 0.15;
    final cell = (size - gap) / 2;
    final radius = BorderRadius.circular(cell * 0.25);

    Widget square(NoteColor color) => Container(
      width: cell,
      height: cell,
      decoration: BoxDecoration(
        color: color.forBrightness(brightness),
        borderRadius: radius,
      ),
    );

    return SizedBox(
      width: size,
      height: size,
      child: Column(
        spacing: gap,
        children: [
          Row(spacing: gap, children: [square(_colors[0]), square(_colors[1])]),
          Row(spacing: gap, children: [square(_colors[2]), square(_colors[3])]),
        ],
      ),
    );
  }
}
