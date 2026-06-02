/// Eğitim durumu seçenekleri.
enum EgitimDurumu {
  lise,
  onLisans,
  lisans,
  yuksekLisans,
  doktora,
}

extension EgitimDurumuX on EgitimDurumu {
  String get id => name;

  String get label => switch (this) {
        EgitimDurumu.lise => 'Lise',
        EgitimDurumu.onLisans => 'Ön Lisans',
        EgitimDurumu.lisans => 'Lisans',
        EgitimDurumu.yuksekLisans => 'Yüksek Lisans',
        EgitimDurumu.doktora => 'Doktora',
      };

  String get kisaLabel => switch (this) {
        EgitimDurumu.lise => 'Lise mezunu',
        EgitimDurumu.onLisans => 'Ön lisans mezunu',
        EgitimDurumu.lisans => 'Lisans mezunu',
        EgitimDurumu.yuksekLisans => 'Yüksek lisans mezunu',
        EgitimDurumu.doktora => 'Doktora mezunu',
      };

  static EgitimDurumu? fromId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final e in EgitimDurumu.values) {
      if (e.id == id) return e;
    }
    return null;
  }
}

/// Kariyer profilinde seçilebilir rütbeler ([RutbeRankIcon] ile eşleşir).
class KariyerRutbe {
  const KariyerRutbe({required this.id, required this.label, required this.levelIndex});

  final String id;
  final String label;
  final int levelIndex;

  static const List<KariyerRutbe> all = [
    KariyerRutbe(id: 'polis_memuru', label: 'Polis Memuru', levelIndex: 0),
    KariyerRutbe(id: 'baspolis', label: 'Başpolis', levelIndex: 1),
    KariyerRutbe(
        id: 'kideme_baspolis', label: 'Kıdemli Başpolis', levelIndex: 2),
    KariyerRutbe(
        id: 'komiser_yardimcisi', label: 'Komiser Yardımcısı', levelIndex: 3),
    KariyerRutbe(id: 'komiser', label: 'Komiser', levelIndex: 4),
    KariyerRutbe(id: 'baskomiser', label: 'Başkomiser', levelIndex: 5),
    KariyerRutbe(id: 'emniyet_amiri', label: 'Emniyet Amiri', levelIndex: 6),
    KariyerRutbe(
        id: 'dort_sinif', label: '4. Sınıf Emniyet Müdürü', levelIndex: 7),
    KariyerRutbe(
        id: 'uc_sinif', label: '3. Sınıf Emniyet Müdürü', levelIndex: 8),
    KariyerRutbe(
        id: 'iki_sinif', label: '2. Sınıf Emniyet Müdürü', levelIndex: 9),
    KariyerRutbe(
        id: 'bir_sinif', label: '1. Sınıf Emniyet Müdürü', levelIndex: 10),
  ];

  static KariyerRutbe? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final r in all) {
      if (r.id == id) return r;
    }
    return null;
  }
}
