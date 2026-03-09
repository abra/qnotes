/// Predefined note background colors.
///
/// Serialized as a string (e.g. 'red') for storage.
/// Actual Color values are defined in component_library.
enum NoteColor {
  none,
  red,
  orange,
  yellow,
  green,
  teal,
  blue,
  purple;

  static NoteColor from(String? value) => switch (value) {
    'red' => NoteColor.red,
    'orange' => NoteColor.orange,
    'yellow' => NoteColor.yellow,
    'green' => NoteColor.green,
    'teal' => NoteColor.teal,
    'blue' => NoteColor.blue,
    'purple' => NoteColor.purple,
    _ => NoteColor.none,
  };
}
