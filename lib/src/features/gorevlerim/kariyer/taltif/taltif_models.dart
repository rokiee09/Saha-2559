class TaltifKayit {
  const TaltifKayit({
    required this.id,
    required this.tarihMs,
    required this.tutar,
    required this.verenMakam,
    required this.aciklama,
    required this.not,
    required this.createdAtMs,
    this.fotoPath = '',
    this.pdfPath = '',
  });

  final String id;
  final int tarihMs;
  final int tutar;
  final String verenMakam;
  final String aciklama;
  final String not;
  final String fotoPath;
  final String pdfPath;
  final int createdAtMs;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tarihMs': tarihMs,
        'tutar': tutar,
        'verenMakam': verenMakam,
        'aciklama': aciklama,
        'not': not,
        'fotoPath': fotoPath,
        'pdfPath': pdfPath,
        'createdAtMs': createdAtMs,
      };

  factory TaltifKayit.fromJson(Map<String, dynamic> j) => TaltifKayit(
        id: j['id'] as String? ?? '',
        tarihMs: (j['tarihMs'] as num?)?.toInt() ?? 0,
        tutar: (j['tutar'] as num?)?.toInt() ?? 0,
        verenMakam: j['verenMakam'] as String? ?? '',
        aciklama: j['aciklama'] as String? ?? '',
        not: j['not'] as String? ?? '',
        fotoPath: j['fotoPath'] as String? ?? '',
        pdfPath: j['pdfPath'] as String? ?? '',
        createdAtMs: (j['createdAtMs'] as num?)?.toInt() ?? 0,
      );
}

class TaltifOzet {
  const TaltifOzet({
    required this.toplamSayi,
    required this.toplamTutar,
    this.sonTarihMs = 0,
  });

  final int toplamSayi;
  final int toplamTutar;
  final int sonTarihMs;
}

String formatTaltifTutari(int tl) {
  final s = tl.toString();
  if (s.length <= 3) return s;
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

TaltifOzet hesaplaTaltif(List<TaltifKayit> kayitlar) {
  if (kayitlar.isEmpty) {
    return const TaltifOzet(toplamSayi: 0, toplamTutar: 0);
  }
  final sorted = [...kayitlar]..sort((a, b) => b.tarihMs.compareTo(a.tarihMs));
  return TaltifOzet(
    toplamSayi: kayitlar.length,
    toplamTutar: kayitlar.fold<int>(0, (sum, k) => sum + k.tutar),
    sonTarihMs: sorted.first.tarihMs,
  );
}
