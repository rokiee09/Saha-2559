enum TelsizKodKategori {
  protokol,
  birim,
}

extension TelsizKodKategoriX on TelsizKodKategori {
  String get label => switch (this) {
        TelsizKodKategori.protokol => 'Protokol',
        TelsizKodKategori.birim => 'Birim',
      };
}

class TelsizKod {
  const TelsizKod({
    required this.kod,
    required this.anlam,
    required this.kategori,
    this.not,
  });

  final String kod;
  final String anlam;
  final TelsizKodKategori kategori;
  final String? not;
}

const kTelsizKodlari = <TelsizKod>[
  TelsizKod(
    kod: '32-10',
    anlam: 'Vali',
    kategori: TelsizKodKategori.protokol,
    not: 'İl protokol çağrı kodu.',
  ),
  TelsizKod(
    kod: '33-10',
    anlam: 'İl Emniyet Müdürü',
    kategori: TelsizKodKategori.protokol,
    not: 'Tüm illerde kullanılan il emniyet müdürü çağrı kodu.',
  ),
  TelsizKod(
    kod: '38',
    anlam: 'Çevik Kuvvet',
    kategori: TelsizKodKategori.birim,
  ),
  TelsizKod(
    kod: '48',
    anlam: 'Asayiş',
    kategori: TelsizKodKategori.birim,
  ),
  TelsizKod(
    kod: '54',
    anlam: 'Trafik',
    kategori: TelsizKodKategori.birim,
  ),
  TelsizKod(
    kod: '59',
    anlam: 'Bölge Trafik',
    kategori: TelsizKodKategori.birim,
  ),
];
