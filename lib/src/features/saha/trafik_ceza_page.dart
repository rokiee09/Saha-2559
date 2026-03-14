import 'package:flutter/material.dart';

/// Trafik ceza maddesi: açıklama, para cezası (TL), ceza puanı, araç bağlama.
class _CezaMaddesi {
  final String madde;
  final String aciklama;
  final String paraCezasi;
  final int puan;
  final String aracBaglama;

  _CezaMaddesi({
    required this.madde,
    required this.aciklama,
    required this.paraCezasi,
    required this.puan,
    required this.aracBaglama,
  });
}

class TrafikCezaPage extends StatefulWidget {
  const TrafikCezaPage({super.key});

  @override
  State<TrafikCezaPage> createState() => _TrafikCezaPageState();
}

class _TrafikCezaPageState extends State<TrafikCezaPage> {
  static final List<_CezaMaddesi> _maddeler = [
    _CezaMaddesi(
      madde: 'Hız ihlali (şehir içi)',
      aciklama: 'Yerleşim yeri içinde hız sınırının %10–%30 aşılması',
      paraCezasi: '~1.500 TL',
      puan: 10,
      aracBaglama: 'Yok',
    ),
    _CezaMaddesi(
      madde: 'Hız ihlali (şehir içi %30+)',
      aciklama: 'Yerleşim yeri içinde hız sınırının %30\'dan fazla aşılması',
      paraCezasi: '~3.500 TL',
      puan: 15,
      aracBaglama: 'Yok',
    ),
    _CezaMaddesi(
      madde: 'Emniyet kemeri takmama',
      aciklama: 'Sürücü veya yolcunun emniyet kemeri takmaması',
      paraCezasi: '~350 TL',
      puan: 5,
      aracBaglama: 'Yok',
    ),
    _CezaMaddesi(
      madde: 'Cep telefonu kullanımı',
      aciklama: 'Sürüş sırasında elde cep telefonu kullanımı',
      paraCezasi: '~2.000 TL',
      puan: 15,
      aracBaglama: 'Yok',
    ),
    _CezaMaddesi(
      madde: 'Kırmızı ışık ihlali',
      aciklama: 'Kırmızı ışıkta geçme',
      paraCezasi: '~2.500 TL',
      puan: 20,
      aracBaglama: 'Yok',
    ),
    _CezaMaddesi(
      madde: 'Alkollü araç kullanma (0.20–0.50 promil)',
      aciklama: 'Kan alkol sınırının aşılması',
      paraCezasi: '~7.000 TL',
      puan: 20,
      aracBaglama: '6 ay (ilk)',
    ),
    _CezaMaddesi(
      madde: 'Alkollü araç kullanma (0.50+ promil)',
      aciklama: 'Yüksek oranda alkol',
      paraCezasi: '~15.000 TL+',
      puan: 20,
      aracBaglama: '2 yıl (sürücü belgesi iptali)',
    ),
    _CezaMaddesi(
      madde: 'Ehliyetsiz araç kullanma',
      aciklama: 'Geçerli sürücü belgesi olmadan araç kullanma',
      paraCezasi: '~3.500 TL',
      puan: 20,
      aracBaglama: 'Araç trafikten men',
    ),
    _CezaMaddesi(
      madde: 'Park ihlali (yasak yerde park)',
      aciklama: 'Yasak veya engel oluşturacak şekilde park',
      paraCezasi: '~500 TL',
      puan: 0,
      aracBaglama: 'Çekici ile kaldırma (belediyeye göre)',
    ),
    _CezaMaddesi(
      madde: 'Dönüş kurallarına uymama',
      aciklama: 'Dönüşlerde şerit ve sinyal kuralı ihlali',
      paraCezasi: '~1.100 TL',
      puan: 10,
      aracBaglama: 'Yok',
    ),
  ];

  _CezaMaddesi? _secili;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trafik Ceza Hesaplayıcı')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ceza maddesi seçin; para cezası, ceza puanı ve araç bağlama bilgisi gösterilir. '
              'Tutarlar örnek olup yıla ve mevzuata göre değişebilir.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<_CezaMaddesi>(
              value: _secili,
              decoration: const InputDecoration(
                labelText: 'Ceza maddesi',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Seçiniz'),
              items: _maddeler
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(
                          m.madde,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _secili = v),
            ),
            if (_secili != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _secili!.madde,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(_secili!.aciklama),
                      const Divider(height: 24),
                      _row(context, 'Para cezası', _secili!.paraCezasi, Icons.money_off),
                      const SizedBox(height: 8),
                      _row(context, 'Ceza puanı', '${_secili!.puan} puan', Icons.pin),
                      const SizedBox(height: 8),
                      _row(context, 'Araç bağlama / Men', _secili!.aracBaglama, Icons.directions_car),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ],
    );
  }
}
