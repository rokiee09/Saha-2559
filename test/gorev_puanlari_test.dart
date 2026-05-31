import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/araclar/gorev_puanlari/gorev_puanlari_data.dart';

void main() {
  group('formatGorevPuani', () {
    test('1718 → 1.718', () {
      expect(formatGorevPuani(1.718), '1.718');
    });

    test('3660 → 3.660', () {
      expect(formatGorevPuani(3.66), '3.660');
    });

    test('1520 → 1.520', () {
      expect(formatGorevPuani(1.52), '1.520');
    });
  });
}
