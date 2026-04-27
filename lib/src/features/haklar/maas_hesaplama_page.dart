import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'maas_form_style_constants.dart';
import 'maas_katsayi_data.dart';

/// Yaygın memur maaş / bordro giriş formu düzenine benzer alan grupları.
/// Kesin net ve kesintiler kurum bordrosu ve güncel mevzuata bağlıdır.
class MaasHesaplamaPage extends StatefulWidget {
  const MaasHesaplamaPage({super.key});

  @override
  State<MaasHesaplamaPage> createState() => _MaasHesaplamaPageState();
}

class _MaasHesaplamaPageState extends State<MaasHesaplamaPage> {
  final _gostergeCtrl = TextEditingController(text: '1350');
  final _ekGostergeCtrl = TextEditingController(text: '0');
  final _kidemCtrl = TextEditingController(text: '0');
  final _ohtCtrl = TextEditingController(text: '0');
  final _dilCtrl = TextEditingController(text: '0');
  final _ekOdemeCtrl = TextEditingController(text: '0');
  final _aileCtrl = TextEditingController(text: '0');
  final _cocukCtrl = TextEditingController(text: '0');
  final _gvIstisnaCtrl = TextEditingController(text: '0');
  final _dvIstisnaCtrl = TextEditingController(text: '0');
  final _sosyalDengeCtrl = TextEditingController(text: '0');
  final _yemekCtrl = TextEditingController(text: '0');
  final _ek28Ctrl = TextEditingController(text: '0');
  final _ozelSaglikCtrl = TextEditingController(text: '0');
  final _nafakaCtrl = TextEditingController(text: '0');
  final _icraCtrl = TextEditingController(text: '0');
  final _kiraCtrl = TextEditingController(text: '0');
  final _digerKesintiCtrl = TextEditingController(text: '0');

  MaasKatsayiFile? _file;
  String? _donemId;
  MaasHesapSonucu? _sonuc;
  Object? _loadErr;

  int _ayIndex = 0;
  String _kadroUnvan = kPolisEmniyetUnvanlari.first;
  int _derece = 5;
  int _kademe = 1;
  int _kidemYili = 0;
  int _kidemAyIndex = 0;
  int _medeniHal = 0;
  int _cocuk06 = 0;
  int _cocuk7 = 0;
  int _sendika = 0;
  int _gvOraniSecim = 0;

  static const _medeniEtiketler = [
    'Bekar',
    'Evli / Eşi çalışıyor',
    'Evli / Eşi çalışmıyor',
    'Evli / Eşi emekli',
  ];

  static const _sendikaEtiketler = [
    'Yok',
    'Var (kesinti %0,4)',
    'Var (kesinti %0,5)',
    'Var (kesinti %0,6)',
    'Var (kesinti %0,7)',
    'Var (kesinti %0,8)',
    'Var (taban aylık kes. %1,1)',
    'Var (taban aylık kes. %1,5)',
  ];

  static const _gvOranEtiketleri = [
    'Otomatik (uygulama tahmini)',
    '%15',
    '%20',
    '%27',
    '%35',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final f = await loadMaasKatsayiFile();
      if (!mounted) return;
      setState(() {
        _file = f;
        _donemId = f.donemById(f.varsayilanDonem) != null
            ? f.varsayilanDonem
            : (f.donemler.isNotEmpty ? f.donemler.first.id : null);
        _loadErr = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadErr = e);
    }
  }

  @override
  void dispose() {
    _gostergeCtrl.dispose();
    _ekGostergeCtrl.dispose();
    _kidemCtrl.dispose();
    _ohtCtrl.dispose();
    _dilCtrl.dispose();
    _ekOdemeCtrl.dispose();
    _aileCtrl.dispose();
    _cocukCtrl.dispose();
    _gvIstisnaCtrl.dispose();
    _dvIstisnaCtrl.dispose();
    _sosyalDengeCtrl.dispose();
    _yemekCtrl.dispose();
    _ek28Ctrl.dispose();
    _ozelSaglikCtrl.dispose();
    _nafakaCtrl.dispose();
    _icraCtrl.dispose();
    _kiraCtrl.dispose();
    _digerKesintiCtrl.dispose();
    super.dispose();
  }

  double _parseTr(String s) {
    final t = s.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(t) ?? 0;
  }

  void _hesapla() {
    final f = _file;
    final id = _donemId;
    if (f == null || id == null) return;
    final d = f.donemById(id);
    if (d == null) return;

    final ekToplu = _parseTr(_ekOdemeCtrl.text) +
        _parseTr(_sosyalDengeCtrl.text) +
        _parseTr(_yemekCtrl.text) +
        _parseTr(_ek28Ctrl.text);

    setState(() {
      _sonuc = hesaplaMaas(
        donem: d,
        gostergePuan: _parseTr(_gostergeCtrl.text),
        ekGostergeTl: _parseTr(_ekGostergeCtrl.text),
        kidemAyligi: _parseTr(_kidemCtrl.text),
        ozelHizmetTazminati: _parseTr(_ohtCtrl.text),
        dilTazminati: _parseTr(_dilCtrl.text),
        ekOdeme: ekToplu,
        aileYardimi: _parseTr(_aileCtrl.text),
        cocukYardimi: _parseTr(_cocukCtrl.text),
      );
    });
  }

  void _temizle() {
    setState(() {
      _gostergeCtrl.text = '1350';
      _ekGostergeCtrl.text = '0';
      _kidemCtrl.text = '0';
      _ohtCtrl.text = '0';
      _dilCtrl.text = '0';
      _ekOdemeCtrl.text = '0';
      _aileCtrl.text = '0';
      _cocukCtrl.text = '0';
      _gvIstisnaCtrl.text = '0';
      _dvIstisnaCtrl.text = '0';
      _sosyalDengeCtrl.text = '0';
      _yemekCtrl.text = '0';
      _ek28Ctrl.text = '0';
      _ozelSaglikCtrl.text = '0';
      _nafakaCtrl.text = '0';
      _icraCtrl.text = '0';
      _kiraCtrl.text = '0';
      _digerKesintiCtrl.text = '0';
      _ayIndex = 0;
      _kadroUnvan = kPolisEmniyetUnvanlari.first;
      _derece = 5;
      _kademe = 1;
      _kidemYili = 0;
      _kidemAyIndex = 0;
      _medeniHal = 0;
      _cocuk06 = 0;
      _cocuk7 = 0;
      _sendika = 0;
      _gvOraniSecim = 0;
      _sonuc = null;
    });
  }

  void _sifirla() {
    setState(() {
      _gostergeCtrl.text = '0';
      _ekGostergeCtrl.text = '0';
      _kidemCtrl.text = '0';
      _ohtCtrl.text = '0';
      _dilCtrl.text = '0';
      _ekOdemeCtrl.text = '0';
      _aileCtrl.text = '0';
      _cocukCtrl.text = '0';
      _gvIstisnaCtrl.text = '0';
      _dvIstisnaCtrl.text = '0';
      _sosyalDengeCtrl.text = '0';
      _yemekCtrl.text = '0';
      _ek28Ctrl.text = '0';
      _ozelSaglikCtrl.text = '0';
      _nafakaCtrl.text = '0';
      _icraCtrl.text = '0';
      _kiraCtrl.text = '0';
      _digerKesintiCtrl.text = '0';
      _sonuc = null;
    });
  }

  double _nafakaToplami() {
    return _parseTr(_nafakaCtrl.text) +
        _parseTr(_icraCtrl.text) +
        _parseTr(_kiraCtrl.text) +
        _parseTr(_digerKesintiCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadErr != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tahmini maaş bilgisi')),
        body: Center(child: Text('Veri yüklenemedi: $_loadErr')),
      );
    }
    final f = _file;
    if (f == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final cs = Theme.of(context).colorScheme;
    final d = _donemId != null ? f.donemById(_donemId!) : null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tahmini maaş bilgisi'),
            Text(
              'Bordro formuna benzer giriş; sonuç tahmindir',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).appBarTheme.foregroundColor?.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: cs.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: cs.primary.withValues(alpha: 0.35)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Önemli uyarı',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.error,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bu ekran yalnızca bilgilendirme amaçlı tahmini tutarlar üretir; hukuken ve mali olarak '
                      'hiçbir bağlayıcılığı yoktur. Uygulama paketindeki katsayı ve parametreler '
                      'güncel olmayabilir; güncellemeleri kaçırıldığında sonuçlar ciddi şekilde sapar. '
                      'Kesin ve güncel maaş bilgisi yalnızca kurum bordronuz ve resmî duyurulardadır. '
                      'Borç-alacak, kredi veya işlem yapmayınız; bu ekrana güvenmeyiniz.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'BİLGİ GİRİŞİ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kesin sonuçlar için doğru ve eksiksiz bilgi girişi yapmalısınız.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 14),
            Text('Son güncelleme (JSON): ${f.sonGuncelleme}',
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 6),
            Text(f.genelUyari,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35)),
            const SizedBox(height: 16),

            _bilgiSatiri(
              context,
              'Bütçe dönemi seçimi',
              DropdownButtonFormField<String>(
                value: _donemId,
                isExpanded: true,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                items: [
                  for (final p in f.donemler)
                    DropdownMenuItem(value: p.id, child: Text(p.etiket, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) => setState(() => _donemId = v),
              ),
            ),
            if (d != null) ...[
              const SizedBox(height: 10),
              _katsayiOzet(context, d),
              if (d.kaynakNot != null) ...[
                const SizedBox(height: 8),
                Text(d.kaynakNot!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
            const SizedBox(height: 12),
            _bilgiSatiri(
              context,
              'Hesaplanacak ay seçimi',
              DropdownButtonFormField<int>(
                value: _ayIndex,
                isExpanded: true,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                items: [
                  for (var i = 0; i < kAylar12.length; i++)
                    DropdownMenuItem(value: i, child: Text(kAylar12[i])),
                ],
                onChanged: (v) => setState(() => _ayIndex = v ?? 0),
              ),
            ),
            const SizedBox(height: 12),
            _bilgiSatiri(
              context,
              'Kadro (görev) ünvanı seçimi',
              DropdownButtonFormField<String>(
                value: _kadroUnvan,
                isExpanded: true,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  helperText: 'Tam ünvan listesi kurum kadro cetvelindedir; göstergeyi elle girin.',
                ),
                items: [
                  for (final u in kPolisEmniyetUnvanlari)
                    DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) => setState(() => _kadroUnvan = v ?? _kadroUnvan),
              ),
            ),
            const SizedBox(height: 12),
            _bilgiSatiri(
              context,
              'Derece / kademe (ödemeye esas)',
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _derece,
                      decoration: const InputDecoration(labelText: 'Derece', border: OutlineInputBorder()),
                      items: [for (var i = 1; i <= 9; i++) DropdownMenuItem(value: i, child: Text('$i'))],
                      onChanged: (v) => setState(() => _derece = v ?? 1),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('/')),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _kademe,
                      decoration: const InputDecoration(labelText: 'Kademe', border: OutlineInputBorder()),
                      items: [for (var i = 1; i <= 9; i++) DropdownMenuItem(value: i, child: Text('$i'))],
                      onChanged: (v) => setState(() => _kademe = v ?? 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _bilgiSatiri(
              context,
              'Kıdem yılı / göreve başlama ayı',
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      value: _kidemYili.clamp(0, 25),
                      decoration: const InputDecoration(labelText: 'Yıl', border: OutlineInputBorder()),
                      items: [
                        for (var i = 0; i <= 24; i++)
                          DropdownMenuItem(value: i, child: Text('$i')),
                        const DropdownMenuItem(value: 25, child: Text('25+')),
                      ],
                      onChanged: (v) => setState(() => _kidemYili = v ?? 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<int>(
                      value: _kidemAyIndex,
                      decoration: const InputDecoration(labelText: 'Ay', border: OutlineInputBorder()),
                      items: [
                        for (var i = 0; i < kAylar12.length; i++)
                          DropdownMenuItem(value: i, child: Text(kAylar12[i])),
                      ],
                      onChanged: (v) => setState(() => _kidemAyIndex = v ?? 0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _bilgiSatiri(
              context,
              'Medeni hal / eş durumu',
              DropdownButtonFormField<int>(
                value: _medeniHal,
                isExpanded: true,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                items: [
                  for (var i = 0; i < _medeniEtiketler.length; i++)
                    DropdownMenuItem(value: i, child: Text(_medeniEtiketler[i])),
                ],
                onChanged: (v) => setState(() => _medeniHal = v ?? 0),
              ),
            ),
            const SizedBox(height: 12),
            _bilgiSatiri(
              context,
              'Çocuk yardımı (0–6 / 7+)',
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _cocuk06,
                      decoration: const InputDecoration(labelText: '0–6', border: OutlineInputBorder()),
                      items: [for (var i = 0; i <= 6; i++) DropdownMenuItem(value: i, child: Text('$i'))],
                      onChanged: (v) => setState(() => _cocuk06 = v ?? 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _cocuk7,
                      decoration: const InputDecoration(labelText: '7+', border: OutlineInputBorder()),
                      items: [for (var i = 0; i <= 9; i++) DropdownMenuItem(value: i, child: Text('$i'))],
                      onChanged: (v) => setState(() => _cocuk7 = v ?? 0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _bilgiSatiri(
              context,
              'Sendika üyeliği',
              DropdownButtonFormField<int>(
                value: _sendika,
                isExpanded: true,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                items: [
                  for (var i = 0; i < _sendikaEtiketler.length; i++)
                    DropdownMenuItem(value: i, child: Text(_sendikaEtiketler[i], overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) => setState(() => _sendika = v ?? 0),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'UYGULAMA İÇİ BRÜT KALEMLERİ (TL)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Ünvan seçimi yalnızca bilgi amaçlıdır; gösterge puanı otomatik gelmez. Toplam gösterge ve tutarları cetvelden girin. '
              'Aşağıdaki TL alanları çevrimdışı toplam içindir.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 12),
            _numField(context, _gostergeCtrl, 'Toplam gösterge puanı', hint: '1350'),
            const SizedBox(height: 10),
            _numField(context, _ekGostergeCtrl, 'Ek gösterge (TL)'),
            const SizedBox(height: 10),
            _numField(context, _kidemCtrl, 'Kıdem aylığı (TL)'),
            const SizedBox(height: 10),
            _numField(context, _ohtCtrl, 'Özel hizmet tazminatı — ÖHT (TL)'),
            const SizedBox(height: 10),
            _numField(context, _dilCtrl, 'Dil tazminatı (TL)'),
            const SizedBox(height: 10),
            _numField(context, _ekOdemeCtrl, 'Ek ödeme / görev tazminatı (TL)'),
            const SizedBox(height: 10),
            _numField(context, _aileCtrl, 'Aile yardımı (TL)'),
            const SizedBox(height: 10),
            _numField(context, _cocukCtrl, 'Çocuk yardımı (brüt TL, cetvel)'),

            const SizedBox(height: 8),
            ExpansionTile(
              title: Text(
                'GELİŞMİŞ SEÇİMLER',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              children: [
                _numField(context, _gvIstisnaCtrl, 'GV istisnası (faydalanılan, TL)'),
                const SizedBox(height: 8),
                _numField(context, _dvIstisnaCtrl, 'DV istisna uyg. matrahı (faydalanılan, TL)'),
                const SizedBox(height: 8),
                _numField(context, _sosyalDengeCtrl, 'Sosyal denge tazminatı (TL)'),
                const SizedBox(height: 8),
                _numField(context, _yemekCtrl, 'Yemek yardımı (TL)'),
                const SizedBox(height: 8),
                _numField(context, _ek28Ctrl, 'Ek tazminat (28/B) (TL)'),
                const SizedBox(height: 8),
                _numField(context, _ozelSaglikCtrl, 'Özel sağlık sig. primi vergi indirimi (TL)'),
                const SizedBox(height: 8),
                _bilgiSatiri(
                  context,
                  'Gelir vergisi oranı seçimi',
                  DropdownButtonFormField<int>(
                    value: _gvOraniSecim,
                    isExpanded: true,
                    decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                    items: [
                      for (var i = 0; i < _gvOranEtiketleri.length; i++)
                        DropdownMenuItem(value: i, child: Text(_gvOranEtiketleri[i])),
                    ],
                    onChanged: (v) => setState(() => _gvOraniSecim = v ?? 0),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'GV istisnası ve oran seçimi bu çevrimdışı özet hesapta yalnızca kayıt amaçlıdır; '
                  'otomatik vergi dilimi yok.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: cs.onSurface.withValues(alpha: 0.75),
                      ),
                ),
              ],
            ),

            ExpansionTile(
              title: Text(
                'NAFAKA / İCRA / KİRA / DİĞER KESİNTİ',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              children: [
                _numField(context, _nafakaCtrl, 'Nafaka kesintisi (TL)'),
                const SizedBox(height: 8),
                _numField(context, _icraCtrl, 'İcra kesintisi (TL)'),
                const SizedBox(height: 8),
                _numField(context, _kiraCtrl, 'Kira kesintisi (TL)'),
                const SizedBox(height: 8),
                _numField(context, _digerKesintiCtrl, 'Diğer kesintiler (TL)'),
              ],
            ),

            const SizedBox(height: 8),
            Text(f.formulAciklama,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),

            const SizedBox(height: 16),
            Text(
              'İŞLEMLER',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _hesapla,
                  icon: const Icon(Icons.calculate),
                  label: const Text('HESAPLA'),
                ),
                OutlinedButton(
                  onPressed: _temizle,
                  child: const Text('TEMİZLE'),
                ),
                OutlinedButton(
                  onPressed: _sifirla,
                  child: const Text('SIFIRLA'),
                ),
              ],
            ),

            if (_sonuc != null && d != null) ...[
              const SizedBox(height: 24),
              Text(
                'ÖZET (çevrimdışı tahmini)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Kadro: $_kadroUnvan · Ay: ${kAylar12[_ayIndex]} · '
                'Derece/ kademe: $_derece / $_kademe · Medeni: ${_medeniEtiketler[_medeniHal]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _bordroTablosu(context, _sonuc!, d, _nafakaToplami(), _gvOraniSecim),
            ],

            const SizedBox(height: 28),
            Text(
              'NOTLAR',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '1. Burada yer alan bilgiler yalnızca bilgilendirme amaçlıdır; yanlış veya eksik girişten doğan '
              'hatalardan uygulama sorumlu tutulamaz.\n\n'
              '2. Bilgi girişinde değişiklik yaptıktan sonra sonucu güncellemek için tekrar HESAPLA’ya basınız.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bilgiSatiri(BuildContext context, String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget _katsayiOzet(BuildContext context, MaasDonemData d) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv(context, 'Taban aylık (cetvel)', _tryFormat(d.tabanAylik)),
          const SizedBox(height: 6),
          _kv(context, 'Memur aylık katsayısı', d.memurAylikKatsayisi.toStringAsFixed(6)),
          const SizedBox(height: 6),
          _kv(context, 'Tahmini net oranı (JSON)', '%${(d.tahminiNetOrani * 100).toStringAsFixed(1)}'),
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(k, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          flex: 2,
          child: Text(
            v,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _numField(
    BuildContext context,
    TextEditingController c,
    String label, {
    String? hint,
    String? helper,
  }) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _bordroTablosu(
    BuildContext context,
    MaasHesapSonucu s,
    MaasDonemData d,
    double nafakaToplam,
    int gvSecim,
  ) {
    final cs = Theme.of(context).colorScheme;
    final rows = <MapEntry<String, double>>[
      MapEntry('Taban aylık', s.tabanAylik),
      MapEntry('Aylık (gösterge × katsayı)', s.gostergeAyligi),
      MapEntry('Ek gösterge', s.ekGostergeTl),
      MapEntry('Kıdem aylığı', s.kidemAyligi),
      MapEntry('ÖHT', s.ozelHizmetTazminati),
      MapEntry('Dil tazminatı', s.dilTazminati),
      MapEntry('Ek ödeme + sosyal denge + yemek + 28/B', s.ekOdeme),
      MapEntry('Aile yardımı', s.aileYardimi),
      MapEntry('Çocuk yardımı', s.cocukYardimi),
    ];

    final netIc = (s.tahminiNet - nafakaToplam).clamp(0.0, double.infinity);

    return Card(
      elevation: 2,
      color: cs.primaryContainer.withValues(alpha: 0.22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final e in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _bordroSatir(context, e.key, e.value),
              ),
            const Divider(height: 20),
            _bordroSatir(context, 'Brüt toplam', s.brut, vurgu: true),
            const SizedBox(height: 10),
            _bordroSatir(
              context,
              'Tahmini kesintiler (özet oran %${((1 - d.tahminiNetOrani) * 100).toStringAsFixed(1)})',
              s.tahminiKesinti,
            ),
            const SizedBox(height: 8),
            if (nafakaToplam > 0) ...[
              _bordroSatir(context, 'Tahmini net (özet)', s.tahminiNet, vurgu: true),
              const SizedBox(height: 8),
              _bordroSatir(context, 'Nafaka / icra / kira / diğer (düşülür)', -nafakaToplam),
              const SizedBox(height: 8),
              _bordroSatir(context, 'Tahmini elde kalan', netIc, buyuk: true),
            ] else
              _bordroSatir(context, 'Tahmini net', s.tahminiNet, buyuk: true),
            if (gvSecim != 0) ...[
              const SizedBox(height: 10),
              Text(
                'Gelir vergisi oranı seçiminiz (${_gvOranEtiketleri[gvSecim]}) bu çevrimdışı hesapta rakama yansıtılmamıştır.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Gelişmiş alanlardaki GV/DV tutarları ve sendika seçimi bu özet hesapta otomatik işlenmez; '
              'kesin kesinti ve net için kurum bordrosunu esas alın.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bordroSatir(
    BuildContext context,
    String label,
    double v, {
    bool vurgu = false,
    bool buyuk = false,
  }) {
    final style = buyuk
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)
        : vurgu
            ? Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)
            : Theme.of(context).textTheme.bodyMedium;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: style?.copyWith(fontWeight: vurgu || buyuk ? FontWeight.w700 : null),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            _tryFormat(v),
            textAlign: TextAlign.end,
            style: style,
          ),
        ),
      ],
    );
  }
}

String _tryFormat(double v) {
  final neg = v < 0;
  var n = neg ? -v : v;
  final fixed = n.toStringAsFixed(2);
  final parts = fixed.split('.');
  var intPart = parts[0];
  if (intPart == '-0') intPart = '0';
  final buf = StringBuffer();
  final len = intPart.length;
  for (var i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) buf.write('.');
    buf.write(intPart[i]);
  }
  final sign = neg ? '-' : '';
  return '$sign${buf.toString()},${parts[1]} ₺';
}
