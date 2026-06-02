import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'maas_form_style_constants.dart';
import 'maas_katsayi_data.dart';
import 'polis_odeme_derece_kademe.dart';

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
  final _ilksanCtrl = TextEditingController(text: '0');
  final _kefaletCtrl = TextEditingController(text: '0');
  final _nafakaCtrl = TextEditingController(text: '0');
  final _icraCtrl = TextEditingController(text: '0');
  final _kiraCtrl = TextEditingController(text: '0');
  final _digerKesintiCtrl = TextEditingController(text: '0');

  MaasKatsayiFile? _file;
  PolisOdemeDereceKademeTablosu? _polisOdeme;
  String? _donemId;
  MaasHesapSonucu? _sonuc;
  Object? _loadErr;
  double? _polisNetOrani;
  String? _dkOtomatikNot;

  int _ayIndex = 0;
  String _kadroUnvan = kPolisEmniyetUnvanlari.first;
  int _derece = 5;
  int _kademe = 2;
  int _kidemYili = 0;
  int _kidemAyIndex = 0;
  int _medeniHal = 0;
  int _cocuk06 = 0;
  int _cocuk7 = 0;
  int _sendika = 0;
  int _gvOraniSecim = 0;
  int _besOrani = 0;
  int _ilksan = 0;
  int _raporluGun = 0;
  int _engelliCocuk06 = 0;
  int _engelliCocuk7 = 0;
  int _engellilikIndirimi = 0;
  int _tkky = 0;
  bool _sosyalCalismaGorevi = false;
  bool _yabanciDilKurumYarari = false;

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

  static const _ilksanEtiketleri = [
    'Yok',
    'Var',
    'Var (derece terfisi alınan ay)',
  ];

  static const _engellilikEtiketleri = [
    'Yok',
    '%80 (1. derece)',
    '%60 (2. derece)',
    '%40 (3. derece)',
  ];

  static const _tkkyEtiketleri = [
    'Yok',
    'TKKY - giriş aidatı',
    'TKKY - aylık aidat',
    'Giriş aidatı',
    'Aylık aidat',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final f = await loadMaasKatsayiFile();
      final polis = await loadPolisOdemeDereceKademeTablosu();
      if (!mounted) return;
      setState(() {
        _file = f;
        _polisOdeme = polis;
        _donemId = f.donemById(f.varsayilanDonem) != null
            ? f.varsayilanDonem
            : (f.donemler.isNotEmpty ? f.donemler.first.id : null);
        _loadErr = null;
      });
      _uygulaDereceKademe();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadErr = e);
    }
  }

  String _formatTrNum(double v, {int frac = 2}) {
    final s = v.toStringAsFixed(frac);
    final parts = s.split('.');
    return '${parts[0]},${parts[1]}';
  }

  void _uygulaDereceKademe() {
    final polis = _polisOdeme;
    final f = _file;
    final id = _donemId;
    if (polis == null || f == null || id == null) return;
    final d = f.donemById(id);
    if (d == null) return;

    if (!polis.desteklenenUnvan(_kadroUnvan)) {
      setState(() {
        _polisNetOrani = null;
        _dkOtomatikNot =
            'Bu ünvan için otomatik derece/kademe tablosu yok; kalemleri elle girin.';
      });
      return;
    }

    final sonuc = polis.hesapla(
      unvan: _kadroUnvan,
      derece: _derece,
      kademe: _kademe,
      memurAylikKatsayisi: d.memurAylikKatsayisi,
    );
    if (sonuc == null) {
      setState(() {
        _polisNetOrani = null;
        _dkOtomatikNot =
            'Seçilen derece/kademe 657 gösterge tablosunda geçerli değil.';
      });
      return;
    }

    setState(() {
      _gostergeCtrl.text = '${sonuc.gostergePuan}';
      _ekGostergeCtrl.text = _formatTrNum(sonuc.ekGostergeTl);
      _kidemCtrl.text = _formatTrNum(sonuc.kidemAylik);
      _ohtCtrl.text = _formatTrNum(sonuc.ohtTl);
      _ekOdemeCtrl.text = _formatTrNum(sonuc.ekOdemeToplam);
      _gvIstisnaCtrl.text = _formatTrNum(sonuc.gvIstisnasi);
      _dvIstisnaCtrl.text = _formatTrNum(sonuc.dvIstisnaMatrahi, frac: 0);
      _polisNetOrani = sonuc.tahminiNetBrutOrani;
      final kaynak = sonuc.kalibreNokta
          ? 'referans bordro (kalibre)'
          : '657 gösterge ${sonuc.gostergePuan657} puanı + emniyet ödeme çarpanı';
      _dkOtomatikNot =
          '$_kadroUnvan $_derece/$_kademe: gösterge $kaynak; ek gösterge ve ÖHT ödeme derecesine göre dolduruldu.';
    });
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
    _ilksanCtrl.dispose();
    _kefaletCtrl.dispose();
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

  double _gvOrani() => switch (_gvOraniSecim) {
        1 => 0.15,
        2 => 0.20,
        3 => 0.27,
        4 => 0.35,
        _ => 0.15,
      };

  double _sendikaOrani() => switch (_sendika) {
        1 => 0.004,
        2 => 0.005,
        3 => 0.006,
        4 => 0.007,
        5 => 0.008,
        _ => 0,
      };

  double _sendikaTabanOrani() => switch (_sendika) {
        6 => 0.011,
        7 => 0.015,
        _ => 0,
      };

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
        gvIstisnasi: _parseTr(_gvIstisnaCtrl.text),
        dvIstisnaMatrahi: _parseTr(_dvIstisnaCtrl.text),
        ozelSaglikPrimi: _parseTr(_ozelSaglikCtrl.text),
        gelirVergisiOrani: _gvOrani(),
        sendikaKesintiOrani: _sendikaOrani(),
        sendikaTabanAylikKesintiOrani: _sendikaTabanOrani(),
        besKesintiOrani: _besOrani / 100,
        ilksanKesintisi: _parseTr(_ilksanCtrl.text),
        kefaletKesintisi: _parseTr(_kefaletCtrl.text),
        raporluGun: _raporluGun.toDouble(),
        digerKesintiler: _nafakaToplami(),
        tahminiNetOraniOverride: _polisNetOrani,
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
      _ilksanCtrl.text = '0';
      _kefaletCtrl.text = '0';
      _nafakaCtrl.text = '0';
      _icraCtrl.text = '0';
      _kiraCtrl.text = '0';
      _digerKesintiCtrl.text = '0';
      _ayIndex = 0;
      _kadroUnvan = kPolisEmniyetUnvanlari.first;
      _derece = 5;
      _kademe = 2;
      _polisNetOrani = null;
      _dkOtomatikNot = null;
      _kidemYili = 0;
      _kidemAyIndex = 0;
      _medeniHal = 0;
      _cocuk06 = 0;
      _cocuk7 = 0;
      _sendika = 0;
      _gvOraniSecim = 0;
      _besOrani = 0;
      _ilksan = 0;
      _raporluGun = 0;
      _engelliCocuk06 = 0;
      _engelliCocuk7 = 0;
      _engellilikIndirimi = 0;
      _tkky = 0;
      _sosyalCalismaGorevi = false;
      _yabanciDilKurumYarari = false;
      _sonuc = null;
    });
    _uygulaDereceKademe();
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
      _ilksanCtrl.text = '0';
      _kefaletCtrl.text = '0';
      _nafakaCtrl.text = '0';
      _icraCtrl.text = '0';
      _kiraCtrl.text = '0';
      _digerKesintiCtrl.text = '0';
      _besOrani = 0;
      _ilksan = 0;
      _raporluGun = 0;
      _engelliCocuk06 = 0;
      _engelliCocuk7 = 0;
      _engellilikIndirimi = 0;
      _tkky = 0;
      _sosyalCalismaGorevi = false;
      _yabanciDilKurumYarari = false;
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
                color: Theme.of(context)
                    .appBarTheme
                    .foregroundColor
                    ?.withValues(alpha: 0.9),
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
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(height: 1.45),
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
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(height: 1.35)),
            const SizedBox(height: 16),
            _bilgiSatiri(
              context,
              'Bütçe dönemi seçimi',
              DropdownButtonFormField<String>(
                value: _donemId,
                isExpanded: true,
                decoration: const InputDecoration(
                    isDense: true, border: OutlineInputBorder()),
                items: [
                  for (final p in f.donemler)
                    DropdownMenuItem(
                        value: p.id,
                        child: Text(p.etiket, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) {
                  setState(() => _donemId = v);
                  _uygulaDereceKademe();
                },
              ),
            ),
            if (d != null) ...[
              const SizedBox(height: 10),
              _katsayiOzet(context, d),
              if (d.kaynakNot != null) ...[
                const SizedBox(height: 8),
                Text(d.kaynakNot!,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
            const SizedBox(height: 12),
            _bilgiSatiri(
              context,
              'Hesaplanacak ay seçimi',
              DropdownButtonFormField<int>(
                value: _ayIndex,
                isExpanded: true,
                decoration: const InputDecoration(
                    isDense: true, border: OutlineInputBorder()),
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
                  helperText:
                      'Polis Memuru seçiliyken derece/kademe alt kalemleri otomatik dolar.',
                ),
                items: [
                  for (final u in kPolisEmniyetUnvanlari)
                    DropdownMenuItem(
                        value: u,
                        child: Text(u, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) {
                  setState(() => _kadroUnvan = v ?? _kadroUnvan);
                  _uygulaDereceKademe();
                },
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
                      decoration: const InputDecoration(
                          labelText: 'Derece', border: OutlineInputBorder()),
                      items: [
                        for (var i = 1; i <= 15; i++)
                          DropdownMenuItem(value: i, child: Text('$i'))
                      ],
                      onChanged: (v) {
                        setState(() => _derece = v ?? 1);
                        _uygulaDereceKademe();
                      },
                    ),
                  ),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('/')),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _kademe,
                      decoration: const InputDecoration(
                          labelText: 'Kademe', border: OutlineInputBorder()),
                      items: [
                        for (var i = 1; i <= 9; i++)
                          DropdownMenuItem(value: i, child: Text('$i'))
                      ],
                      onChanged: (v) {
                        setState(() => _kademe = v ?? 1);
                        _uygulaDereceKademe();
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_dkOtomatikNot != null) ...[
              const SizedBox(height: 8),
              Text(
                _dkOtomatikNot!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      height: 1.35,
                    ),
              ),
            ],
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
                      decoration: const InputDecoration(
                          labelText: 'Yıl', border: OutlineInputBorder()),
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
                      decoration: const InputDecoration(
                          labelText: 'Ay', border: OutlineInputBorder()),
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
                decoration: const InputDecoration(
                    isDense: true, border: OutlineInputBorder()),
                items: [
                  for (var i = 0; i < _medeniEtiketler.length; i++)
                    DropdownMenuItem(
                        value: i, child: Text(_medeniEtiketler[i])),
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
                      decoration: const InputDecoration(
                          labelText: '0–6', border: OutlineInputBorder()),
                      items: [
                        for (var i = 0; i <= 6; i++)
                          DropdownMenuItem(value: i, child: Text('$i'))
                      ],
                      onChanged: (v) => setState(() => _cocuk06 = v ?? 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _cocuk7,
                      decoration: const InputDecoration(
                          labelText: '7+', border: OutlineInputBorder()),
                      items: [
                        for (var i = 0; i <= 9; i++)
                          DropdownMenuItem(value: i, child: Text('$i'))
                      ],
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
                decoration: const InputDecoration(
                    isDense: true, border: OutlineInputBorder()),
                items: [
                  for (var i = 0; i < _sendikaEtiketler.length; i++)
                    DropdownMenuItem(
                        value: i,
                        child: Text(_sendikaEtiketler[i],
                            overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) => setState(() => _sendika = v ?? 0),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'UYGULAMA İÇİ BRÜT KALEMLERİ (TL)',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Polis Memuru için ödemeye esas derece/kademe (ör. 1/4, 3/1, 5/2) gösterge, ek gösterge, ÖHT ve yaygın ek ödemeleri otomatik doldurur. '
              'Diğer ünvanlarda veya özel durumlarda alanları elle düzenleyebilirsiniz.',
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 12),
            _numField(context, _gostergeCtrl, 'Toplam gösterge puanı',
                hint: '5907',
                helper: 'Aylık tutar = puan × memur aylık katsayısı'),
            const SizedBox(height: 10),
            _numField(context, _ekGostergeCtrl, 'Ek gösterge (TL)',
                helper: 'Ödeme derecesine göre; MAHEP ile uyumlu TL'),
            const SizedBox(height: 10),
            _numField(context, _kidemCtrl, 'Kıdem aylığı (TL)'),
            const SizedBox(height: 10),
            _numField(context, _ohtCtrl, 'Özel hizmet tazminatı — ÖHT (TL)'),
            const SizedBox(height: 10),
            _numField(context, _dilCtrl, 'Dil tazminatı (TL)'),
            const SizedBox(height: 10),
            _numField(
              context,
              _ekOdemeCtrl,
              'Ek ödeme toplamı (666 + mesai + tayin + 375.40)',
              helper: 'Polis Memuru varsayılanı otomatik gelir',
            ),
            const SizedBox(height: 10),
            _numField(context, _aileCtrl, 'Aile yardımı (TL)'),
            const SizedBox(height: 10),
            _numField(context, _cocukCtrl, 'Çocuk yardımı (brüt TL, cetvel)'),
            const SizedBox(height: 8),
            ExpansionTile(
              title: Text(
                'GELİŞMİŞ SEÇİMLER',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              children: [
                _numField(
                    context, _gvIstisnaCtrl, 'GV istisnası (faydalanılan, TL)'),
                const SizedBox(height: 8),
                _numField(context, _dvIstisnaCtrl,
                    'DV istisna uyg. matrahı (faydalanılan, TL)'),
                const SizedBox(height: 8),
                _numField(
                    context, _sosyalDengeCtrl, 'Sosyal denge tazminatı (TL)'),
                const SizedBox(height: 8),
                _numField(context, _yemekCtrl, 'Yemek yardımı (TL)'),
                const SizedBox(height: 8),
                _numField(context, _ek28Ctrl, 'Ek tazminat (28/B) (TL)'),
                const SizedBox(height: 8),
                _numField(context, _ozelSaglikCtrl,
                    'Özel sağlık sig. primi vergi indirimi (TL)'),
                const SizedBox(height: 8),
                _bilgiSatiri(
                  context,
                  'Oto. kat. BES üyeliği',
                  DropdownButtonFormField<int>(
                    value: _besOrani,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: 0, child: Text('Yok')),
                      for (var i = 3; i <= 100; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text('Var (kesinti oranı: %$i)'),
                        ),
                    ],
                    onChanged: (v) => setState(() => _besOrani = v ?? 0),
                  ),
                ),
                const SizedBox(height: 8),
                _bilgiSatiri(
                  context,
                  'İLKSAN üyeliği',
                  DropdownButtonFormField<int>(
                    value: _ilksan,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (var i = 0; i < _ilksanEtiketleri.length; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(_ilksanEtiketleri[i]),
                        ),
                    ],
                    onChanged: (v) => setState(() => _ilksan = v ?? 0),
                  ),
                ),
                const SizedBox(height: 8),
                _numField(
                  context,
                  _ilksanCtrl,
                  'İLKSAN kesintisi (TL)',
                  helper: 'Varsa bordro/MAHEP tutarını girin.',
                ),
                const SizedBox(height: 8),
                _bilgiSatiri(
                  context,
                  'Raporlu gün sayısı (7+)',
                  DropdownButtonFormField<int>(
                    value: _raporluGun,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (var i = 0; i <= 31; i++)
                        DropdownMenuItem(value: i, child: Text('$i')),
                    ],
                    onChanged: (v) => setState(() => _raporluGun = v ?? 0),
                  ),
                ),
                const SizedBox(height: 8),
                _bilgiSatiri(
                  context,
                  'Engelli çocuk yardımı (0-6 / 7+)',
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _engelliCocuk06,
                          decoration: const InputDecoration(
                            labelText: '0-6',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            for (var i = 0; i <= 6; i++)
                              DropdownMenuItem(value: i, child: Text('$i')),
                          ],
                          onChanged: (v) =>
                              setState(() => _engelliCocuk06 = v ?? 0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _engelliCocuk7,
                          decoration: const InputDecoration(
                            labelText: '7+',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            for (var i = 0; i <= 9; i++)
                              DropdownMenuItem(value: i, child: Text('$i')),
                          ],
                          onChanged: (v) =>
                              setState(() => _engelliCocuk7 = v ?? 0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Engelli çocuk yardımının bordro tutarını çocuk yardımı TL alanına ekleyin.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: cs.onSurface.withValues(alpha: 0.75),
                      ),
                ),
                const SizedBox(height: 8),
                _bilgiSatiri(
                  context,
                  'Engellilik indirimi derecesi',
                  DropdownButtonFormField<int>(
                    value: _engellilikIndirimi,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (var i = 0; i < _engellilikEtiketleri.length; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(_engellilikEtiketleri[i]),
                        ),
                    ],
                    onChanged: (v) =>
                        setState(() => _engellilikIndirimi = v ?? 0),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Engellilik indirimi tutarını GV istisnası alanına girerek nete yansıtın.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: cs.onSurface.withValues(alpha: 0.75),
                      ),
                ),
                const SizedBox(height: 8),
                _bilgiSatiri(
                  context,
                  'TKKY görevi / kefalet aidatı',
                  DropdownButtonFormField<int>(
                    value: _tkky,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (var i = 0; i < _tkkyEtiketleri.length; i++)
                        DropdownMenuItem(
                            value: i, child: Text(_tkkyEtiketleri[i])),
                    ],
                    onChanged: (v) => setState(() => _tkky = v ?? 0),
                  ),
                ),
                const SizedBox(height: 8),
                _numField(
                  context,
                  _kefaletCtrl,
                  'Kefalet aidatı / TKKY kesintisi (TL)',
                  helper: 'Seçim varsa tutarı burada hesaba dahil edilir.',
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Sosyal çalışma görevlisi görevi'),
                  subtitle: const Text(
                      'Bilgi amaçlı seçim; ilave tutarı ilgili TL alanına girin.'),
                  value: _sosyalCalismaGorevi,
                  onChanged: (v) => setState(() => _sosyalCalismaGorevi = v),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Yabancı dil bilgisi kurum yararına'),
                  subtitle: const Text(
                      'Dil tazminatı tutarını yukarıdaki TL alanına girin.'),
                  value: _yabanciDilKurumYarari,
                  onChanged: (v) => setState(() => _yabanciDilKurumYarari = v),
                ),
                const SizedBox(height: 8),
                _bilgiSatiri(
                  context,
                  'Gelir vergisi oranı seçimi',
                  DropdownButtonFormField<int>(
                    value: _gvOraniSecim,
                    isExpanded: true,
                    decoration: const InputDecoration(
                        isDense: true, border: OutlineInputBorder()),
                    items: [
                      for (var i = 0; i < _gvOranEtiketleri.length; i++)
                        DropdownMenuItem(
                            value: i, child: Text(_gvOranEtiketleri[i])),
                    ],
                    onChanged: (v) => setState(() => _gvOraniSecim = v ?? 0),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'GV/DV istisnası, özel sağlık indirimi, BES, sendika, rapor, İLKSAN ve kefalet alanları '
                  'sonuçtaki tahmini kesinti hesabına yansıtılır. Kesin bordro kurum parametresine bağlıdır.',
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
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
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
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            Text(
              'İŞLEMLER',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
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
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Kadro: $_kadroUnvan · Ay: ${kAylar12[_ayIndex]} · '
                'Derece/ kademe: $_derece / $_kademe · Medeni: ${_medeniEtiketler[_medeniHal]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _bordroTablosu(
                  context, _sonuc!, d, _nafakaToplami(), _gvOraniSecim),
            ],
            const SizedBox(height: 28),
            Text(
              'NOTLAR',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '1. Burada yer alan bilgiler yalnızca bilgilendirme amaçlıdır; yanlış veya eksik girişten doğan '
              'hatalardan uygulama sorumlu tutulamaz.\n\n'
              '2. Bilgi girişinde değişiklik yaptıktan sonra sonucu güncellemek için tekrar HESAPLA’ya basınız.',
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45),
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
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv(context, 'Taban aylık (cetvel)', _tryFormat(d.tabanAylik)),
          const SizedBox(height: 6),
          _kv(context, 'Memur aylık katsayısı',
              d.memurAylikKatsayisi.toStringAsFixed(6)),
          const SizedBox(height: 6),
          _kv(context, 'Tahmini net oranı (JSON)',
              '%${(d.tahminiNetOrani * 100).toStringAsFixed(1)}'),
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
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
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
              s.brut * (1 - d.tahminiNetOrani),
            ),
            const SizedBox(height: 8),
            if (s.vergiIstisnaEtkisi > 0) ...[
              _bordroSatir(
                context,
                'GV/DV istisnası etkisi',
                s.vergiIstisnaEtkisi,
              ),
              const SizedBox(height: 8),
            ],
            if (s.ozelSaglikVergiEtkisi > 0) ...[
              _bordroSatir(
                context,
                'Özel sağlık sig. vergi etkisi',
                s.ozelSaglikVergiEtkisi,
              ),
              const SizedBox(height: 8),
            ],
            if (s.raporKesintisi > 0) ...[
              _bordroSatir(context, 'Raporlu gün kesintisi', -s.raporKesintisi),
              const SizedBox(height: 8),
            ],
            if (s.sendikaKesintisi > 0) ...[
              _bordroSatir(context, 'Sendika kesintisi', -s.sendikaKesintisi),
              const SizedBox(height: 8),
            ],
            if (s.besKesintisi > 0) ...[
              _bordroSatir(context, 'Otomatik BES kesintisi', -s.besKesintisi),
              const SizedBox(height: 8),
            ],
            if (s.ilksanKesintisi > 0) ...[
              _bordroSatir(context, 'İLKSAN kesintisi', -s.ilksanKesintisi),
              const SizedBox(height: 8),
            ],
            if (s.kefaletKesintisi > 0) ...[
              _bordroSatir(
                  context, 'Kefalet / TKKY kesintisi', -s.kefaletKesintisi),
              const SizedBox(height: 8),
            ],
            _bordroSatir(
              context,
              'Tahmini toplam bordro kesintisi',
              s.tahminiKesinti,
              vurgu: true,
            ),
            const SizedBox(height: 8),
            if (nafakaToplam > 0) ...[
              _bordroSatir(context, 'Tahmini bordro neti', s.tahminiNet,
                  vurgu: true),
              const SizedBox(height: 8),
              _bordroSatir(context, 'Nafaka / icra / kira / diğer (düşülür)',
                  -nafakaToplam),
              const SizedBox(height: 8),
              _bordroSatir(context, 'Tahmini elde kalan', s.eldeKalan,
                  buyuk: true),
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
              'Diğer veriler bölümü MAHEP alanlarına yakın bir yerel modeldir. Kurum bordrosundaki özel '
              'unvan katsayıları, vergi matrahı ve kesinti ayrıntıları değişebileceğinden sonuç tahminidir.',
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
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
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w800)
        : vurgu
            ? Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w700)
            : Theme.of(context).textTheme.bodyMedium;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: style?.copyWith(
                fontWeight: vurgu || buyuk ? FontWeight.w700 : null),
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
