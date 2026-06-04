import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/map/il_telefonlari.dart';
import '../../common/text/tr_text.dart';
import '../araclar/gorev_puanlari/gorev_puanlari_data.dart';
import 'il_analiz_display.dart';
import 'il_analiz_models.dart';
import 'tazminat_dereceleri_data.dart';
import 'yasam_indeksi_data.dart';

const _assetPath = 'assets/json/il_analiz.json';

/// Tüm iller (81) — profilli olanlar önce.
class IlAnalizKatalog {
  const IlAnalizKatalog({
    required this.kaynakNotu,
    required this.iller,
    required this.profilMap,
  });

  final String kaynakNotu;
  final List<IlAnalizOzet> iller;
  final Map<String, IlAnalizProfil> profilMap;

  IlAnalizProfil? profil(String id) => profilMap[id];

  List<IlAnalizOzet> ara(String query) {
    final q = trFold(query.trim());
    if (q.isEmpty) return iller;
    return iller
        .where((i) =>
            trFold(i.ad).contains(q) ||
            i.plaka.contains(q) ||
            trFold(i.id).contains(q))
        .toList();
  }

  List<IlAnalizOzet> hazirProfiller() =>
      iller.where((i) => i.hazir).toList();
}

Future<IlAnalizKatalog> loadIlAnalizKatalog() async {
  final raw = await rootBundle.loadString(_assetPath);
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final profilMap = <String, IlAnalizProfil>{};
  for (final e in (json['iller'] as List<dynamic>? ?? const [])) {
    if (e is! Map<String, dynamic>) continue;
    final p = IlAnalizProfil.fromJson(e);
    if (p.id.isEmpty || p.id == 'ornek_il') continue;
    profilMap[p.id] = p;
  }

  final iller = <IlAnalizOzet>[];
  for (final e in plakaToIlKey.entries) {
    final plaka = e.key;
    final key = e.value;
    final ad = _ilAdFromKey(key);
    final id = key;
    iller.add(
      IlAnalizOzet(
        id: id,
        ad: ad,
        plaka: plaka,
        profil: profilMap[id],
      ),
    );
  }
  iller.sort((a, b) {
    if (a.hazir != b.hazir) return a.hazir ? -1 : 1;
    return trFold(a.ad).compareTo(trFold(b.ad));
  });

  return IlAnalizKatalog(
    kaynakNotu: json['kaynakNotu'] as String? ?? '',
    iller: iller,
    profilMap: profilMap,
  );
}

String _ilAdFromKey(String key) {
  const ozel = {
    'adana': 'Adana',
    'adiyaman': 'Adıyaman',
    'ankara': 'Ankara',
    'antalya': 'Antalya',
    'aydin': 'Aydın',
    'balikesir': 'Balıkesir',
    'bilecik': 'Bilecik',
    'bingol': 'Bingöl',
    'bitlis': 'Bitlis',
    'canakkale': 'Çanakkale',
    'cankiri': 'Çankırı',
    'corum': 'Çorum',
    'denizli': 'Denizli',
    'diyarbakir': 'Diyarbakır',
    'duzce': 'Düzce',
    'edirne': 'Edirne',
    'elazig': 'Elazığ',
    'erzincan': 'Erzincan',
    'erzurum': 'Erzurum',
    'eskisehir': 'Eskişehir',
    'gaziantep': 'Gaziantep',
    'giresun': 'Giresun',
    'gumushane': 'Gümüşhane',
    'hakkari': 'Hakkâri',
    'hatay': 'Hatay',
    'isparta': 'Isparta',
    'istanbul': 'İstanbul',
    'izmir': 'İzmir',
    'kahramanmaras': 'Kahramanmaraş',
    'karabuk': 'Karabük',
    'karaman': 'Karaman',
    'kars': 'Kars',
    'kastamonu': 'Kastamonu',
    'kayseri': 'Kayseri',
    'kilis': 'Kilis',
    'kirikkale': 'Kırıkkale',
    'kirklareli': 'Kırklareli',
    'kirsehir': 'Kırşehir',
    'kocaeli': 'Kocaeli',
    'konya': 'Konya',
    'kutahya': 'Kütahya',
    'malatya': 'Malatya',
    'manisa': 'Manisa',
    'mardin': 'Mardin',
    'mersin': 'Mersin',
    'mugla': 'Muğla',
    'mus': 'Muş',
    'nevsehir': 'Nevşehir',
    'nigde': 'Niğde',
    'ordu': 'Ordu',
    'osmaniye': 'Osmaniye',
    'rize': 'Rize',
    'sakarya': 'Sakarya',
    'samsun': 'Samsun',
    'sanliurfa': 'Şanlıurfa',
    'siirt': 'Siirt',
    'sinop': 'Sinop',
    'sirnak': 'Şırnak',
    'sivas': 'Sivas',
    'tekirdag': 'Tekirdağ',
    'tokat': 'Tokat',
    'trabzon': 'Trabzon',
    'tunceli': 'Tunceli',
    'usak': 'Uşak',
    'van': 'Van',
    'yozgat': 'Yozgat',
    'zonguldak': 'Zonguldak',
    'afyonkarahisar': 'Afyonkarahisar',
    'agri': 'Ağrı',
    'aksaray': 'Aksaray',
    'amasya': 'Amasya',
    'artvin': 'Artvin',
    'bartin': 'Bartın',
    'batman': 'Batman',
    'bayburt': 'Bayburt',
    'burdur': 'Burdur',
    'bursa': 'Bursa',
    'igdir': 'Iğdır',
    'yalova': 'Yalova',
  };
  if (ozel.containsKey(key)) return ozel[key]!;
  if (key.isEmpty) return key;
  return key[0].toUpperCase() + key.substring(1);
}

final ilAnalizKatalogProvider = FutureProvider<IlAnalizKatalog>((ref) async {
  final katalog = await loadIlAnalizKatalog();
  GorevPuanlariSet? gorev;
  TazminatDereceleriSet? tazminat;
  YasamIndeksiSet? yasam;
  try {
    gorev = await ref.watch(gorevPuanlariByYilProvider(2026).future);
  } catch (_) {}
  try {
    tazminat = await ref.watch(tazminatDereceleriProvider.future);
  } catch (_) {}
  try {
    yasam = await ref.watch(yasamIndeksiProvider.future);
  } catch (_) {}
  return _mergeIlAnalizKaynaklari(katalog, gorev, tazminat, yasam);
});

bool _polisTlDolu(int? v) => v != null && v > 0;

IlAnalizPolis _mergePolisAlanlari(
  IlAnalizPolis polis, {
  int? gorevPuani,
  int? ekTazminatTl,
  int? tazminatDerece,
}) {
  return IlAnalizPolis(
    gorevPuani: gorevPuani ?? polis.gorevPuani,
    gorevSuresiYil: polis.gorevSuresiYil,
    mudurluk: polis.mudurluk,
    amirlik: polis.amirlik,
    ekTazminatTl: ekTazminatTl ??
        (_polisTlDolu(polis.ekTazminatTl) ? polis.ekTazminatTl : null),
    tazminatDerece: tazminatDerece ?? polis.tazminatDerece,
    lojmanSayisi: polis.lojmanSayisi,
    lojmanDurumu: polis.lojmanDurumu,
    lojmanBeklemeYil: polis.lojmanBeklemeYil,
    calismaSistemi: polis.calismaSistemi,
    mesai: polis.mesai,
    anons: polis.anons,
    uygulama: polis.uygulama,
    isYuku: polis.isYuku,
    sucTuru: polis.sucTuru,
    kaynak: polis.kaynak,
  );
}

IlAnalizProfil _stubProfil(IlAnalizOzet o) {
  return IlAnalizProfil(
    id: o.id,
    ad: o.ad,
    plaka: o.plaka,
    puanlar: const IlAnalizPuanlar(),
    genel: const IlAnalizGenel(),
    ekonomi: const IlAnalizEkonomi(),
    saglik: const IlAnalizSaglik(),
    egitim: const IlAnalizEgitim(),
    sosyal: const IlAnalizSosyal(),
    polis: const IlAnalizPolis(),
    guvenlik: const IlAnalizGuvenlik(),
    ilceler: const [],
  );
}

IlAnalizProfil _profilWithPolis(IlAnalizProfil p, IlAnalizPolis polis) {
  return IlAnalizProfil(
    id: p.id,
    ad: p.ad,
    plaka: p.plaka,
    detayliProfil: p.detayliProfil,
    bolge: p.bolge,
    buyuksehir: p.buyuksehir,
    puanlar: p.puanlar,
    genel: p.genel,
    ekonomi: p.ekonomi,
    saglik: p.saglik,
    egitim: p.egitim,
    sosyal: p.sosyal,
    polis: polis,
    guvenlik: p.guvenlik,
    ozetAi: p.ozetAi,
    ilceler: p.ilceler,
  );
}

IlAnalizGenel _mergeGenelAlanlari(
  IlAnalizGenel genel, {
  int? yasamIndeksiSira,
  int? yasamIndeksiYil,
}) {
  return IlAnalizGenel(
    nufus: genel.nufus,
    yuzolcumuKm2: genel.yuzolcumuKm2,
    ilceSayisi: genel.ilceSayisi,
    rakimM: genel.rakimM,
    kalkinmadaOncelikli: genel.kalkinmadaOncelikli,
    yasamIndeksiSira: genel.yasamIndeksiSira ?? yasamIndeksiSira,
    yasamIndeksiYil: genel.yasamIndeksiYil ?? yasamIndeksiYil,
    kaynak: genel.kaynak,
  );
}

IlAnalizProfil _profilWithGenel(IlAnalizProfil p, IlAnalizGenel genel) {
  return IlAnalizProfil(
    id: p.id,
    ad: p.ad,
    plaka: p.plaka,
    detayliProfil: p.detayliProfil,
    bolge: p.bolge,
    buyuksehir: p.buyuksehir,
    puanlar: p.puanlar,
    genel: genel,
    ekonomi: p.ekonomi,
    saglik: p.saglik,
    egitim: p.egitim,
    sosyal: p.sosyal,
    polis: p.polis,
    guvenlik: p.guvenlik,
    ozetAi: p.ozetAi,
    ilceler: p.ilceler,
  );
}

IlAnalizKatalog _mergeIlAnalizKaynaklari(
  IlAnalizKatalog katalog,
  GorevPuanlariSet? gorev,
  TazminatDereceleriSet? tazminat,
  YasamIndeksiSet? yasam,
) {
  final map = Map<String, IlAnalizProfil>.from(katalog.profilMap);
  for (final il in katalog.iller) {
    var p = map[il.id] ?? _stubProfil(il);
    var polis = p.polis;
    var genel = p.genel;

    if (gorev != null) {
      final kayit = gorev.bul(p.ad);
      if (kayit != null) {
        polis = _mergePolisAlanlari(
          polis,
          gorevPuani: (kayit.puan * 1000).round(),
        );
      }
    }

    if (tazminat != null) {
      final tz = tazminatForIlId(p.id, tazminat);
      if (tz != null && tz.varMi) {
        polis = _mergePolisAlanlari(
          polis,
          ekTazminatTl:
              _polisTlDolu(polis.ekTazminatTl) ? polis.ekTazminatTl : tz.ekOdemeTl,
          tazminatDerece: polis.tazminatDerece ?? tz.derece,
        );
      }
    }

    if (yasam != null && genel.yasamIndeksiSira == null) {
      final yi = yasamIndeksiForIlId(p.id, yasam);
      if (yi != null) {
        genel = _mergeGenelAlanlari(
          genel,
          yasamIndeksiSira: yi.sira,
          yasamIndeksiYil: yasam.yil,
        );
      }
    }

    if (polis != p.polis) {
      p = _profilWithPolis(p, polis);
    }
    if (genel != p.genel) {
      p = _profilWithGenel(p, genel);
    }
    map[il.id] = p;
  }

  final iller = katalog.iller
      .map(
        (o) => IlAnalizOzet(
          id: o.id,
          ad: o.ad,
          plaka: o.plaka,
          profil: map[o.id],
        ),
      )
      .toList();
  return IlAnalizKatalog(
    kaynakNotu: katalog.kaynakNotu,
    iller: iller,
    profilMap: map,
  );
}

// Geriye dönük — boş alan boş string (satır gizlenir).
String formatNufus(int? n) => formatIlNufus(n);
String formatTl(int? v) => formatIlTl(v);
