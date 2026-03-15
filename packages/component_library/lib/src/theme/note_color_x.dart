import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'catppuccin.dart';

/// Maps [NoteColor] domain values to Flutter [Color].
extension NoteColorX on NoteColor {
  Color get color => switch (this) {
    NoteColor.none => Colors.transparent,
    NoteColor.red => const Color(0xFFF28B85),
    NoteColor.orange => const Color(0xFFFFB347),
    NoteColor.yellow => const Color(0xFFFFEA70),
    NoteColor.green => const Color(0xFF8DD98A),
    NoteColor.teal => const Color(0xFF63CDD8),
    NoteColor.blue => const Color(0xFF72B8F5),
    NoteColor.purple => const Color(0xFFC08ED8),
    NoteColor.pink => const Color(0xFFFF9FD8),
    NoteColor.lime => const Color(0xFFBBF075),
    NoteColor.indigo => const Color(0xFF9EA3FF),
    NoteColor.brown => const Color(0xFFD9A87A),
    NoteColor.coral => const Color(0xFFFF9070),
    NoteColor.mint => const Color(0xFF72F0C8),
    NoteColor.rose => const Color(0xFFFF8DB5),
    NoteColor.sand => const Color(0xFFE8D280),
  };

  Color forBrightness(Brightness brightness) => color;

  /// Returns a legible text/icon color for content drawn on top of this
  /// note color.
  Color get onColor => CatppuccinLatte.text;
}
