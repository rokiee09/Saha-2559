class EgitimKayit {
  const EgitimKayit({
    required this.id,
    required this.ad,
    required this.kurum,
    required this.tarihMs,
    required this.sure,
    required this.aciklama,
    required this.createdAtMs,
    this.belgePath = '',
    this.sertifikaPath = '',
    this.sertifika = true,
  });

  final String id;
  final String ad;
  final String kurum;
  final int tarihMs;
  final String sure;
  final String aciklama;
  final String belgePath;
  final String sertifikaPath;
  final bool sertifika;
  final int createdAtMs;

  Map<String, dynamic> toJson() => {
        'id': id,
        'ad': ad,
        'kurum': kurum,
        'tarihMs': tarihMs,
        'sure': sure,
        'aciklama': aciklama,
        'belgePath': belgePath,
        'sertifikaPath': sertifikaPath,
        'sertifika': sertifika,
        'createdAtMs': createdAtMs,
      };

  factory EgitimKayit.fromJson(Map<String, dynamic> j) => EgitimKayit(
        id: j['id'] as String? ?? '',
        ad: j['ad'] as String? ?? '',
        kurum: j['kurum'] as String? ?? '',
        tarihMs: (j['tarihMs'] as num?)?.toInt() ?? 0,
        sure: j['sure'] as String? ?? '',
        aciklama: j['aciklama'] as String? ?? '',
        belgePath: j['belgePath'] as String? ?? '',
        sertifikaPath: j['sertifikaPath'] as String? ?? '',
        sertifika: j['sertifika'] as bool? ?? true,
        createdAtMs: (j['createdAtMs'] as num?)?.toInt() ?? 0,
      );
}

class EgitimIstatistik {
  const EgitimIstatistik({
    required this.toplamEgitim,
    required this.toplamSertifika,
    this.sonKayitAd,
  });

  final int toplamEgitim;
  final int toplamSertifika;
  final String? sonKayitAd;
}

EgitimIstatistik egitimIstatistik(List<EgitimKayit> list) {
  final egitim = list.where((e) => !e.sertifika).length;
  final sert = list.where((e) => e.sertifika).length;
  final sorted = [...list]..sort((a, b) => b.tarihMs.compareTo(a.tarihMs));
  return EgitimIstatistik(
    toplamEgitim: egitim,
    toplamSertifika: sert,
    sonKayitAd: sorted.isEmpty ? null : sorted.first.ad,
  );
}
