import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/gorevlerim/kariyer/basari/basari_models.dart';
import 'package:coderipple/src/features/gorevlerim/kariyer/taltif/taltif_models.dart';

void main() {
  test('5 basari -> 1 kalan for next ustun', () {
    final h = hesaplaBasari([
      for (var i = 0; i < 5; i++)
        BasariBelge(
          id: '$i',
          tur: BasariBelgeTuru.basari,
          tarihMs: 0,
          verenMakam: '',
          evrakNo: '',
          aciklama: '',
          not: '',
          createdAtMs: 0,
        ),
      const BasariBelge(
        id: 'u',
        tur: BasariBelgeTuru.ustunBasari,
        tarihMs: 0,
        verenMakam: '',
        evrakNo: '',
        aciklama: '',
        not: '',
        createdAtMs: 0,
      ),
    ]);
    expect(h.basariSayisi, 5);
    expect(h.ustunSayisi, 1);
    expect(h.sonrakiUstunIcinKalan, 1);
    expect(h.ustunEsikUlasildi, isFalse);
  });

  test('3 basari triggers esik bilgilendirme', () {
    final h = hesaplaBasari([
      for (var i = 0; i < 3; i++)
        BasariBelge(
          id: '$i',
          tur: BasariBelgeTuru.basari,
          tarihMs: 0,
          verenMakam: '',
          evrakNo: '',
          aciklama: '',
          not: '',
          createdAtMs: 0,
        ),
    ]);
    expect(h.basariSayisi, 3);
    expect(h.sonrakiUstunIcinKalan, 0);
    expect(h.ustunEsikUlasildi, isTrue);
  });

  test('taltif ozet', () {
    final ozet = hesaplaTaltif([
      TaltifKayit(
        id: '1',
        tarihMs: DateTime(2024, 6, 1).millisecondsSinceEpoch,
        tutar: 5000,
        verenMakam: 'Makam',
        aciklama: 'Test',
        not: '',
        createdAtMs: 0,
      ),
      TaltifKayit(
        id: '2',
        tarihMs: DateTime(2025, 1, 1).millisecondsSinceEpoch,
        tutar: 3000,
        verenMakam: 'Makam',
        aciklama: 'Test 2',
        not: '',
        createdAtMs: 0,
      ),
    ]);
    expect(ozet.toplamSayi, 2);
    expect(ozet.toplamTutar, 8000);
    expect(ozet.sonTarihMs, DateTime(2025, 1, 1).millisecondsSinceEpoch);
  });
}
