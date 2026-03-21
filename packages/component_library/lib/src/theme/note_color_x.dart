import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'nord.dart';

/// Maps [NoteColor] domain values to Flutter [Color].
extension NoteColorX on NoteColor {
  Color get color => switch (this) {
    NoteColor.none => Colors.transparent,
    NoteColor.red => const Color(0xFFF5A29D),
    NoteColor.orange => const Color(0xFFFFC26C),
    NoteColor.yellow => const Color(0xFFFFEE8D),
    NoteColor.green => const Color(0xFFA4E1A1),
    NoteColor.teal => const Color(0xFF82D7E0),
    NoteColor.blue => const Color(0xFF8EC6F7),
    NoteColor.purple => const Color(0xFFCDA5E0),
    NoteColor.pink => const Color(0xFFFFB2E0),
    NoteColor.lime => const Color(0xFFC9F391),
    NoteColor.indigo => const Color(0xFFB1B5FF),
    NoteColor.brown => const Color(0xFFE1B995),
    NoteColor.coral => const Color(0xFFFFA68D),
    NoteColor.mint => const Color(0xFF8EF3D3),
    NoteColor.rose => const Color(0xFFFFA4C4),
    NoteColor.sand => const Color(0xFFEDDB99),
  };

  Color forBrightness(Brightness brightness) => color;

  /// Returns a legible text/icon color for content drawn on top of this
  /// note color.
  Color get onColor => NordPolarNight.nord0;
}
