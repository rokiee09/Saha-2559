class TrafikAdim {
  const TrafikAdim({required this.title, required this.detail});

  final String title;
  final String detail;
}

class TrafikKonu {
  const TrafikKonu({
    required this.id,
    required this.title,
    required this.summary,
    required this.steps,
    required this.keywords,
    this.mevzuatNote = '',
    this.moduleRoute,
  });

  final String id;
  final String title;
  final String summary;
  final List<TrafikAdim> steps;
  final List<String> keywords;
  final String mevzuatNote;
  final String? moduleRoute;
}

const kTrafikKonulari = <TrafikKonu>[
  TrafikKonu(
    id: 'rutin_kontrol',
    title: 'Rutin trafik kontrolü',
    summary:
        'Durdurma makul sebebe dayanır; kimlik, ruhsat ve gerekli belgeler '
        'kontrol edilir; ihlal yoksa kısa sürede sonlandırılır.',
    keywords: ['trafik kontrol', 'durdurma', 'ruhsat', 'ehliyet', 'kimlik'],
    steps: [
      TrafikAdim(
        title: 'Durdurma gerekçesi',
        detail: 'Tehlike, suç şüphesi veya denetim planı gibi makul sebep tutanağa yazılır.',
      ),
      TrafikAdim(
        title: 'Belge kontrolü',
        detail: 'Ehliyet, ruhsat, sigorta; eksik belge ayrı işlem dosyası açar.',
      ),
      TrafikAdim(
        title: 'İhlal yoksa sonlandırma',
        detail: 'Gereksiz uzatmadan bilgilendirip serbest bırakın; süre kaydı tutun.',
      ),
    ],
    mevzuatNote: 'PVSK md. 4/A · Karayolları Trafik Kanunu',
    moduleRoute: 'idari_para_ceza',
  ),
  TrafikKonu(
    id: 'alkollu',
    title: 'Alkollü sürücü',
    summary:
        'Ölçüm cihazı kaydı, tutanak ve idari/adli yaptırım ayrı kanallarda '
        'tamamlanır; güvenlik ve trafik akışı korunur.',
    keywords: ['alkol', 'alkollu', 'promil', 'surucu', 'trafik'],
    steps: [
      TrafikAdim(
        title: 'Güvenlik ve ölçüm',
        detail: 'Araç güvenli durdurulur; ölçüm usulü ve cihaz bilgisi kayda geçer.',
      ),
      TrafikAdim(
        title: 'Tutanak ve yaptırım',
        detail: 'Trafik tutanağı; idari para ceza ve gerekirse adli süreç başlatılır.',
      ),
      TrafikAdim(
        title: 'Personel disiplini',
        detail: 'Görevli personel ise özlük/disiplin süreci ayrı yürütülür.',
      ),
    ],
    mevzuatNote: 'TCK trafik güvenliği · İdari para cezaları listesi',
    moduleRoute: 'idari_para_ceza',
  ),
  TrafikKonu(
    id: 'hiz',
    title: 'Hız sınırı ihlali',
    summary:
        'Tespit yöntemi (radar, takip) kayıt altına alınır; ceza tutarı '
        'güncel kabahatler cetvelinden kontrol edilir.',
    keywords: ['hiz', 'hız', 'radar', 'limit', 'asimi'],
    steps: [
      TrafikAdim(
        title: 'Tespit kaydı',
        detail: 'Cihaz, konum, saat ve sınır değeri belgelenir.',
      ),
      TrafikAdim(
        title: 'Kabahat işlemi',
        detail: 'İdari para ceza tebliği; itiraz mercii ve süre bilgisi verilir.',
      ),
    ],
    moduleRoute: 'idari_para_ceza',
  ),
  TrafikKonu(
    id: 'belgesiz',
    title: 'Belgesiz veya usulsüz sürüş',
    summary:
        'Ehliyetsiz veya iptal ehliyetle sürüş ağır kabahat/adli boyuta '
        'geçebilir; araç trafikten men edilebilir.',
    keywords: ['ehliyetsiz', 'belgesiz', 'ruhsatsiz', 'surucu belgesi'],
    steps: [
      TrafikAdim(
        title: 'Durum tespiti',
        detail: 'Ehliyet/ruhsat kontrolü; sahte belge şüphesinde ayrı soruşturma.',
      ),
      TrafikAdim(
        title: 'Araç işlemi',
        detail: 'Çekme, men veya görevli teslim — mevzuat ve emir zincirine göre.',
      ),
    ],
    moduleRoute: 'idari_para_ceza',
  ),
  TrafikKonu(
    id: 'kaza',
    title: 'Trafik kazası yeri',
    summary:
        'Can güvenliği, yaralıya ilk yardım, olay yeri koruma ve görgü '
        'tespiti önceliklidir; ölümlü kazada kriz rehberi ile birlikte bakın.',
    keywords: ['kaza', 'trafik kazasi', 'yarali', 'olay yeri', 'gorgu'],
    steps: [
      TrafikAdim(
        title: 'Güvenlik ve 112',
        detail: 'Şerit kapatma, uyarı, sağlık ve itfaiye çağrısı.',
      ),
      TrafikAdim(
        title: 'Görgü ve tutanak',
        detail: 'Olay görgü tespit tutanağı; fotoğraf ve tanık bilgisi.',
      ),
      TrafikAdim(
        title: 'Kriz rehberi',
        detail: 'Ağır kazalarda Araçlar → Kriz rehberi adımlarını uygulayın.',
      ),
    ],
    mevzuatNote: 'TCK · CMK · Tutanak şablonları',
  ),
];

List<TrafikKonu> trafikEslestir(String query) {
  final q = query.trim().toLowerCase();
  if (q.length < 2) return const [];
  final out = <TrafikKonu>[];
  for (final t in kTrafikKonulari) {
    final blob = '${t.title} ${t.summary} ${t.keywords.join(' ')}'.toLowerCase();
    if (blob.contains(q)) out.add(t);
  }
  return out;
}
