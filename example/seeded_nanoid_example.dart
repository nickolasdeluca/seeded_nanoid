import 'package:seeded_nanoid/seeded_nanoid.dart';

void main() {
  final day = DateTime.utc(2026, 5, 26).toIso8601String();
  final dailyId = nanoid(seed: 'daily-offer:$day');
  print(dailyId);

  final orderIds = customAlphabet('0123456789abcdef', size: 16);
  print(orderIds.generate('order:9417'));

  final storedId = encodeSeed('customer:9417');
  print(storedId);
  print(decodeSeed(storedId));
}
