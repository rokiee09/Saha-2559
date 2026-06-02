/// Yıllık atış dönemi kaydı (1–4. dönem).
class AtisKayit {
  const AtisKayit({
    required this.id,
    required this.yil,
    required this.donem,
    required this.tarihMs,
    required this.puan,
    required this.izinKullanildi,
    required this.not,
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  final String id;
  final int yil;
  final int donem;
  final int tarihMs;
  final double puan;
  final bool izinKullanildi;
  final String not;
  final int createdAtMs;
  final int updatedAtMs;

  DateTime get tarih => DateTime.fromMillisecondsSinceEpoch(tarihMs);

  Map<String, dynamic> toJson() => {
        'id': id,
        'yil': yil,
        'donem': donem,
        'tarihMs': tarihMs,
        'puan': puan,
        'izinKullanildi': izinKullanildi,
        'not': not,
        'createdAtMs': createdAtMs,
        'updatedAtMs': updatedAtMs,
      };

  factory AtisKayit.fromJson(Map<String, dynamic> j) => AtisKayit(
        id: j['id'] as String? ?? '',
        yil: (j['yil'] as num?)?.toInt() ?? DateTime.now().year,
        donem: (j['donem'] as num?)?.toInt() ?? 1,
        tarihMs: (j['tarihMs'] as num?)?.toInt() ?? 0,
        puan: (j['puan'] as num?)?.toDouble() ?? 0,
        izinKullanildi: j['izinKullanildi'] as bool? ?? false,
        not: j['not'] as String? ?? '',
        createdAtMs: (j['createdAtMs'] as num?)?.toInt() ?? 0,
        updatedAtMs: (j['updatedAtMs'] as num?)?.toInt() ?? 0,
      );
}

enum AtisDonemDurum { tamamlandi, bekliyor }

class AtisDonemOzet {
  const AtisDonemOzet({
    required this.donem,
    required this.durum,
    this.kayit,
  });

  final int donem;
  final AtisDonemDurum durum;
  final AtisKayit? kayit;
}

List<AtisDonemOzet> atisDonemOzetleri(List<AtisKayit> all, {int? yil}) {
  final y = yil ?? DateTime.now().year;
  final yearKayit = all.where((k) => k.yil == y).toList();
  return List.generate(4, (i) {
    final donem = i + 1;
    AtisKayit? found;
    for (final k in yearKayit) {
      if (k.donem == donem) {
        found = k;
        break;
      }
    }
    return AtisDonemOzet(
      donem: donem,
      durum:
          found != null ? AtisDonemDurum.tamamlandi : AtisDonemDurum.bekliyor,
      kayit: found,
    );
  });
}

int atisTamamlananDonemSayisi(List<AtisKayit> all, {int? yil}) {
  return atisDonemOzetleri(all, yil: yil)
      .where((d) => d.durum == AtisDonemDurum.tamamlandi)
      .length;
}
