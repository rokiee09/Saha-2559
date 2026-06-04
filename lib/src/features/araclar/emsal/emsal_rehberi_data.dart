/// Anonimleştirilmiş uygulama özeti — yargı kararı veya resmî emsal değildir.
class EmsalKayit {
  const EmsalKayit({
    required this.id,
    required this.title,
    required this.situation,
    required this.summary,
    required this.checklist,
    required this.keywords,
    required this.tags,
    this.mevzuatRefs = const [],
    this.riskNote = '',
  });

  final String id;
  final String title;
  final String situation;
  final String summary;
  final List<String> checklist;
  final List<String> keywords;
  final List<String> tags;
  final List<EmsalMevzuatRef> mevzuatRefs;
  final String riskNote;
}

class EmsalMevzuatRef {
  const EmsalMevzuatRef({
    this.entryId,
    this.sectionId,
    required this.label,
  });

  final String? entryId;
  final String? sectionId;
  final String label;
}

const kEmsalKayitlari = <EmsalKayit>[
  EmsalKayit(
    id: 'yediemin_teslim',
    title: 'Yediemin — başka il mahkeme kararı ile teslim',
    situation:
        'Adli emanetteki araç için başka ilde verilmiş infaz kararı geldi; '
        'yerel savcı talimatı gerekir mi?',
    summary:
        'Önce karar metninde teslim/iade hükmü ve kesinleşme şerhi kontrol edilir. '
        'Başka il kararında infaz yazışması yapılır; savcı talimatı her dosyada '
        'otomatik şart değildir ancak koordinasyon eksikliği işlemi durdurur.',
    checklist: [
      'Karar–emanet araç bilgisi eşleşiyor mu?',
      'Infaz mercii ve dosya numarası yazışmada var mı?',
      'Teslim tutanağı ve zimmet kaydı tamamlandı mı?',
      'Keyfi teslimden kaçınıldı — belirsizlikte üst amir/savcıya danışıldı mı?',
    ],
    keywords: [
      'yediemin',
      'arac teslim',
      'mahkeme karari',
      'baska il',
      'savci talimati',
      'infaz',
    ],
    tags: ['yediemin', 'cmk', 'infaz'],
    mevzuatRefs: [
      EmsalMevzuatRef(
        entryId: 'kanun-cmk',
        sectionId: 'cmk-128',
        label: 'CMK — emanetteki eşya',
      ),
    ],
    riskNote: 'Karar infaza elverişli değilse teslim yapılmamalı.',
  ),
  EmsalKayit(
    id: 'kimlik_vermeyen',
    title: 'Kimlik vermeyen şahıs — durdurma ve tespit',
    situation: 'Durdurulan şahıs kimlik ibraz etmiyor; işlem nasıl ilerler?',
    summary:
        'Durdurma makul sebebe dayanmalı; kimlik tespiti PVSK çerçevesinde '
        'yürütülür. Bilgi vermeyen şahısta usul ve süre CMK ile birlikte '
        'değerlendirilir; zor kullanımı orantılılık ilkesine tabidir.',
    checklist: [
      'Durdurma gerekçesi tutanağa yazıldı mı?',
      'Kimlik tespit tutanağı veya beyan alındı mı?',
      'Gözaltı süresi ve müdafi bildirimi CMK ile uyumlu mu?',
      'Ses/görüntü kaydı kurum talimatına uygun mu?',
    ],
    keywords: [
      'kimlik vermeyen',
      'kimlik sorma',
      'durdurma',
      'tespit',
      'mukavemet',
    ],
    tags: ['pvsk', 'cmk', 'kimlik'],
    mevzuatRefs: [
      EmsalMevzuatRef(
        entryId: 'kanun-pvsk',
        sectionId: 'pvsk-4a',
        label: 'PVSK md. 4/A',
      ),
    ],
  ),
  EmsalKayit(
    id: 'alkollu_surucu',
    title: 'Alkollü sürücü — trafik ve disiplin ayrımı',
    situation:
        'Trafik kontrolünde alkollü sürücü tespit edildi; hem ceza hem özlük soruluyor.',
    summary:
        'Trafik/adli işlem (ölçüm, tutanak, idari yaptırım) ile personel disiplin '
        'süreci ayrı yürütülür. Olay tutanağı, alkol raporu ve delil zinciri tamamlanır.',
    checklist: [
      'Alkol ölçümü ve cihaz kayıtları alındı mı?',
      'Trafik tutanağı ve idari işlem dosyası açıldı mı?',
      'Personel ise disiplin ön raporu ayrı mı?',
      'Araç güvenliği ve trafik akışı sağlandı mı?',
    ],
    keywords: [
      'alkol',
      'alkollu',
      'surucu',
      'trafik',
      'disiplin',
    ],
    tags: ['trafik', 'disiplin', 'idari_para'],
    mevzuatRefs: [
      EmsalMevzuatRef(
        entryId: 'kanun-tck',
        label: 'TCK — trafik güvenliği',
      ),
    ],
  ),
  EmsalKayit(
    id: 'gec_kalma_disiplin',
    title: 'İşe geç kalma — disiplin kademesi',
    situation: 'Memur tekrarlayan geç kalmalarda hangi ceza gündeme gelir?',
    summary:
        '7068 kapsamında fiilin niteliği ve tekrarına göre uyarma, kınama veya '
        'aylıktan kesme değerlendirilir. Önceki disiplin kaydı ve süre önemlidir.',
    checklist: [
      'Giriş kayıtları / nöbet defteri incelendi mi?',
      'Ön rapor ve savunma hakkı tanındı mı?',
      'Fiil–ceza eşlemesi 7068 md. 8 ile uyumlu mu?',
      'Emniyet iç yöneriği ile çelişen işlem yapılmadı mı?',
    ],
    keywords: [
      'gec kalma',
      'gec kaldim',
      'disiplin',
      'uyarma',
      'kinama',
    ],
    tags: ['disiplin', 'dmk'],
    mevzuatRefs: [
      EmsalMevzuatRef(
        entryId: 'kanun-disiplin',
        label: '7068 Disiplin Kanunu',
      ),
    ],
  ),
  EmsalKayit(
    id: 'onleme_arama',
    title: 'Önleme araması — karar ve süre',
    situation: 'Silah/uyuşturucu şüphesiyle konut veya iş yeri aranacak.',
    summary:
        'Önleme araması yönetmelikteki usule ve yazılı karar/ yetki şartlarına '
        'bağlıdır. El koyma ve tutanak PVSK ile uyumlu tamamlanır.',
    checklist: [
      'Arama türü (adli/önleme) doğru sınıflandırıldı mı?',
      'Karar veya yetki belgesi dosyada mı?',
      'Arama tutanağı ve el koyma listesi düzenlendi mi?',
      'Müdahale orantılı ve kayıt altında mı?',
    ],
    keywords: [
      'onleme aramasi',
      'arama karari',
      'el koyma',
      'konut',
    ],
    tags: ['arama', 'pvsk', 'cmk'],
    mevzuatRefs: [
      EmsalMevzuatRef(
        entryId: 'yonetmelik-adli_arama',
        label: 'Adli ve Önleme Aramaları Yönetmeliği',
      ),
    ],
  ),
  EmsalKayit(
    id: 'refakat_sure',
    title: 'Refakat izni — rapor süresi',
    situation:
        'Hasta yakını refakat izni kaç gün; rapor bitince izin sona erer mi?',
    summary:
        'DMK m. 104 ve sağlık raporu birlikte değerlendirilir. Süre raporda '
        'belirtilir; taburcu veya sevk ile izin sonlandırılır.',
    checklist: [
      'Rapor refakat için uygun mu?',
      'Yakınlık derecesi ve bakım ihtiyacı belgelendi mi?',
      'İzin kaydı özlük birimine iletildi mi?',
      'Süre uzatımı için yeni rapor var mı?',
    ],
    keywords: [
      'refakat',
      'refakat izni',
      'hasta yakini',
      'rapor',
    ],
    tags: ['izinler', 'saglik', 'dmk'],
    mevzuatRefs: [
      EmsalMevzuatRef(
        entryId: 'kanun-dmk',
        sectionId: 'dmk-104',
        label: 'DMK md. 104',
      ),
    ],
  ),
];

List<EmsalKayit> emsalEslestir(String query) {
  final q = query.trim().toLowerCase();
  if (q.length < 2) return const [];
  final tokens = q.split(RegExp(r'\s+')).where((t) => t.length >= 2).toList();
  final out = <EmsalKayit>[];
  for (final e in kEmsalKayitlari) {
    final blob = '${e.title} ${e.situation} ${e.keywords.join(' ')}'.toLowerCase();
    final match = blob.contains(q) ||
        e.keywords.any((k) => k.contains(q)) ||
        (tokens.isNotEmpty && tokens.every((t) => blob.contains(t)));
    if (match) out.add(e);
  }
  return out;
}
