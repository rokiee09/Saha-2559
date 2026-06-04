import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/araclar/idari_para_ceza/idari_para_ceza_data.dart';

void main() {
  const set = IdariParaCezaSet(
    yil: 2026,
    kaynak: 'test',
    kayitlar: [
      IdariParaCezaKayit(
        id: '2',
        kanunSayisi: '5326',
        kanun: 'KABAHATLER KANUNU',
        madde: 'Md. 33',
        kabahatAdi: 'DİLENCİLİK YAPMAK',
        cezaMiktari: 1764,
        kararVerenMakam: 'KOLLUK',
        itirazMercii: 'SULH CEZA MAHKEMESİ',
        itirazSuresi: '15 GÜN',
        odemeSuresi: '1 AY',
        belge: 'EK-2',
      ),
      IdariParaCezaKayit(
        id: '3',
        kanunSayisi: '5326',
        kanun: 'KABAHATLER KANUNU',
        madde: 'Md. 34',
        kabahatAdi: 'KUMAR OYNAMAK (HAYVAN DÖVÜŞTÜRMEK HARİÇ)',
        cezaMiktari: 11604,
        kararVerenMakam: 'KOLLUK',
        itirazMercii: 'SULH CEZA MAHKEMESİ',
        itirazSuresi: '15 GÜN',
        odemeSuresi: '1 AY',
        belge: 'EK-3',
      ),
    ],
  );

  test('dilencilik cezası sorgusu eşleşir', () {
    final hit = set.enIyiEslesme('dilencilik cezası ne kadar');
    expect(hit, isNotNull);
    expect(hit!.kabahatAdi, 'DİLENCİLİK YAPMAK');
    expect(hit.cezaMiktari, 1764);
  });

  test('ceza miktarı formatı', () {
    expect(formatCezaMiktari(1764), '1.764');
    expect(formatCezaMiktari(3705), '3.705');
    expect(formatCezaMiktari(100), '100');
  });

  test('kanun ve madde filtreleme', () {
    final items = set.filtrele(
      kanun: 'KABAHATLER KANUNU',
      madde: 'Md. 33',
    );
    expect(items.length, 1);
    expect(items.first.kabahatAdi, 'DİLENCİLİK YAPMAK');
  });

  test('ceza sıralama', () {
    final desc = set.filtrele(sirala: IdariParaCezaSirala.cezaDesc);
    expect(desc.first.cezaMiktari, 11604);
    final asc = set.filtrele(sirala: IdariParaCezaSirala.cezaAsc);
    expect(asc.first.cezaMiktari, 1764);
  });

  test('idari para sorgu anahtar kelimeleri', () {
    expect(idariParaCezaSorguMu('dilencilik cezası ne kadar'), isTrue);
    expect(idariParaCezaSorguMu('gözaltı müdafi'), isFalse);
  });
}
