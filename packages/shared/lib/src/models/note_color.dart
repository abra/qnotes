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
  purple,
  pink,
  lime,
  indigo,
  brown,
  coral,
  mint,
  rose,
  sand;

  static NoteColor from(String? value) => switch (value) {
    'red' => NoteColor.red,
    'orange' => NoteColor.orange,
    'yellow' => NoteColor.yellow,
    'green' => NoteColor.green,
    'teal' => NoteColor.teal,
    'blue' => NoteColor.blue,
    'purple' => NoteColor.purple,
    'pink' => NoteColor.pink,
    'lime' => NoteColor.lime,
    'indigo' => NoteColor.indigo,
    'brown' => NoteColor.brown,
    'coral' => NoteColor.coral,
    'mint' => NoteColor.mint,
    'rose' => NoteColor.rose,
    'sand' => NoteColor.sand,
    _ => NoteColor.none,
  };
}
