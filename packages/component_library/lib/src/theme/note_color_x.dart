import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// Maps [NoteColor] domain values to Flutter [Color].
extension NoteColorX on NoteColor {
  Color get color => switch (this) {
    NoteColor.none => Colors.transparent,
    NoteColor.red => const Color(0xFFF7B9B5),
    NoteColor.orange => const Color(0xFFFFCE91),
    NoteColor.yellow => const Color(0xFFFFF3A0),
    NoteColor.green => const Color(0xFFB5E8B0),
    NoteColor.teal => const Color(0xFF96DCE8),
    NoteColor.blue => const Color(0xFFA3CFF8),
    NoteColor.purple => const Color(0xFFD4A8E0),
  };

  Color forBrightness(Brightness brightness) => color;
}
