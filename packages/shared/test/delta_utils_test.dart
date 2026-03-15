import 'dart:convert';

import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  const plainText = 'Hello world';
  final deltaJson = jsonEncode({
    'ops': [
      {'insert': 'Hello '},
      {
        'insert': 'world',
        'attributes': {'bold': true},
      },
      {'insert': '\n'},
    ],
  });
  final emptyDelta = jsonEncode({
    'ops': [
      {'insert': '\n'},
    ],
  });
  final imageOnlyDelta = jsonEncode({
    'ops': [
      {
        'insert': {'image': '/path/to/image.jpg'},
      },
      {'insert': '\n'},
    ],
  });
  final multiImageDelta = jsonEncode({
    'ops': [
      {
        'insert': {'image': '/img/first.jpg'},
      },
      {'insert': 'Some text'},
      {
        'insert': {'image': '/img/second.jpg'},
      },
      {'insert': '\n'},
    ],
  });

  group('DeltaUtils.isDelta', () {
    test('returns true for valid Delta JSON', () {
      expect(DeltaUtils.isDelta(deltaJson), isTrue);
    });

    test('returns false for plain text', () {
      expect(DeltaUtils.isDelta(plainText), isFalse);
    });

    test('returns false for empty string', () {
      expect(DeltaUtils.isDelta(''), isFalse);
    });

    test('returns false for arbitrary JSON without ops', () {
      expect(DeltaUtils.isDelta('{"foo": "bar"}'), isFalse);
    });
  });

  group('DeltaUtils.toPlainText', () {
    test('extracts plain text from Delta', () {
      expect(DeltaUtils.toPlainText(deltaJson), 'Hello world');
    });

    test('returns plain text as-is for legacy content', () {
      expect(DeltaUtils.toPlainText(plainText), plainText);
    });

    test('ignores image embeds', () {
      expect(DeltaUtils.toPlainText(imageOnlyDelta), '');
    });

    test('extracts text and ignores images in mixed delta', () {
      expect(DeltaUtils.toPlainText(multiImageDelta), 'Some text');
    });
  });

  group('DeltaUtils.isContentEmpty', () {
    test('returns true for empty Delta', () {
      expect(DeltaUtils.isContentEmpty(emptyDelta), isTrue);
    });

    test('returns false for Delta with text', () {
      expect(DeltaUtils.isContentEmpty(deltaJson), isFalse);
    });

    test('returns false for Delta with image only', () {
      expect(DeltaUtils.isContentEmpty(imageOnlyDelta), isFalse);
    });

    test('returns true for empty plain text', () {
      expect(DeltaUtils.isContentEmpty(''), isTrue);
      expect(DeltaUtils.isContentEmpty('   '), isTrue);
    });

    test('returns false for non-empty plain text', () {
      expect(DeltaUtils.isContentEmpty(plainText), isFalse);
    });
  });

  group('DeltaUtils.firstImagePath', () {
    test('returns null for plain text', () {
      expect(DeltaUtils.firstImagePath(plainText), isNull);
    });

    test('returns null for Delta without images', () {
      expect(DeltaUtils.firstImagePath(deltaJson), isNull);
    });

    test('returns first image path from Delta', () {
      expect(
        DeltaUtils.firstImagePath(multiImageDelta),
        '/img/first.jpg',
      );
    });

    test('returns image path when only image present', () {
      expect(
        DeltaUtils.firstImagePath(imageOnlyDelta),
        '/path/to/image.jpg',
      );
    });
  });

  group('DeltaUtils.allImagePaths', () {
    test('returns empty list for plain text', () {
      expect(DeltaUtils.allImagePaths(plainText), isEmpty);
    });

    test('returns empty list for Delta without images', () {
      expect(DeltaUtils.allImagePaths(deltaJson), isEmpty);
    });

    test('returns all image paths', () {
      expect(
        DeltaUtils.allImagePaths(multiImageDelta),
        ['/img/first.jpg', '/img/second.jpg'],
      );
    });
  });

  group('DeltaUtils.fromPlainText', () {
    test('wraps plain text into Delta JSON', () {
      final result = DeltaUtils.fromPlainText('Hello');
      expect(DeltaUtils.isDelta(result), isTrue);
      expect(DeltaUtils.toPlainText(result), 'Hello');
    });

    test('empty string produces non-empty Delta with newline', () {
      final result = DeltaUtils.fromPlainText('');
      expect(DeltaUtils.isDelta(result), isTrue);
      expect(DeltaUtils.isContentEmpty(result), isTrue);
    });
  });
}
