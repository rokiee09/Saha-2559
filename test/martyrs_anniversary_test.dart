import 'package:coderipple/src/data/models/martyr.dart';
import 'package:coderipple/src/features/martyrs/martyrs_anniversary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('martyrsOnAnniversaryDay matches month and day', () {
    final all = [
      Martyr()
        ..id = 1
        ..fullName = 'A'
        ..cityName = 'Ankara'
        ..dateOfMartyrdom = DateTime(2017, 6, 11),
      Martyr()
        ..id = 2
        ..fullName = 'B'
        ..cityName = 'İstanbul'
        ..dateOfMartyrdom = DateTime(2020, 7, 19),
      Martyr()
        ..id = 3
        ..fullName = 'C'
        ..cityName = 'Belirtilmedi'
        ..dateOfMartyrdom = DateTime(2015, 6, 11),
    ];
    final gun = DateTime(2026, 6, 11);
    final found = martyrsOnAnniversaryDay(all, gun);
    expect(found.length, 2);
    expect(found.first.fullName, 'A');
  });

  test('marquee lists martyr names without closing line', () {
    final text = buildSehitDevriyeMarqueeText([
      Martyr()
        ..id = 1
        ..fullName = 'Polis Memuru X'
        ..cityName = 'Ankara'
        ..dateOfMartyrdom = DateTime(2017, 6, 2),
    ]);
    expect(text, contains('Polis Memuru X'));
    expect(text, contains('Ankara'));
    expect(text, isNot(contains(sehitDevriyeKapanis)));
  });

  test('empty marquee is empty', () {
    expect(buildSehitDevriyeMarqueeText([]), '');
  });
}
