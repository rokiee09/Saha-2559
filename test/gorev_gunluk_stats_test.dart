import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/gorevlerim/atis/atis_models.dart';
import 'package:coderipple/src/features/gorevlerim/atis/atis_store.dart';
import 'package:coderipple/src/features/gorevlerim/gunluk/gorev_gunluk_models.dart';
import 'package:coderipple/src/features/gorevlerim/gunluk/gorev_gunluk_stats.dart';

GorevGunlukKayit _k({
  required int day,
  required double saat,
  int month = 6,
  int year = 2026,
}) {
  return GorevGunlukKayit(
    id: 'x$day',
    tarihMs: DateTime(year, month, day).millisecondsSinceEpoch,
    saat: '08:00',
    gorevAdi: 'Nokta',
    sureSaat: saat,
    not: 'not',
    createdAtMs: 0,
    updatedAtMs: 0,
  );
}

void main() {
  test('ayIstatistik counts tasks and hours', () {
    final all = [
      _k(day: 10, saat: 8),
      _k(day: 12, saat: 10),
      _k(day: 12, saat: 4),
    ];
    final s = ayIstatistik(all, referans: DateTime(2026, 6, 15));
    expect(s.toplamGorev, 3);
    expect(s.toplamSaat, 22);
    expect(s.enYogunGunLabel, '12 Haziran');
  });

  test('atisDonemOzetleri marks completed periods', () {
    final all = [
      AtisKayit(
        id: '1',
        yil: 2026,
        donem: 1,
        tarihMs: DateTime(2026, 3, 1).millisecondsSinceEpoch,
        puan: 85,
        izinKullanildi: false,
        not: '',
        createdAtMs: 0,
        updatedAtMs: 0,
      ),
      AtisKayit(
        id: '2',
        yil: 2026,
        donem: 2,
        tarihMs: DateTime(2026, 6, 1).millisecondsSinceEpoch,
        puan: 90,
        izinKullanildi: true,
        not: '',
        createdAtMs: 0,
        updatedAtMs: 0,
      ),
    ];
    final ozet = atisDonemOzetleri(all, yil: 2026);
    expect(ozet[0].durum, AtisDonemDurum.tamamlandi);
    expect(ozet[1].durum, AtisDonemDurum.tamamlandi);
    expect(ozet[2].durum, AtisDonemDurum.bekliyor);
    expect(atisTamamlananDonemSayisi(all, yil: 2026), 2);
  });
}
