import 'package:shared/shared.dart';
import 'package:test/test.dart';

Note _note({
  String id = '1',
  String? title,
  String content = 'content',
  NoteColor color = NoteColor.none,
  bool isPinned = false,
}) => Note(
  id: id,
  title: title,
  content: content,
  color: color,
  isPinned: isPinned,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

void main() {
  group('Note', () {
    group('copyWith()', () {
      test('preserves id and createdAt', () {
        final note = _note();
        final copy = note.copyWith(content: 'new content');

        expect(copy.id, note.id);
        expect(copy.createdAt, note.createdAt);
      });

      test('updates content', () {
        final note = _note();
        final copy = note.copyWith(content: 'updated');

        expect(copy.content, 'updated');
      });

      test('updates title', () {
        final note = _note();
        final copy = note.copyWith(title: 'new title');

        expect(copy.title, 'new title');
      });

      test('updates isPinned', () {
        final note = _note();
        final copy = note.copyWith(isPinned: true);

        expect(copy.isPinned, isTrue);
      });

      test('updates color', () {
        final note = _note();
        final copy = note.copyWith(color: NoteColor.blue);

        expect(copy.color, NoteColor.blue);
      });

      test('updates updatedAt', () {
        final note = _note();
        final newDate = DateTime(2025);
        final copy = note.copyWith(updatedAt: newDate);

        expect(copy.updatedAt, newDate);
      });
    });

    group('equality', () {
      test('two notes with same fields are equal', () {
        final a = _note();
        final b = _note();

        expect(a, equals(b));
      });

      test('notes with different id are not equal', () {
        final a = _note(id: '1');
        final b = _note(id: '2');

        expect(a, isNot(equals(b)));
      });

      test('notes with different content are not equal', () {
        final a = _note(content: 'a');
        final b = _note(content: 'b');

        expect(a, isNot(equals(b)));
      });

      test('notes with different color are not equal', () {
        final a = _note(color: NoteColor.none);
        final b = _note(color: NoteColor.red);

        expect(a, isNot(equals(b)));
      });
    });
  });
}
