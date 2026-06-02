import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Tutanak taslakları tamamen cihazda üretilir; resmî form değildir.

class TutanakField {
  const TutanakField({
    required this.key,
    required this.label,
    this.hint = '',
    this.multiline = false,
    this.voiceFriendly = false,
  });

  final String key;
  final String label;
  final String hint;
  final bool multiline;
  final bool voiceFriendly;
}

class TutanakTemplate {
  const TutanakTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.fields,
    required this.build,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<TutanakField> fields;
  final String Function(Map<String, String> values) build;

  static const List<TutanakTemplate> all = [
    TutanakTemplate(
      id: 'kimlik_tespit',
      title: 'Kimlik Tespit Tutanağı',
      description: 'Kimlik ve şahıs bilgilerinin tespiti',
      icon: PhosphorIconsRegular.identificationCard,
      fields: [
        TutanakField(key: 'tarih', label: 'Tarih', hint: 'gg.aa.yyyy'),
        TutanakField(key: 'saat', label: 'Saat', hint: 'ss:dd'),
        TutanakField(key: 'yer', label: 'Yer / adres'),
        TutanakField(key: 'kisi', label: 'Tespit edilen kişi'),
        TutanakField(key: 'tc', label: 'T.C. kimlik no (varsa)'),
        TutanakField(key: 'dogum', label: 'Doğum tarihi / yeri'),
        TutanakField(key: 'adres', label: 'İkametgah / bildirilen adres'),
        TutanakField(
          key: 'tespit',
          label: 'Tespit edilen bilgiler / açıklama',
          multiline: true,
          voiceFriendly: true,
        ),
      ],
      build: _buildKimlikTespit,
    ),
    TutanakTemplate(
      id: 'teslim_tesellum',
      title: 'Teslim Tesellüm Tutanağı',
      description: 'Eşya / evrak teslim-tesellümü',
      icon: PhosphorIconsRegular.handshake,
      fields: [
        TutanakField(key: 'tarih', label: 'Tarih', hint: 'gg.aa.yyyy'),
        TutanakField(key: 'saat', label: 'Saat', hint: 'ss:dd'),
        TutanakField(key: 'yer', label: 'Yer / adres'),
        TutanakField(key: 'teslimEden', label: 'Teslim eden'),
        TutanakField(key: 'teslimAlan', label: 'Teslim alan'),
        TutanakField(
          key: 'esya',
          label: 'Teslim edilenler',
          hint: 'Her satıra bir madde',
          multiline: true,
        ),
        TutanakField(
          key: 'aciklama',
          label: 'Açıklama',
          multiline: true,
          voiceFriendly: true,
        ),
      ],
      build: _buildTeslim,
    ),
    TutanakTemplate(
      id: 'buluntu_esya',
      title: 'Buluntu Eşya Tutanağı',
      description: 'Bulunan eşyanın kaydı ve teslimi',
      icon: PhosphorIconsRegular.package,
      fields: [
        TutanakField(key: 'tarih', label: 'Tarih', hint: 'gg.aa.yyyy'),
        TutanakField(key: 'saat', label: 'Saat', hint: 'ss:dd'),
        TutanakField(key: 'yer', label: 'Bulunduğu yer'),
        TutanakField(key: 'bulan', label: 'Bulana / teslim eden'),
        TutanakField(
          key: 'esya',
          label: 'Buluntu eşya tanımı',
          multiline: true,
          voiceFriendly: true,
        ),
        TutanakField(key: 'teslimAlan', label: 'Teslim alan görevli / birim'),
        TutanakField(
          key: 'aciklama',
          label: 'Ek açıklama',
          multiline: true,
          voiceFriendly: true,
        ),
      ],
      build: _buildBuluntu,
    ),
    TutanakTemplate(
      id: 'muhafaza_altina_alma',
      title: 'Muhafaza Altına Alma Tutanağı',
      description: 'El konulan eşyanın muhafazası',
      icon: PhosphorIconsRegular.lock,
      fields: [
        TutanakField(key: 'tarih', label: 'Tarih', hint: 'gg.aa.yyyy'),
        TutanakField(key: 'saat', label: 'Saat', hint: 'ss:dd'),
        TutanakField(key: 'yer', label: 'Yer / birim'),
        TutanakField(key: 'sahip', label: 'Eşya sahibi / ilgili'),
        TutanakField(
          key: 'esya',
          label: 'Muhafaza altına alınan eşya',
          multiline: true,
        ),
        TutanakField(key: 'sebep', label: 'Sebep / dayanak'),
        TutanakField(
          key: 'aciklama',
          label: 'Muhafaza yeri ve işlem',
          multiline: true,
          voiceFriendly: true,
        ),
      ],
      build: _buildMuhafaza,
    ),
    TutanakTemplate(
      id: 'olay_gorgu_tespit',
      title: 'Olay Görgü Tespit Tutanağı',
      description: 'Olay yeri görgü tespiti',
      icon: PhosphorIconsRegular.eye,
      fields: [
        TutanakField(key: 'tarih', label: 'Tarih', hint: 'gg.aa.yyyy'),
        TutanakField(key: 'saat', label: 'Saat', hint: 'ss:dd'),
        TutanakField(key: 'yer', label: 'Olay yeri'),
        TutanakField(key: 'olayTuru', label: 'Olayın türü'),
        TutanakField(
          key: 'gorgu',
          label: 'Görgü tespiti',
          multiline: true,
          voiceFriendly: true,
        ),
        TutanakField(
          key: 'taraflar',
          label: 'Taraflar / tanıklar',
          multiline: true,
        ),
        TutanakField(
          key: 'tedbir',
          label: 'Alınan tedbir',
          multiline: true,
          voiceFriendly: true,
        ),
      ],
      build: _buildOlayGorgu,
    ),
  ];

  static TutanakTemplate? byId(String id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }
}

String _v(Map<String, String> v, String key, [String fallback = '.....']) {
  final s = v[key]?.trim() ?? '';
  return s.isEmpty ? fallback : s;
}

String _header(Map<String, String> v) {
  return '${_v(v, 'tarih', 'gg.aa.yyyy')} tarihinde saat '
      '${_v(v, 'saat', 'ss:dd')} sıralarında, ${_v(v, 'yer')} adresinde;';
}

String _buildKimlikTespit(Map<String, String> v) {
  return [
    'KİMLİK TESPİT TUTANAĞI',
    '',
    '${_header(v)} ${_v(v, 'kisi')} adlı kişinin kimlik bilgileri '
        'tespit edilmiştir.',
    '',
    'T.C. Kimlik No: ${_v(v, 'tc', '—')}',
    'Doğum: ${_v(v, 'dogum', '—')}',
    'Adres: ${_v(v, 'adres', '—')}',
    '',
    'Tespit / açıklama:',
    _v(v, 'tespit'),
    '',
    'İşbu tutanak tarafımızca düzenlenerek okunup imza altına alınmıştır.',
    '',
    'Tespit Edilen: ${_v(v, 'kisi')}        İmza:',
    'Görevli:        İmza:',
  ].join('\n');
}

String _buildTeslim(Map<String, String> v) {
  final esya = (v['esya'] ?? '').trim();
  final esyaBlok = esya.isEmpty
      ? '1- .....'
      : esya
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .toList()
          .asMap()
          .entries
          .map((e) => '${e.key + 1}- ${e.value.trim()}')
          .join('\n');
  final aciklama = v['aciklama']?.trim();
  return [
    'TESLİM TESELLÜM TUTANAĞI',
    '',
    '${_header(v)} aşağıda belirtilen eşya/evrak, '
        '${_v(v, 'teslimEden')} tarafından ${_v(v, 'teslimAlan')} adlı kişiye '
        'eksiksiz olarak teslim edilmiştir.',
    '',
    'Teslim edilenler:',
    esyaBlok,
    if (aciklama != null && aciklama.isNotEmpty) ...['', 'Açıklama: $aciklama'],
    '',
    'İşbu tutanak birlikte düzenlenip okunarak imza altına alınmıştır.',
    '',
    'Teslim Eden: ${_v(v, 'teslimEden')}        İmza:',
    'Teslim Alan: ${_v(v, 'teslimAlan')}        İmza:',
  ].join('\n');
}

String _buildBuluntu(Map<String, String> v) {
  return [
    'BULUNTU EŞYA TUTANAĞI',
    '',
    '${_header(v)} ${_v(v, 'bulan')} tarafından bulunan / teslim edilen eşya '
        'aşağıda kayda geçirilmiştir.',
    '',
    'Buluntu eşya:',
    _v(v, 'esya'),
    '',
    'Teslim alan: ${_v(v, 'teslimAlan')}',
    if ((v['aciklama'] ?? '').trim().isNotEmpty) ...[
      '',
      'Açıklama:',
      _v(v, 'aciklama'),
    ],
    '',
    'İşbu tutanak düzenlenerek okunup imza altına alınmıştır.',
    '',
    'Teslim Eden: ${_v(v, 'bulan')}        İmza:',
    'Teslim Alan: ${_v(v, 'teslimAlan')}        İmza:',
  ].join('\n');
}

String _buildMuhafaza(Map<String, String> v) {
  return [
    'MUHAFAZA ALTINA ALMA TUTANAĞI',
    '',
    '${_header(v)} ${_v(v, 'sahip')} ile ilgili aşağıdaki eşya '
        'muhafaza altına alınmıştır.',
    '',
    'Sebep / dayanak: ${_v(v, 'sebep')}',
    '',
    'Eşya:',
    _v(v, 'esya'),
    '',
    'Muhafaza işlemi:',
    _v(v, 'aciklama'),
    '',
    'İşbu tutanak düzenlenerek imza altına alınmıştır.',
    '',
    'İlgili: ${_v(v, 'sahip')}        İmza:',
    'Görevli:        İmza:',
  ].join('\n');
}

String _buildOlayGorgu(Map<String, String> v) {
  final taraflar = v['taraflar']?.trim();
  final tedbir = v['tedbir']?.trim();
  return [
    'OLAY GÖRGÜ TESPİT TUTANAĞI',
    '',
    '${_header(v)} ${_v(v, 'olayTuru')} nitelikli olay yerinde görgü tespiti '
        'yapılmıştır.',
    '',
    'Görgü tespiti:',
    _v(v, 'gorgu'),
    if (taraflar != null && taraflar.isNotEmpty) ...[
      '',
      'Taraflar / tanıklar:',
      taraflar,
    ],
    if (tedbir != null && tedbir.isNotEmpty) ...[
      '',
      'Alınan tedbir:',
      tedbir,
    ],
    '',
    'İşbu tutanak olay yerinde düzenlenerek imza altına alınmıştır.',
    '',
    'Görevliler:        İmza:',
  ].join('\n');
}
