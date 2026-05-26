import 'dart:convert';

import 'package:seeded_nanoid/seeded_nanoid.dart';
import 'package:test/test.dart';

void main() {
  group('nanoid', () {
    test('has a stable default version 1 vector', () {
      expect(
        nanoid(seed: 'daily-offer:2026-05-26T00:00:00.000Z'),
        'fkU2HaBiDCmyt870jhd8h',
      );
    });

    test('locks byte order and continuation across generated words', () {
      expect(
        nanoid(seed: 'stream-continuation', size: 64),
        'jco4k5FeONAbbhGpwW01XzIf9t_IEA6ORdpAtPkbeLPFCpb5LBqr8MsekXBBbxjS',
      );
    });

    test('uses the Nano ID URL alphabet and default size', () {
      final id = nanoid(seed: 'account:42');

      expect(id.length, defaultSize);
      expect(id.runes, everyElement(isIn(urlAlphabet.runes)));
    });

    test('returns the same identifier whenever the seed is reused', () {
      final first = nanoid(seed: 'invoice:9417');
      final second = nanoid(seed: 'invoice:9417');

      expect(first, second);
    });

    test('supports direct byte seeds using the same UTF-8 representation', () {
      final generator = SeededNanoId();

      expect(
        generator.generateBytes(utf8.encode('cafe:\u00e9')),
        generator.generate('cafe:\u00e9'),
      );
    });
  });

  group('customAlphabet', () {
    test('has a stable custom-alphabet version 1 vector', () {
      final generator = customAlphabet('0123456789abcdef', size: 16);

      expect(generator.generate('order:9417'), 'cc63f406a6bae5f0');
    });

    test('accepts a per-call output size override', () {
      final generator = customAlphabet('0123456789abcdef', size: 16);

      expect(generator.generate('order:9417', size: 8), 'cc63f406');
    });

    test('treats Unicode scalar values as alphabet symbols', () {
      final generator = customAlphabet('\u{1f31e}\u{1f319}', size: 9);
      final id = generator.generate('sky');

      expect(id.runes.length, 9);
      expect(id.runes, everyElement(isIn(<int>{0x1f31e, 0x1f319})));
    });
  });

  group('validation', () {
    test('rejects invalid output sizes', () {
      expect(() => SeededNanoId(size: 0), throwsRangeError);
      expect(() => nanoid(seed: 'seed', size: -1), throwsRangeError);
      expect(() => SeededNanoId().generate('seed', size: 0), throwsRangeError);
    });

    test('rejects invalid alphabets', () {
      expect(() => customAlphabet(''), throwsArgumentError);
      expect(() => customAlphabet('aab'), throwsArgumentError);
      expect(
        () => customAlphabet(
          String.fromCharCodes(List<int>.generate(257, (index) => index + 1)),
        ),
        throwsArgumentError,
      );
    });

    test('rejects values that are not bytes', () {
      expect(() => SeededNanoId().generateBytes(<int>[256]), throwsRangeError);
      expect(() => encodeSeedBytes(<int>[-1]), throwsRangeError);
    });
  });

  group('reversible seed IDs', () {
    test('has a stable URL-safe encoding vector', () {
      expect(encodeSeed('customer:9417'), 'Y3VzdG9tZXI6OTQxNw');
      expect(decodeSeed('Y3VzdG9tZXI6OTQxNw'), 'customer:9417');
    });

    test('round-trips arbitrary byte input', () {
      final bytes = <int>[0, 1, 2, 127, 128, 255];

      expect(decodeSeedBytes(encodeSeedBytes(bytes)), bytes);
    });

    test('preserves distinct namespaced unique inputs', () {
      final ids = <String>{encodeSeed('customer:42'), encodeSeed('invoice:42')};

      expect(ids, hasLength(2));
    });

    test('rejects padded, malformed, or non-canonical encodings', () {
      expect(() => decodeSeed('YQ=='), throwsFormatException);
      expect(() => decodeSeed(r'$bad'), throwsFormatException);
      expect(() => decodeSeed('A'), throwsFormatException);
      expect(() => decodeSeed('YR'), throwsFormatException);
    });

    test('rejects decoded bytes that are not UTF-8 strings', () {
      expect(
        () => decodeSeed(encodeSeedBytes(<int>[255])),
        throwsFormatException,
      );
    });
  });
}
