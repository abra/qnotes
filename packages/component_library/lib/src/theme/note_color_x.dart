import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// Maps [NoteColor] domain values to Flutter [Color] for light and dark themes.
///
/// Colors are pastel tones that ensure black text remains legible in both modes.
extension NoteColorX on NoteColor {
  Color get lightColor => switch (this) {
    NoteColor.none => Colors.transparent,
    NoteColor.red => const Color(0xFFFAD2CF),
    NoteColor.orange => const Color(0xFFFFE0B2),
    NoteColor.yellow => const Color(0xFFFFF9C4),
    NoteColor.green => const Color(0xFFCCF0C8),
    NoteColor.teal => const Color(0xFFB2EBF2),
    NoteColor.blue => const Color(0xFFBBDEFB),
    NoteColor.purple => const Color(0xFFE1BEE7),
  };

  Color get darkColor => switch (this) {
    NoteColor.none => Colors.transparent,
    NoteColor.red => const Color(0xFF5C2B29),
    NoteColor.orange => const Color(0xFF5D3A1A),
    NoteColor.yellow => const Color(0xFF5D4A1A),
    NoteColor.green => const Color(0xFF1E3B1E),
    NoteColor.teal => const Color(0xFF1A3B3B),
    NoteColor.blue => const Color(0xFF1A2B3B),
    NoteColor.purple => const Color(0xFF3B1A5C),
  };

  Color forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? darkColor : lightColor;
}
