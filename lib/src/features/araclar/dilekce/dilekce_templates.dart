import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class DilekceField {
  const DilekceField({
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

class DilekceTemplate {
  const DilekceTemplate({
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
  final List<DilekceField> fields;
  final String Function(Map<String, String> values) build;

  static const List<DilekceTemplate> all = [
    DilekceTemplate(
      id: 'yillik_izin',
      title: 'Yıllık izin talebi',
      description: '657 DMK kapsamında yıllık izin talep taslağı',
      icon: PhosphorIconsRegular.calendarCheck,
      fields: [
        DilekceField(key: 'birim', label: 'Bağlı bulunulan birim'),
        DilekceField(key: 'unvan', label: 'Rütbe / görev unvanı'),
        DilekceField(key: 'adSoyad', label: 'Ad soyad'),
        DilekceField(key: 'sicil', label: 'Sicil / kimlik no'),
        DilekceField(key: 'baslangic', label: 'İzin başlangıç tarihi', hint: 'gg.aa.yyyy'),
        DilekceField(key: 'bitis', label: 'İzin bitiş tarihi', hint: 'gg.aa.yyyy'),
        DilekceField(key: 'gun', label: 'Talep edilen gün sayısı'),
        DilekceField(
          key: 'gerekce',
          label: 'Gerekçe (isteğe bağlı)',
          multiline: true,
        ),
      ],
      build: _buildYillikIzin,
    ),
    DilekceTemplate(
      id: 'mazeret_izin',
      title: 'Mazeret izni talebi',
      description: 'Kısa süreli mazeret izni taslağı',
      icon: PhosphorIconsRegular.clock,
      fields: [
        DilekceField(key: 'birim', label: 'Birim'),
        DilekceField(key: 'adSoyad', label: 'Ad soyad'),
        DilekceField(key: 'sicil', label: 'Sicil no'),
        DilekceField(key: 'tarih', label: 'İzin tarihi', hint: 'gg.aa.yyyy'),
        DilekceField(key: 'sure', label: 'Süre (saat/gün)'),
        DilekceField(
          key: 'mazeret',
          label: 'Mazeret açıklaması',
          multiline: true,
        ),
      ],
      build: _buildMazeretIzin,
    ),
    DilekceTemplate(
      id: 'refakat_izin',
      title: 'Refakat izni talebi',
      description: 'Hasta yakını refakat izni taslağı',
      icon: PhosphorIconsRegular.heart,
      fields: [
        DilekceField(key: 'birim', label: 'Birim'),
        DilekceField(key: 'adSoyad', label: 'Ad soyad'),
        DilekceField(key: 'sicil', label: 'Sicil no'),
        DilekceField(key: 'hasta', label: 'Hasta yakınının adı ve yakınlık derecesi'),
        DilekceField(key: 'kurum', label: 'Sağlık kurumu'),
        DilekceField(key: 'baslangic', label: 'Refakat başlangıcı', hint: 'gg.aa.yyyy'),
        DilekceField(key: 'bitis', label: 'Refakat bitişi (rapora göre)', hint: 'gg.aa.yyyy'),
        DilekceField(
          key: 'rapor',
          label: 'Rapor / heyet bilgisi',
          multiline: true,
        ),
      ],
      build: _buildRefakatIzin,
    ),
    DilekceTemplate(
      id: 'disiplin_savunma',
      title: 'Disiplin savunması taslağı',
      description: '7068 kapsamında savunma dilekçesi iskeleti',
      icon: PhosphorIconsRegular.gavel,
      fields: [
        DilekceField(key: 'birim', label: 'Birim / disiplin amiri'),
        DilekceField(key: 'adSoyad', label: 'Ad soyad'),
        DilekceField(key: 'sicil', label: 'Sicil no'),
        DilekceField(key: 'konu', label: 'Savunma konusu / ön rapor tarihi'),
        DilekceField(
          key: 'olay',
          label: 'Olayın özeti',
          multiline: true,
        ),
        DilekceField(
          key: 'savunma',
          label: 'Savunma ve deliller',
          multiline: true,
        ),
        DilekceField(
          key: 'talep',
          label: 'Sonuç ve talep',
          multiline: true,
        ),
      ],
      build: _buildDisiplinSavunma,
    ),
  ];

  static DilekceTemplate? byId(String id) {
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

String _buildYillikIzin(Map<String, String> v) {
  return [
    '${_v(v, 'birim')} MÜDÜRLÜĞÜNE',
    '',
    'Konu: Yıllık izin talebi',
    '',
    '657 sayılı Devlet Memurları Kanunu ve ilgili yönetmelik hükümleri uyarınca,',
    '${_v(v, 'baslangic')} – ${_v(v, 'bitis')} tarihleri arasında ${_v(v, 'gun')} gün',
    'yıllık izin kullanmak istiyorum.',
    if ((v['gerekce'] ?? '').trim().isNotEmpty) ...[
      '',
      'Gerekçe:',
      _v(v, 'gerekce'),
    ],
    '',
    'Gereğinin yapılmasını arz ederim.',
    '',
    'Tarih: ${_v(v, 'baslangic', 'gg.aa.yyyy')}',
    'Rütbe/Unvan: ${_v(v, 'unvan')}',
    'Ad Soyad: ${_v(v, 'adSoyad')}',
    'Sicil: ${_v(v, 'sicil')}',
    'İmza:',
  ].join('\n');
}

String _buildMazeretIzin(Map<String, String> v) {
  return [
    '${_v(v, 'birim')} MÜDÜRLÜĞÜNE',
    '',
    'Konu: Mazeret izni talebi',
    '',
    '${_v(v, 'tarih')} tarihinde ${_v(v, 'sure')} süreyle mazeret izni kullanmak istiyorum.',
    '',
    'Mazeret:',
    _v(v, 'mazeret'),
    '',
    'Gereğinin yapılmasını arz ederim.',
    '',
    'Ad Soyad: ${_v(v, 'adSoyad')}',
    'Sicil: ${_v(v, 'sicil')}',
    'İmza:',
  ].join('\n');
}

String _buildRefakatIzin(Map<String, String> v) {
  return [
    '${_v(v, 'birim')} MÜDÜRLÜĞÜNE',
    '',
    'Konu: Refakat izni talebi',
    '',
    'DMK m. 104 ve sağlık mevzuatı uyarınca, ${_v(v, 'hasta')} için',
    '${_v(v, 'kurum')} bünyesinde ${_v(v, 'baslangic')} – ${_v(v, 'bitis')} tarihleri',
    'arasında refakat izni kullanmak istiyorum.',
    '',
    'Rapor / heyet:',
    _v(v, 'rapor'),
    '',
    'Gereğinin yapılmasını arz ederim.',
    '',
    'Ad Soyad: ${_v(v, 'adSoyad')}',
    'Sicil: ${_v(v, 'sicil')}',
    'İmza:',
  ].join('\n');
}

String _buildDisiplinSavunma(Map<String, String> v) {
  return [
    '${_v(v, 'birim')}NE',
    '',
    'Konu: ${_v(v, 'konu')} hakkında savunmam',
    '',
    '7068 sayılı Genel Kolluk Disiplin Hükümleri Kanunu ve ilgili mevzuat uyarınca',
    'savunma hakkımı kullanarak aşağıdaki hususları arz ederim.',
    '',
    'Olay özeti:',
    _v(v, 'olay'),
    '',
    'Savunma ve deliller:',
    _v(v, 'savunma'),
    '',
    'Sonuç ve talep:',
    _v(v, 'talep'),
    '',
    'Ad Soyad: ${_v(v, 'adSoyad')}',
    'Sicil: ${_v(v, 'sicil')}',
    'Tarih: .....',
    'İmza:',
  ].join('\n');
}
