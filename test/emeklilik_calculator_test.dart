import 'package:coderipple/src/features/gorevlerim/emeklilik/emeklilik_calculator.dart';
import 'package:coderipple/src/features/gorevlerim/kariyer/kariyer_profil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('zorunlu hizmet 20 yıl meslek girişinden', () {
    final profil = KariyerProfil(
      rutbeId: 'polis_memuru',
      gorevBaslamaMs: DateTime(2017, 3, 21).millisecondsSinceEpoch,
      dogumTarihiMs: DateTime(1993, 7, 2).millisecondsSinceEpoch,
    );
    final d = hesaplaEmeklilik(profil, DateTime(2026, 3, 21))!;
    expect(formatTrTarih(d.zorunluHizmet.bitis), '21.03.2037');
    expect(formatTrTarih(d.yasHaddi.bitis), '02.07.2048');
    expect(d.yasHaddiYas, 55);
  });

  test('yaş haddi 56 komiser için', () {
    expect(emeklilikYasHaddi('komiser'), 56);
    expect(emeklilikYasHaddi('bir_sinif'), 65);
  });

  test('2048 önce emeklilik tarihi zorunlu hizmet', () {
    final profil = KariyerProfil(
      rutbeId: 'polis_memuru',
      gorevBaslamaMs: DateTime(2017, 3, 21).millisecondsSinceEpoch,
      dogumTarihiMs: DateTime(1993, 7, 2).millisecondsSinceEpoch,
    );
    final d = hesaplaEmeklilik(profil, DateTime(2026, 6, 2))!;
    expect(d.emeklilikTarihi, DateTime(2037, 3, 21));
    expect(d.zorunluHizmet.kalan.years, 10);
    expect(d.zorunluHizmet.kalan.months, greaterThanOrEqualTo(0));
  });
}
