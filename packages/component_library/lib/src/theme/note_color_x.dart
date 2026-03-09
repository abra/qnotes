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
    NoteColor.pink => const Color(0xFFFFC0E8),
    NoteColor.lime => const Color(0xFFD0F5A0),
    NoteColor.indigo => const Color(0xFFBBBEFF),
    NoteColor.brown => const Color(0xFFE8C8A8),
    NoteColor.coral => const Color(0xFFFFB8A8),
    NoteColor.mint => const Color(0xFFAAF5DC),
    NoteColor.rose => const Color(0xFFFFB5D0),
    NoteColor.sand => const Color(0xFFF0E4B0),
  };

  Color forBrightness(Brightness brightness) => color;
}
