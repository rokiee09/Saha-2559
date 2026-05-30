import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Tutanak taslakları tamamen cihazda üretilir; resmî form değildir, yalnızca
/// alan kayıtlarını derli toplu yazmaya yardımcı olur. Üretilen metin kullanıcı
/// tarafından kontrol edilip düzenlenmelidir.

class TutanakField {
  const TutanakField({
    required this.key,
    required this.label,
    this.hint = '',
    this.multiline = false,
  });

  final String key;
  final String label;
  final String hint;
  final bool multiline;
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
        TutanakField(key: 'aciklama', label: 'Açıklama', multiline: true),
      ],
      build: _buildTeslim,
    ),
    TutanakTemplate(
      id: 'bilgi_alma',
      title: 'Bilgi Alma Tutanağı',
      description: 'İlgiliden bilgi alma kaydı',
      icon: PhosphorIconsRegular.chatCircleText,
      fields: [
        TutanakField(key: 'tarih', label: 'Tarih', hint: 'gg.aa.yyyy'),
        TutanakField(key: 'saat', label: 'Saat', hint: 'ss:dd'),
        TutanakField(key: 'yer', label: 'Yer / adres'),
        TutanakField(key: 'kisi', label: 'Bilgisine başvurulan'),
        TutanakField(key: 'kimlik', label: 'Kimlik / T.C. (varsa)'),
        TutanakField(key: 'konu', label: 'Konu'),
        TutanakField(
          key: 'beyan',
          label: 'Beyan / alınan bilgi',
          multiline: true,
        ),
      ],
      build: _buildBilgiAlma,
    ),
    TutanakTemplate(
      id: 'ifade',
      title: 'İfade Tutanağı',
      description: 'Şüpheli / mağdur / tanık ifadesi',
      icon: PhosphorIconsRegular.microphone,
      fields: [
        TutanakField(key: 'tarih', label: 'Tarih', hint: 'gg.aa.yyyy'),
        TutanakField(key: 'saat', label: 'Saat', hint: 'ss:dd'),
        TutanakField(key: 'yer', label: 'Yer / birim'),
        TutanakField(key: 'ifadeVeren', label: 'İfade veren'),
        TutanakField(key: 'sifat', label: 'Sıfatı', hint: 'şüpheli / mağdur / tanık'),
        TutanakField(key: 'mudafi', label: 'Müdafi (varsa)'),
        TutanakField(key: 'konu', label: 'İsnat / konu'),
        TutanakField(key: 'beyan', label: 'Beyan', multiline: true),
      ],
      build: _buildIfade,
    ),
    TutanakTemplate(
      id: 'olay',
      title: 'Olay Tutanağı',
      description: 'Genel olay tespit kaydı',
      icon: PhosphorIconsRegular.warningCircle,
      fields: [
        TutanakField(key: 'tarih', label: 'Tarih', hint: 'gg.aa.yyyy'),
        TutanakField(key: 'saat', label: 'Saat', hint: 'ss:dd'),
        TutanakField(key: 'yer', label: 'Olay yeri'),
        TutanakField(key: 'olayTuru', label: 'Olayın türü'),
        TutanakField(key: 'taraflar', label: 'Taraflar / ilgililer', multiline: true),
        TutanakField(key: 'ozet', label: 'Olayın özeti', multiline: true),
        TutanakField(key: 'tedbir', label: 'Alınan tedbir / işlem', multiline: true),
      ],
      build: _buildOlay,
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

String _buildBilgiAlma(Map<String, String> v) {
  final kimlik = v['kimlik']?.trim();
  return [
    'BİLGİ ALMA TUTANAĞI',
    '',
    '${_header(v)} ${_v(v, 'konu')} konusuyla ilgili olarak '
        '${_v(v, 'kisi')} adlı kişinin bilgisine başvurulmuştur.',
    if (kimlik != null && kimlik.isNotEmpty) 'Kimlik bilgisi: $kimlik',
    '',
    'İlgilinin beyanı:',
    _v(v, 'beyan'),
    '',
    'İşbu tutanak tarafımızca düzenlenerek okunup imza altına alınmıştır.',
    '',
    'Bilgi Veren: ${_v(v, 'kisi')}        İmza:',
    'Düzenleyen Görevli:        İmza:',
  ].join('\n');
}

String _buildIfade(Map<String, String> v) {
  final mudafi = v['mudafi']?.trim();
  return [
    'İFADE TUTANAĞI',
    '',
    '${_header(v)} ${_v(v, 'ifadeVeren')} adlı kişi '
        '${_v(v, 'sifat', 'ilgili')} sıfatıyla, ${_v(v, 'konu')} konusunda '
        'ifadesi alınmak üzere hazır edilmiştir.',
    '',
    'İlgiliye; susma hakkı, müdafi yardımından yararlanma ve yakınlarına '
        'haber verme hakları ile yüklenen suç (CMK md. 147) bildirilmiştir.',
    if (mudafi != null && mudafi.isNotEmpty) 'Müdafi: $mudafi',
    '',
    'Beyanı:',
    _v(v, 'beyan'),
    '',
    'İşbu tutanak okunarak doğruluğu teyit edilip imza altına alınmıştır.',
    '',
    'İfade Veren: ${_v(v, 'ifadeVeren')}        İmza:',
    'Müdafi:        İmza:',
    'Düzenleyen Görevli:        İmza:',
  ].join('\n');
}

String _buildOlay(Map<String, String> v) {
  final taraflar = v['taraflar']?.trim();
  final tedbir = v['tedbir']?.trim();
  return [
    'OLAY TUTANAĞI',
    '',
    '${_header(v)} ${_v(v, 'olayTuru')} nitelikli bir olay meydana gelmiştir.',
    '',
    if (taraflar != null && taraflar.isNotEmpty) ...[
      'Taraflar / ilgililer:',
      taraflar,
      '',
    ],
    'Olayın özeti:',
    _v(v, 'ozet'),
    if (tedbir != null && tedbir.isNotEmpty) ...[
      '',
      'Alınan tedbir / yapılan işlem:',
      tedbir,
    ],
    '',
    'İşbu tutanak olay yerinde tarafımızca düzenlenerek imza altına alınmıştır.',
    '',
    'Düzenleyen Görevliler:        İmza:',
  ].join('\n');
}
