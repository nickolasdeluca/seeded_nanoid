import 'dart:convert';
import 'dart:typed_data';

/// Encodes [seed] as an unpadded, URL-safe, reversible identifier.
///
/// Unlike a fixed-length generated ID, this output retains the complete UTF-8
/// seed. Therefore, distinct Dart strings with distinct UTF-8 encodings
/// produce distinct results. Include a namespace in seeds when identifier
/// domains can overlap, for example `user:42` and `invoice:42`.
String encodeSeed(String seed) => encodeSeedBytes(utf8.encode(seed));

/// Encodes raw [seed] bytes as an unpadded, URL-safe, reversible identifier.
///
/// This uses canonical unpadded Base64 URL encoding. Distinct byte lists
/// always produce distinct identifiers.
String encodeSeedBytes(List<int> seed) {
  for (final byte in seed) {
    if (byte < 0 || byte > 255) {
      throw RangeError.range(byte, 0, 255, 'seed byte');
    }
  }

  return base64Url.encode(seed).replaceAll('=', '');
}

/// Decodes an identifier produced by [encodeSeed] back to its string seed.
///
/// Throws a [FormatException] if [id] is not canonical unpadded Base64 URL
/// data or if it does not represent valid UTF-8.
String decodeSeed(String id) => utf8.decode(decodeSeedBytes(id));

/// Decodes an identifier produced by [encodeSeedBytes] back to bytes.
///
/// Throws a [FormatException] unless [id] is canonical unpadded Base64 URL
/// data.
Uint8List decodeSeedBytes(String id) {
  if (!_base64UrlPattern.hasMatch(id) || id.length % 4 == 1) {
    throw const FormatException('Invalid unpadded Base64 URL seed ID.');
  }

  final paddingLength = (4 - id.length % 4) % 4;
  final padded = id.padRight(id.length + paddingLength, '=');
  final decoded = base64Url.decode(padded);

  if (encodeSeedBytes(decoded) != id) {
    throw const FormatException('Seed ID is not canonically encoded.');
  }

  return Uint8List.fromList(decoded);
}

final RegExp _base64UrlPattern = RegExp(r'^[A-Za-z0-9_-]*$');
