/// Deterministic Nano ID-style identifiers based on caller-provided seeds.
///
/// Use [nanoid] when a short, stable identifier with a configurable length is
/// needed. Use [encodeSeed] when distinct input bytes must always produce
/// distinct identifiers.
library;

export 'src/seed_encoding.dart';
export 'src/seeded_nanoid.dart';
