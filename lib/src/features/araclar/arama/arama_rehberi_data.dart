import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Arama türü — hızlı kontrol ve checklist için.
enum AramaTuru {
  arac,
  ev,
  ust,
  isyeri,
}

extension AramaTuruX on AramaTuru {
  String get id => name;

  String get title => switch (this) {
        AramaTuru.arac => 'Araç Araması',
        AramaTuru.ev => 'Ev Araması',
        AramaTuru.ust => 'Üst Araması',
        AramaTuru.isyeri => 'İşyeri Araması',
      };

  IconData get icon => switch (this) {
        AramaTuru.arac => PhosphorIconsRegular.car,
        AramaTuru.ev => PhosphorIconsRegular.house,
        AramaTuru.ust => PhosphorIconsRegular.user,
        AramaTuru.isyeri => PhosphorIconsRegular.storefront,
      };
}

class AramaHukukiOzet {
  const AramaHukukiOzet({
    required this.baslik,
    required this.aciklama,
    required this.hakimKarari,
    required this.savciTalimati,
    required this.cmk,
    required this.pvsk,
  });

  final String baslik;
  final String aciklama;
  final String hakimKarari;
  final String savciTalimati;
  final String cmk;
  final String pvsk;
}

class AramaMevzuatRef {
  const AramaMevzuatRef({
    required this.label,
    required this.entryId,
    this.sectionId,
  });

  final String label;
  final String entryId;
  final String? sectionId;
}

class AramaSenaryo {
  const AramaSenaryo({
    required this.id,
    required this.baslik,
    required this.anahtarlar,
    required this.ozet,
    required this.mevzuatNotlari,
  });

  final String id;
  final String baslik;
  final List<String> anahtarlar;
  final String ozet;
  final List<String> mevzuatNotlari;
}

const kAramaMevzuatRefs = <AramaMevzuatRef>[
  AramaMevzuatRef(
    label: 'CMK (5271)',
    entryId: 'kanun-cmk',
  ),
  AramaMevzuatRef(
    label: 'CMK md. 116–118 (Adli arama)',
    entryId: 'kanun-cmk',
  ),
  AramaMevzuatRef(
    label: 'PVSK md. 9',
    entryId: 'kanun-pvsk',
    sectionId: 'pvsk-9',
  ),
  AramaMevzuatRef(
    label: 'Adli ve Önleme Aramaları Yönetmeliği',
    entryId: 'yonetmelik-adli_arama',
    sectionId: 'aay-1',
  ),
];

AramaHukukiOzet hukukiOzet(AramaTuru tur) => switch (tur) {
      AramaTuru.arac => const AramaHukukiOzet(
            baslik: 'Araç araması',
            aciklama:
                'Adli arama ile önleme araması usulleri farklıdır. Araçta '
                'suç unsuru şüphesi varsa adli arama usulü; önleyici '
                'denetimlerde farklı dayanaklar devreye girebilir.',
            hakimKarari:
                'Adli arama: CMK uyarınca genellikle hâkim kararı gerekir '
                '(istisnalar mevzuatta sayılıdır).',
            savciTalimati:
                'Gecikmesinde sakınca bulunan hâllerde Cumhuriyet savcısı '
                'talimatı ile adli arama yapılabilir; karar sonradan '
                'onaylatılır.',
            cmk: 'Adli arama: CMK ve Adli/Önleme Aramaları Yönetmeliği.',
            pvsk:
                'Kanuna aykırı silah/tehlikeli eşya tespitinde PVSK md. 9 '
                'kapsamında el koyma söz konusu olabilir; tam arama usulü '
                'ayrıca değerlendirilmelidir.',
          ),
      AramaTuru.ev => const AramaHukukiOzet(
            baslik: 'Ev / konut araması',
            aciklama:
                'Konutta arama, anayasal dokunulmazlık nedeniyle sıkı '
                'şekil şartlarına tabidir. Karar kapsamı, süre ve tutanak '
                'zorunluluğu gözetilmelidir.',
            hakimKarari:
                'Adli arama: Kural olarak hâkim kararı şarttır (CMK).',
            savciTalimati:
                'Gecikmesinde sakınca bulunan hâllerde savcı talimatı '
                'mümkün olabilir; usul sonradan tamamlanır.',
            cmk: 'CMK adli arama hükümleri + Yönetmelik.',
            pvsk: 'Önleme araması farklı rejimde; PVSK md. 4 vd. yetkiler '
                'ayrı değerlendirilir.',
          ),
      AramaTuru.ust => const AramaHukukiOzet(
            baslik: 'Üst araması',
            aciklama:
                'Şüphe halinde üst arama PVSK md. 9 kapsamında mümkündür. '
                'Adli arama niteliğinde geniş kapsamlı arama ile karıştırılmamalıdır.',
            hakimKarari:
                'Basit üst arama (PVSK): Hâkim kararı genellikle gerekmez.',
            savciTalimati:
                'Adli nitelik kazanan genişletilmiş işlemlerde CMK usulü '
                'devreye girebilir.',
            cmk: 'CMK; adli arama boyutuna geçildiğinde uygulanır.',
            pvsk: 'PVSK md. 9 — şüpheli eşya/silah tespiti ve el koyma.',
          ),
      AramaTuru.isyeri => const AramaHukukiOzet(
            baslik: 'İşyeri araması',
            aciklama:
                'İşyeri adli araması konut aramasına benzer şekilde karar '
                've kapsam ile sınırlıdır. Mesai saati, yetkili temsilci '
                've tutanak düzenlenmelidir.',
            hakimKarari:
                'Adli arama: CMK uyarınca hâkim kararı esastır.',
            savciTalimati:
                'Gecikmesinde sakınca bulunan hâllerde savcı talimatı.',
            cmk: 'CMK + Adli/Önleme Aramaları Yönetmeliği.',
            pvsk: 'Önleme araması ayrı usule tabidir.',
          ),
    };

List<String> checklistFor(AramaTuru tur) => switch (tur) {
      AramaTuru.arac => [
            'Arama sebebi / şüphe somut mu?',
            'Adli mi önleme mi? Dayanak belirlendi mi?',
            'Hâkim kararı veya savcı talimatı hazır mı?',
            'Araç sahibi / kullanıcısı tespit edildi mi?',
            'Arama tutanağı ve zapt tutulacak mı?',
            'Tanık / kolluk görevlisi sayısı yeterli mi?',
            'Bodycam / olay yeri kaydı var mı?',
          ],
      AramaTuru.ev => [
            'Hâkim kararı kapsamı yer ve eşya ile uyumlu mu?',
            'Gecikmesinde sakınca varsa savcı talimatı alındı mı?',
            'Konutta bulunanlar bilgilendirildi mi?',
            'Arama tutanağı düzenleniyor mu?',
            'El konulan eşya zapt ve muhafaza altına alındı mı?',
            'Tanık bulunduruldu mu?',
            'Kamera / ses kaydı alındı mı?',
          ],
      AramaTuru.ust => [
            'Şüphe somut ve güncel mi (PVSK md. 9)?',
            'Arama sınırlı mı (üst / eşya)?',
            'Kişi bilgilendirildi mi?',
            'El konulan eşya tutanağı tutuldu mu?',
            'Cinsiyet / ölçülülük kuralları gözetildi mi?',
            'Gerekirse adli arama boyutuna geçiş değerlendirildi mi?',
          ],
      AramaTuru.isyeri => [
            'Karar / talimat kapsamı işyeri ile uyumlu mu?',
            'Yetkili temsilci veya çalışan bilgilendirildi mi?',
            'Arama saati ve mesai durumu kayda geçti mi?',
            'Tutanak ve zapt hazır mı?',
            'Ticari sır / kayıt kapsamı gözetildi mi?',
            'Tanık / kayıt alındı mı?',
          ],
    };

const kAramaSenaryolari = <AramaSenaryo>[
  AramaSenaryo(
    id: 'arac_uyusturucu',
    baslik: 'Araçta uyuşturucu şüphesi',
    anahtarlar: ['uyuşturucu', 'uyusturucu', 'araç', 'arac', 'madde'],
    ozet:
        'Adli arama usulü değerlendirilmelidir. CMK kapsamında karar veya '
        'gecikmesinde sakınca hâlinde savcı talimatı; arama sonrası tutanak, '
        'zapt ve muhafaza zinciri kurulmalıdır. TCK md. 188 kapsamındaki '
        'suç unsuru ayrıca raporlanır.',
    mevzuatNotlari: [
      'CMK adli arama hükümleri',
      'Adli ve Önleme Aramaları Yönetmeliği',
      'TCK md. 188 (Uyuşturucu)',
      'El koyma ve muhafaza tutanakları',
    ],
  ),
  AramaSenaryo(
    id: 'arac_silah',
    baslik: 'Araçta silah şüphesi',
    anahtarlar: ['silah', 'tabanca', 'tüfek', 'arac', 'araç'],
    ozet:
        'PVSK md. 9 kapsamında kanuna aykırı silah tespitinde el koyma '
        'söz konusu olabilir. Kapsamlı arama adli usule tabidir; 6136 sayılı '
        'Kanun kapsamı değerlendirilir.',
    mevzuatNotlari: [
      'PVSK md. 9',
      'CMK adli arama',
      '6136 sayılı Kanun',
    ],
  ),
  AramaSenaryo(
    id: 'ev_adli',
    baslik: 'Konutta adli arama',
    anahtarlar: ['ev', 'konut', 'daire', 'adli', 'hakim'],
    ozet:
        'Konut araması hâkim kararı ile sınırlıdır. Kararda yer, eşya ve '
        'süre açık olmalı; arama defteri ve tutanak düzenlenmelidir.',
    mevzuatNotlari: [
      'CMK adli arama (md. 116 vd.)',
      'Adli ve Önleme Aramaları Yönetmeliği',
    ],
  ),
  AramaSenaryo(
    id: 'ust_genel',
    baslik: 'Şüpheli üst araması',
    anahtarlar: ['üst', 'ust', 'şüphe', 'suphe', 'serseri'],
    ozet:
        'PVSK md. 9 uyarınca şüphe halinde üst aranabilir. İşlem ölçülü '
        'olmalı; el konulan eşya tutanağa bağlanmalıdır.',
    mevzuatNotlari: [
      'PVSK md. 9',
      'El koyma tutanağı',
    ],
  ),
];

List<AramaSenaryo> aramaSenaryoEslestir(String query) {
  final q = query.toLowerCase();
  if (q.trim().length < 3) return [];
  final out = <AramaSenaryo>[];
  for (final s in kAramaSenaryolari) {
    for (final k in s.anahtarlar) {
      if (q.contains(k)) {
        out.add(s);
        break;
      }
    }
  }
  return out;
}
