import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/gorevlerim/kariyer/basari/basari_models.dart';

void main() {
  test('5 basari -> 1 kalan for next ustun', () {
    final h = hesaplaBasari([
      for (var i = 0; i < 5; i++)
        BasariBelge(
          id: '$i',
          tur: BasariBelgeTuru.basari,
          tarihMs: 0,
          verenMakam: '',
          aciklama: '',
          createdAtMs: 0,
        ),
      const BasariBelge(
        id: 'u',
        tur: BasariBelgeTuru.ustunBasari,
        tarihMs: 0,
        verenMakam: '',
        aciklama: '',
        createdAtMs: 0,
      ),
    ]);
    expect(h.basariSayisi, 5);
    expect(h.ustunSayisi, 1);
    expect(h.sonrakiUstunIcinKalan, 1);
  });
}
