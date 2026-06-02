/// Asistanın yanıt verdiği uzmanlık alanları (genel chatbot değil).
enum AsistanDomain {
  mevzuat,
  pvsk,
  cmk,
  tck,
  dmk,
  disiplin,
  izin,
  tayin,
  lojman,
  maas;

  String get id => name;

  String get label => switch (this) {
        AsistanDomain.mevzuat => 'Mevzuat',
        AsistanDomain.pvsk => 'PVSK',
        AsistanDomain.cmk => 'CMK',
        AsistanDomain.tck => 'TCK',
        AsistanDomain.dmk => '657 DMK',
        AsistanDomain.disiplin => 'Disiplin',
        AsistanDomain.izin => 'İzinler',
        AsistanDomain.tayin => 'Tayin',
        AsistanDomain.lojman => 'Lojman',
        AsistanDomain.maas => 'Maaş',
      };

  /// Alan tanıma anahtar kelimeleri (aksan sadeleştirilmiş eşleşme).
  List<String> get keywords => switch (this) {
        AsistanDomain.mevzuat => const [
            'mevzuat',
            'kanun',
            'yonetmelik',
            'madde',
            'yönetmelik',
          ],
        AsistanDomain.pvsk => const [
            'pvsk',
            'polis',
            'kolluk',
            'zor kullanma',
            'yakalama',
            'durdurma',
            'arama',
            'ifade',
            'gozalti',
            'silah',
          ],
        AsistanDomain.cmk => const [
            'cmk',
            'ceza muhakemesi',
            'savunma',
            'müdafi',
            'mudafi',
            'avukat',
            'gözaltı',
            'gozalti',
            'yakalama usul',
          ],
        AsistanDomain.tck => const [
            'tck',
            'turk ceza',
            'suç',
            'suc',
            'ceza kanunu',
            'hakaret',
            'mukavemet',
            'direnme',
          ],
        AsistanDomain.dmk => const [
            'dmk',
            '657',
            'devlet memurlari',
            'memur',
            'personel',
          ],
        AsistanDomain.disiplin => const [
            'disiplin',
            'uyarma',
            'kınama',
            'kinama',
            'ayliktan kesme',
            '7068',
          ],
        AsistanDomain.izin => const [
            'izin',
            'yillik',
            'refakat',
            'mazeret',
            'dogum',
            'babalik',
            'analik',
            'ayliksiz',
          ],
        AsistanDomain.tayin => const [
            'tayin',
            'atama',
            'gorev puani',
            'görev puanı',
            'hizmet puani',
            'yer degistirme',
          ],
        AsistanDomain.lojman => const [
            'lojman',
            'konut',
            'barinma',
            'lojman puani',
          ],
        AsistanDomain.maas => const [
            'maas',
            'maaş',
            'katsayi',
            'katsayı',
            'odeme',
            'ödenek',
            'tazminat',
          ],
      };

  static AsistanDomain? fromId(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final d in AsistanDomain.values) {
      if (d.id == raw) return d;
    }
    return null;
  }
}

/// Tüm uzmanlık alanları (giriş ekranı çipleri).
const List<AsistanDomain> asistanAllDomains = AsistanDomain.values;

/// Hukuki tavsiye değildir — tüm cevaplarda kullanılan önek.
const String asistanLegalPrefix = 'İlgili mevzuata göre';

const String asistanDisclaimer =
    '$asistanLegalPrefix bilgilendirme sunulur; bağlayıcı hukuki tavsiye veya '
    'resmî görüş değildir. Kesin sonuç için tam metne ve kurum işlemine bakın.';
