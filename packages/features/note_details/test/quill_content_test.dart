import 'package:flutter_test/flutter_test.dart';
import 'package:note_details/src/quill_content.dart';

void main() {
  group('opsFromContent', () {
    group('canonical Delta JSON {"ops": [...]}', () {
      test('returns the ops list', () {
        const content = '{"ops":[{"insert":"Hello\\n"}]}';
        expect(opsFromContent(content), [
          {'insert': 'Hello\n'},
        ]);
      });

      test('preserves multiple ops with attributes', () {
        const content =
            '{"ops":[{"insert":"Bold","attributes":{"bold":true}},{"insert":"\\n"}]}';
        expect(opsFromContent(content), [
          {
            'insert': 'Bold',
            'attributes': {'bold': true},
          },
          {'insert': '\n'},
        ]);
      });
    });

    group('legacy bare array [...]', () {
      test('returns the list as-is', () {
        const content = '[{"insert":"Legacy\\n"}]';
        expect(opsFromContent(content), [
          {'insert': 'Legacy\n'},
        ]);
      });
    });

    group('plain text fallback', () {
      test('wraps text in a single insert op with trailing newline', () {
        expect(opsFromContent('Hello world'), [
          {'insert': 'Hello world\n'},
        ]);
      });

      test('handles empty string', () {
        expect(opsFromContent(''), [
          {'insert': '\n'},
        ]);
      });

      test('handles invalid JSON', () {
        expect(opsFromContent('not valid {{{'), [
          {'insert': 'not valid {{{\n'},
        ]);
      });

      test('handles JSON that is neither Map nor List (e.g. a number)', () {
        expect(opsFromContent('42'), [
          {'insert': '42\n'},
        ]);
      });
    });
  });
}
