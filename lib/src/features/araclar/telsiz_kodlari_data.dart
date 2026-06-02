enum TelsizKodKategori {
  protokol,
  subeMuduru,
  buroAmiri,
}

extension TelsizKodKategoriX on TelsizKodKategori {
  String get label => switch (this) {
        TelsizKodKategori.protokol => 'Protokol',
        TelsizKodKategori.subeMuduru => 'Şube Müdürü',
        TelsizKodKategori.buroAmiri => 'Büro Amiri',
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



/// İl protokol hiyerarşisi — her zaman listenin başında, bu sırada.

const kTelsizKodlariProtokol = <TelsizKod>[

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

    kod: '33-20',

    anlam: 'İl Emniyet Müdür Yardımcıları',

    kategori: TelsizKodKategori.protokol,

  ),

  TelsizKod(

    kod: '33-70',

    anlam: 'Nöbetçi Müdür / Amir',

    kategori: TelsizKodKategori.protokol,

  ),

  TelsizKod(

    kod: '33-75',

    anlam: 'Nöbetçi Müdür / Amir Yardımcısı',

    kategori: TelsizKodKategori.protokol,

  ),

];



/// Protokol dışı kodlar — telsiz kod numarasına göre sıralı (33-50, 33-88, 36-10 …).

const kTelsizKodlariSirali = <TelsizKod>[

  TelsizKod(

    kod: '33-50',

    anlam: 'Bomba İmha Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '33-88',

    anlam: 'Rehberlik ve Psikolojik Danışmanlık Büro Amiri',

    kategori: TelsizKodKategori.buroAmiri,

  ),

  TelsizKod(

    kod: '33-90',

    anlam: 'Belge Yönetimi ve Koordinasyon Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '36-10',

    anlam: 'Siber Suçlarla Mücadele Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(
    kod: '37-10',
    anlam: 'İstihbarat Şube Müdürü',
    kategori: TelsizKodKategori.subeMuduru,
  ),
  TelsizKod(
    kod: '38-10',

    anlam: 'Terörle Mücadele Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '41-10',

    anlam: 'Güvenlik Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '44-10',

    anlam: 'Havalimanı Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '45-10',

    anlam: 'Asayiş Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '45-30',

    anlam: 'Cinayet ve Gasp Büro Amiri',

    kategori: TelsizKodKategori.buroAmiri,

  ),

  TelsizKod(

    kod: '45-60',

    anlam: 'Ahlak ve Kayıp Şahıslar Büro Amiri',

    kategori: TelsizKodKategori.buroAmiri,

  ),

  TelsizKod(

    kod: '46-30',

    anlam: 'Hırsızlık Büro Amiri',

    kategori: TelsizKodKategori.buroAmiri,

  ),

  TelsizKod(
    kod: '47-70',
    anlam: 'Aranan Şahıslar Büro Amiri',
    kategori: TelsizKodKategori.buroAmiri,
  ),
  TelsizKod(
    kod: '49-10',

    anlam: 'Olay Yeri İnceleme Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '50-10',

    anlam: 'Kaçakçılık ve Organize Suçlarla Mücadele Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '52-10',

    anlam: 'Narkotik Suçlarla Mücadele Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(
    kod: '53-60',
    anlam: 'Silah ve Patlayıcı Madde Şube Müdürü',
    kategori: TelsizKodKategori.subeMuduru,
  ),
  TelsizKod(
    kod: '54-10',
    anlam: 'Trafik Tesis Denetleme Şube Müdürü',
    kategori: TelsizKodKategori.subeMuduru,
  ),
  TelsizKod(
    kod: '59-10',

    anlam: 'Bölge Trafik Denetleme Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '62-10',

    anlam: 'Çevik Kuvvet Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '63-80',

    anlam: 'Spor Güvenliği Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '64-10',

    anlam: 'Koruma Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '65-10',

    anlam: 'Tanık Koruma Büro Amiri',

    kategori: TelsizKodKategori.buroAmiri,

  ),

  TelsizKod(

    kod: '65-50',

    anlam: 'Toplum Destekli Polislik Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '66-10',

    anlam: 'Çocuk Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '67-10',

    anlam: 'Personel Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '67-30',

    anlam: 'Hukuk İşleri Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '67-50',

    anlam: 'Sosyal Hizmetler Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '67-80',

    anlam: 'Özel Güvenlik Denetleme Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '68-10',

    anlam: 'Eğitim Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '68-50',

    anlam: 'Medya ve Halkla İlişkiler Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '69-10',

    anlam: 'Lojistik Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '70-10',

    anlam: 'Muharebe Elektronik Bilgi Sistemleri Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '70-90',

    anlam: 'Strateji Geliştirme Büro Amiri',

    kategori: TelsizKodKategori.buroAmiri,

  ),

  TelsizKod(

    kod: '71-10',

    anlam: 'Bilgi Teknolojileri Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

  TelsizKod(

    kod: '71-30',

    anlam: 'Belge Yönetimi Şube Müdürü',

    kategori: TelsizKodKategori.subeMuduru,

  ),

];

/// Tüm kodlar: protokol + şube/büro kodları.
List<TelsizKod> get kTelsizKodlari => [
      ...kTelsizKodlariProtokol,
      ...kTelsizKodlariSirali,
    ];


