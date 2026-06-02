import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/haklar/maas_katsayi_data.dart';
import 'package:coderipple/src/features/haklar/polis_odeme_derece_kademe.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const katsayi = 0.352397;

  late PolisOdemeDereceKademeTablosu tablo;

  setUpAll(() async {
    resetPolisOdemeTabloCacheForTest();
    final raw =
        await rootBundle.loadString('assets/json/polis_odeme_derece_kademe.json');
    tablo = PolisOdemeDereceKademeTablosu.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  });

  group('PolisOdemeDereceKademeTablosu.hesapla', () {
    test('1/4 — aylık ve ek gösterge referans bordroya uyumlu', () {
      final r = tablo.hesapla(
        unvan: 'Polis Memuru',
        derece: 1,
        kademe: 4,
        memurAylikKatsayisi: katsayi,
      );
      expect(r, isNotNull);
      expect(r!.gostergePuan, 5907);
      expect(r.ekGostergeTl, closeTo(4996.34, 0.5));
      expect(r.ohtTl, closeTo(19513.47, 0.5));
      expect(r.gostergePuan * katsayi, closeTo(2081.81, 1.0));
      expect(r.kalibreNokta, isTrue);
    });

    test('3/1', () {
      final r = tablo.hesapla(
        unvan: 'Polis Memuru',
        derece: 3,
        kademe: 1,
        memurAylikKatsayisi: katsayi,
      );
      expect(r!.gostergePuan, 4017);
      expect(r.ekGostergeTl, closeTo(3053.32, 0.5));
      expect(r.gostergePuan * katsayi, closeTo(1415.63, 1.0));
    });

    test('5/2', () {
      final r = tablo.hesapla(
        unvan: 'Polis Memuru',
        derece: 5,
        kademe: 2,
        memurAylikKatsayisi: katsayi,
      );
      expect(r!.gostergePuan, 3407);
      expect(r.ekGostergeTl, closeTo(2498.17, 0.5));
      expect(r.ohtTl, closeTo(18326.84, 0.5));
      expect(r.gostergePuan * katsayi, closeTo(1200.51, 1.0));
    });

    test('geçersiz kademe null döner', () {
      expect(
        tablo.hesapla(
          unvan: 'Polis Memuru',
          derece: 1,
          kademe: 5,
          memurAylikKatsayisi: katsayi,
        ),
        isNull,
      );
    });

    test('tam bordro ile tahmini net ~84.936 (1/4 örnek)', () {
      final odeme = tablo.hesapla(
        unvan: 'Polis Memuru',
        derece: 1,
        kademe: 4,
        memurAylikKatsayisi: katsayi,
      )!;
      final donem = MaasDonemData(
        id: 't',
        etiket: 't',
        memurAylikKatsayisi: katsayi,
        tabanAylik: 22722.79,
        tahminiNetOrani: 0.73,
      );
      final m = hesaplaMaas(
        donem: donem,
        gostergePuan: odeme.gostergePuan.toDouble(),
        ekGostergeTl: odeme.ekGostergeTl,
        kidemAyligi: odeme.kidemAylik,
        ozelHizmetTazminati: odeme.ohtTl,
        ekOdeme: odeme.ekOdemeToplam,
        gvIstisnasi: odeme.gvIstisnasi,
        dvIstisnaMatrahi: odeme.dvIstisnaMatrahi,
        tahminiNetOraniOverride: odeme.tahminiNetBrutOrani,
      );
      expect(m.tahminiNet, closeTo(84936, 2500));
    });
  });
}
