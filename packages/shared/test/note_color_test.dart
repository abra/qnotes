import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  group('NoteColor.from()', () {
    test('returns correct value for each known string', () {
      expect(NoteColor.from('red'), NoteColor.red);
      expect(NoteColor.from('orange'), NoteColor.orange);
      expect(NoteColor.from('yellow'), NoteColor.yellow);
      expect(NoteColor.from('green'), NoteColor.green);
      expect(NoteColor.from('teal'), NoteColor.teal);
      expect(NoteColor.from('blue'), NoteColor.blue);
      expect(NoteColor.from('purple'), NoteColor.purple);
    });

    test('returns none for unknown string', () {
      expect(NoteColor.from('unknown'), NoteColor.none);
    });

    test('returns none for null', () {
      expect(NoteColor.from(null), NoteColor.none);
    });

    test('returns none for empty string', () {
      expect(NoteColor.from(''), NoteColor.none);
    });
  });
}
