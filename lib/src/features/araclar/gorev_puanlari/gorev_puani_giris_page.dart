import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../common/text/tr_text.dart';
import '../../../common/theme/police_colors.dart';
import 'gorev_puan_cetvel_policy.dart';
import 'gorev_puan_sark_prefs.dart';
import 'gorev_puani_calculator.dart';
import 'gorev_puani_kayit_provider.dart';
import 'gorev_puanlari_data.dart';
import 'gorev_puanlari_page.dart';

/// EGM görev (hizmet) puanı hesaplama — görev yerleri ve süreleri girilir,
/// dönem puanları toplanarak genel hizmet puanı görülür.
class GorevPuaniGirisPage extends ConsumerStatefulWidget {
  const GorevPuaniGirisPage({super.key, this.tercihYil});

  /// Hub'dan 2025 veya 2026 hesaplama ile açıldığında cetvel tercihi.
  final int? tercihYil;

  @override
  ConsumerState<GorevPuaniGirisPage> createState() =>
      _GorevPuaniGirisPageState();
}

class _GorevPuaniGirisPageState extends ConsumerState<GorevPuaniGirisPage> {
  String? _secilenYerKey;
  DateTime? _baslangic;
  DateTime? _bitis;
  bool _halenGorevde = false;
  bool _kaydediliyor = false;
  bool _bilgiAcik = false;

  static final _tarihFmt = DateFormat('dd.MM.yyyy');

  DateTime? get _bitisEtkin {
    if (_baslangic == null) return null;
    if (_halenGorevde) return DateTime.now();
    return _bitis;
  }

  int get _gunSayisi {
    if (_baslangic == null || _bitisEtkin == null) return 0;
    return gorevPuaniGunSayisi(_baslangic!, _bitisEtkin!);
  }

  int _aktifCetvelYili(
    GorevPuanlariSet set2025,
    GorevPuanlariSet set2026,
    DateTime? sarkBaslangic,
  ) {
    if (_baslangic == null || _bitisEtkin == null) {
      return widget.tercihYil ?? 2025;
    }
    final otomatik = gorevPuanCetvelYiliSarkIle(
      baslangic: _baslangic!,
      bitis: _bitisEtkin!,
      sarkBaslangic: sarkBaslangic,
    );
    if (widget.tercihYil != null) return widget.tercihYil!;
    return otomatik;
  }

  double? _gunlukPuan(
    GorevPuanlariSet set2025,
    GorevPuanlariSet set2026,
    DateTime? sarkBaslangic,
  ) {
    if (_secilenYerKey == null) return null;
    final yil = _aktifCetvelYili(set2025, set2026, sarkBaslangic);
    final set = yil == 2026 ? set2026 : set2025;
    return set.bul(_secilenYerKey!)?.puan;
  }

  double get _donemPuan {
    final ikili = ref.read(gorevPuanlariIkiliProvider).valueOrNull;
    final sark = ref.read(gorevPuanSarkBaslangicProvider).valueOrNull;
    if (ikili == null || _gunSayisi <= 0) return 0;
    final gunluk = _gunlukPuan(ikili.$1, ikili.$2, sark);
    if (gunluk == null || gunluk <= 0) return 0;
    return gorevPuaniToplam(gunluk, _gunSayisi);
  }

  Future<void> _sehirSec(
    GorevPuanlariSet set2025,
    GorevPuanlariSet set2026,
  ) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PoliceColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SehirSecimSheet(
        set2025: set2025,
        set2026: set2026,
      ),
    );
    if (picked != null) {
      setState(() => _secilenYerKey = picked);
    }
  }

  Future<void> _tarihSec({required bool baslangic}) async {
    final now = DateTime.now();
    final initial =
        baslangic ? (_baslangic ?? now) : (_bitis ?? _baslangic ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 2),
      locale: const Locale('tr', 'TR'),
    );
    if (picked == null) return;
    setState(() {
      if (baslangic) {
        _baslangic = picked;
        if (!_halenGorevde && _bitis != null && _bitis!.isBefore(picked)) {
          _bitis = picked;
        }
      } else {
        _halenGorevde = false;
        _bitis = picked;
        if (_baslangic != null && picked.isBefore(_baslangic!)) {
          _baslangic = picked;
        }
      }
    });
  }

  void _formuTemizle() {
    setState(() {
      _secilenYerKey = null;
      _baslangic = null;
      _bitis = null;
      _halenGorevde = false;
    });
  }

  Future<void> _kaydet() async {
    final ikili = ref.read(gorevPuanlariIkiliProvider).valueOrNull;
    final sark = ref.read(gorevPuanSarkBaslangicProvider).valueOrNull;
    if (ikili == null) {
      _uyari('Puan cetveli yüklenemedi.');
      return;
    }
    if (_secilenYerKey == null) {
      _uyari('Önce görev yerini seçin.');
      return;
    }
    final gunluk = _gunlukPuan(ikili.$1, ikili.$2, sark);
    if (gunluk == null || gunluk <= 0) {
      _uyari(
        widget.tercihYil == 2026
            ? '2026 cetvelinde bu yer için puan yok. Tabloyu yükleyin veya 2025 bölümünü kullanın.'
            : 'Bu görev yeri için günlük puan bulunamadı.',
      );
      return;
    }
    if (_baslangic == null) {
      _uyari('Göreve başlama tarihini seçin.');
      return;
    }
    if (!_halenGorevde && _bitis == null) {
      _uyari('Bitiş tarihini seçin veya "Halen görevdeyim" işaretleyin.');
      return;
    }
    if (_gunSayisi <= 0) {
      _uyari('Geçerli bir görev süresi girin.');
      return;
    }

    final bitisKayit = _halenGorevde ? DateTime.now() : _bitis!;
    final yerAdi = displayGorevYeriAdi(_secilenYerKey!);
    final cetvelYili = _aktifCetvelYili(ikili.$1, ikili.$2, sark);

    setState(() => _kaydediliyor = true);
    await gorevPuaniKayitEkle(
      ref,
      GorevPuaniKaydi(
        id: gorevPuaniKayitId(),
        yer: _secilenYerKey!,
        gunlukPuan: gunluk,
        cetvelYili: cetvelYili,
        baslangicMs: _baslangic!.millisecondsSinceEpoch,
        bitisMs: bitisKayit.millisecondsSinceEpoch,
        gunSayisi: _gunSayisi,
        toplamPuan: _donemPuan,
        halenGorevde: _halenGorevde,
        olusturulmaMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (!mounted) return;
    setState(() => _kaydediliyor = false);
    HapticFeedback.mediumImpact();
    _formuTemizle();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$yerAdi dönemi kaydedildi. Başka bir görev yeri ekleyebilirsiniz.',
        ),
      ),
    );
  }

  void _uyari(String msg) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cetvelAsync = ref.watch(gorevPuanlariIkiliProvider);
    final sarkAsync = ref.watch(gorevPuanSarkBaslangicProvider);
    final kayitlarAsync = ref.watch(gorevPuaniKayitlariProvider);
    final genelToplam = ref.watch(gorevPuaniGenelToplamProvider);

    final baslik = widget.tercihYil == 2026
        ? '2026 Görev Puanı'
        : widget.tercihYil == 2025
            ? '2025 Görev Puanı'
            : 'Görev Puanı Hesapla';

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: Text(baslik),
        actions: [
          IconButton(
            tooltip: 'Günlük görev puanları cetveli',
            icon: const PhosphorIcon(
              PhosphorIconsRegular.listBullets,
              color: PoliceColors.titleOnDark,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => GorevPuanlariPage(
                  baslangicYil: widget.tercihYil ?? 2025,
                ),
              ),
            ),
          ),
        ],
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      body: cetvelAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
        ),
        error: (_, __) => const Center(
          child: Text(
            'Puan cetveli yüklenemedi.',
            style: TextStyle(color: PoliceColors.textMuted),
          ),
        ),
        data: (ikili) {
          final set2025 = ikili.$1;
          final set2026 = ikili.$2;
          final sark = sarkAsync.valueOrNull;
          final kayitlar = kayitlarAsync.valueOrNull ?? const [];
          final onizlemeGenel = genelToplam + _donemPuan;
          final kayitliDonemSayisi = kayitlar.length;
          final gunluk = _gunlukPuan(set2025, set2026, sark);
          final aktifYil = _aktifCetvelYili(set2025, set2026, sark);
          final p2025 = _secilenYerKey != null
              ? set2025.bul(_secilenYerKey!)?.puan
              : null;
          final p2026 = _secilenYerKey != null
              ? set2026.bul(_secilenYerKey!)?.puan
              : null;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _GenelToplamCard(
                genelToplam: onizlemeGenel,
                kayitliDonemSayisi: kayitliDonemSayisi,
                taslakVar: _donemPuan > 0,
              ),
              const SizedBox(height: 14),
              _BilgiPaneli(
                acik: _bilgiAcik,
                onToggle: () => setState(() => _bilgiAcik = !_bilgiAcik),
              ),
              if (widget.tercihYil != null &&
                  _baslangic != null &&
                  _bitisEtkin != null) ...[
                const SizedBox(height: 10),
                _CetvelUyariBand(
                  tercihYil: widget.tercihYil!,
                  aktifYil: aktifYil,
                  baslangic: _baslangic!,
                  bitis: _bitisEtkin!,
                ),
              ],
              if (sark != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Şark başlangıcı: ${_tarihFmt.format(sark)}',
                  style: TextStyle(
                    color: PoliceColors.primaryBlue.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Görev Yeri',
                child: Column(
                  children: [
                    if (_secilenYerKey == null)
                      Text(
                        'Henüz bir görev yeri seçilmedi.',
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      )
                    else ...[
                      Text(
                        displayGorevYeriAdi(_secilenYerKey!),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: PoliceColors.titleOnDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (p2025 != null)
                        Text(
                          '2025 günlük puan: ${formatGorevPuani(p2025)}',
                          style: TextStyle(
                            color: aktifYil == 2025
                                ? PoliceColors.primaryBlue
                                : PoliceColors.textMuted
                                    .withValues(alpha: 0.85),
                            fontSize: 13,
                            fontWeight: aktifYil == 2025
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      if (p2026 != null)
                        Text(
                          '2026 günlük puan: ${formatGorevPuani(p2026)}',
                          style: TextStyle(
                            color: aktifYil == 2026
                                ? PoliceColors.primaryBlue
                                : PoliceColors.textMuted
                                    .withValues(alpha: 0.85),
                            fontSize: 13,
                            fontWeight: aktifYil == 2026
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        )
                      else if (set2026.bos)
                        Text(
                          '2026 cetveli henüz yüklenmedi.',
                          style: TextStyle(
                            color: PoliceColors.textMuted.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      if (gunluk != null && _baslangic != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Hesapta kullanılan ($aktifYil): ${formatGorevPuani(gunluk)}',
                          style: const TextStyle(
                            color: PoliceColors.titleOnDark,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _sehirSec(set2025, set2026),
                        style: FilledButton.styleFrom(
                          backgroundColor: PoliceColors.primaryBlue,
                          foregroundColor: PoliceColors.titleOnDark,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Görev Yeri Seç',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Görev Süresi',
                child: Column(
                  children: [
                    _DateField(
                      hint: 'Göreve Başlama Tarihi',
                      value: _baslangic == null
                          ? null
                          : _tarihFmt.format(_baslangic!),
                      onTap: () => _tarihSec(baslangic: true),
                    ),
                    const SizedBox(height: 10),
                    if (!_halenGorevde)
                      _DateField(
                        hint: 'Görev Bitiş Tarihi',
                        value:
                            _bitis == null ? null : _tarihFmt.format(_bitis!),
                        onTap: () => _tarihSec(baslangic: false),
                      )
                    else
                      _DateField(
                        hint: 'Görev Bitiş Tarihi',
                        value: 'Bugün (${_tarihFmt.format(DateTime.now())})',
                        onTap: () {},
                        enabled: false,
                      ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _halenGorevde,
                      activeThumbColor: PoliceColors.primaryBlue,
                      title: const Text(
                        'Halen bu görevdeyim',
                        style: TextStyle(
                          color: PoliceColors.titleOnDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Bitiş tarihi otomatik olarak bugün alınır.',
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                      onChanged: (v) => setState(() {
                        _halenGorevde = v;
                        if (v) _bitis = null;
                      }),
                    ),
                    if (_gunSayisi > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        gorevPuaniSureMetni(_gunSayisi),
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.85),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Dönem Puanı',
                child: Column(
                  children: [
                    Text(
                      formatGorevPuani(_donemPuan),
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 36,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Puan',
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                    if (gunluk != null && _gunSayisi > 0) ...[
                      const SizedBox(height: 10),
                      Text(
                        '${formatGorevPuani(gunluk)} ($aktifYil) × $_gunSayisi gün',
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Günlük görev yeri puanı × çalışılan gün sayısı',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              PoliceColors.primaryBlue.withValues(alpha: 0.85),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _kaydediliyor ? null : _kaydet,
                  icon: _kaydediliyor
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_rounded),
                  label: const Text(
                    'Dönemi Kaydet',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (kayitlar.isNotEmpty) ...[
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Text(
                      'Görev Dönemlerim',
                      style: TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$kayitliDonemSayisi dönem',
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.85),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Her görev yeri ve süresi ayrı kaydedilir; genel hizmet '
                  'puanınız bunların toplamıdır.',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.75),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                ...kayitlar.map((k) => _KayitTile(
                      kayit: k,
                      onDelete: () => gorevPuaniKayitSil(ref, k.id),
                    )),
              ],
              const SizedBox(height: 12),
              Text(
                'Kesin görev puanı POL-NET üzerinden tebliğ edilir; yıllık '
                'izin vb. süreler resmî hesapta çalışılan gün sayılabilir. '
                'Bu araç tahmini hesap içindir.',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.65),
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GenelToplamCard extends StatelessWidget {
  const _GenelToplamCard({
    required this.genelToplam,
    required this.kayitliDonemSayisi,
    required this.taslakVar,
  });

  final double genelToplam;
  final int kayitliDonemSayisi;
  final bool taslakVar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PoliceColors.primaryBlue.withValues(alpha: 0.22),
            PoliceColors.surfaceDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Genel Hizmet Puanı',
            style: TextStyle(
              color: PoliceColors.titleOnDark.withValues(alpha: 0.92),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatGorevPuani(genelToplam),
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w800,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            kayitliDonemSayisi == 0 && !taslakVar
                ? 'Görev yerlerinizi ve sürelerinizi ekleyin'
                : taslakVar && kayitliDonemSayisi > 0
                    ? '$kayitliDonemSayisi kayıtlı dönem + taslak dönem'
                    : taslakVar
                        ? 'Taslak dönem dahil'
                        : '$kayitliDonemSayisi görev dönemi toplamı',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BilgiPaneli extends StatelessWidget {
  const _BilgiPaneli({required this.acik, required this.onToggle});

  final bool acik;
  final VoidCallback onToggle;

  static const _kriterler = [
    (
      'SEGE',
      'Sosyo-ekonomik gelişmişlik sıralaması — az gelişmiş bölgeler daha yüksek puan.',
    ),
    (
      'Tercih',
      'Son 5 yılda il/ilçenin tercih edilme ve atanma oranları.',
    ),
    (
      'İş yükü',
      'Birimde personel başına düşen olay sayısı.',
    ),
    (
      'Ek puan',
      'İstanbul ve 1./2. bölge (şark) hizmeti için ek puan.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PoliceColors.surfaceDark,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: PoliceColors.outlineMuted.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: PoliceColors.primaryBlue.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'EGM puan sistemi nasıl çalışır?',
                      style: TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  Icon(
                    acik ? Icons.expand_less : Icons.expand_more,
                    color: PoliceColors.textMuted,
                  ),
                ],
              ),
              if (acik) ...[
                const SizedBox(height: 10),
                Text(
                  'Mart 2025 yönetmeliğiyle tayinlerde görev puanı esas alınır. '
                  'Her il/ilçenin günlük görev yeri puanı aşağıdaki kriterlerle '
                  'belirlenir; görev puanı = günlük puan × çalışılan gün sayısı.',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.9),
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                ..._kriterler.map(
                  (k) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${k.$1}: ',
                          style: const TextStyle(
                            color: PoliceColors.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            k.$2,
                            style: TextStyle(
                              color: PoliceColors.textMuted
                                  .withValues(alpha: 0.88),
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.outlineMuted.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Divider(
            height: 1,
            color: PoliceColors.outlineMuted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.hint,
    required this.onTap,
    this.value,
    this.enabled = true,
  });

  final String hint;
  final String? value;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return Material(
      color: PoliceColors.surfaceDarkElevated,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: PoliceColors.primaryBlue.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: PoliceColors.primaryBlue.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasValue ? value! : hint,
                  style: TextStyle(
                    color: hasValue
                        ? PoliceColors.titleOnDark
                        : PoliceColors.textMuted.withValues(alpha: 0.75),
                    fontSize: 14.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CetvelUyariBand extends StatelessWidget {
  const _CetvelUyariBand({
    required this.tercihYil,
    required this.aktifYil,
    required this.baslangic,
    required this.bitis,
  });

  final int tercihYil;
  final int aktifYil;
  final DateTime baslangic;
  final DateTime bitis;

  @override
  Widget build(BuildContext context) {
    if (tercihYil == aktifYil) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF3D2A10).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade700.withValues(alpha: 0.6)),
      ),
      child: Text(
        '$tercihYil hesaplama bölümündesiniz; görev tarihlerinize göre '
        'otomatik cetvel $aktifYil olarak seçildi. '
        '(${DateFormat('dd.MM.yyyy').format(baslangic)} – '
        '${DateFormat('dd.MM.yyyy').format(bitis)})',
        style: TextStyle(
          color: PoliceColors.titleOnDark.withValues(alpha: 0.9),
          fontSize: 11.5,
          height: 1.35,
        ),
      ),
    );
  }
}

class _SehirSecimSheet extends StatefulWidget {
  const _SehirSecimSheet({
    required this.set2025,
    required this.set2026,
  });

  final GorevPuanlariSet set2025;
  final GorevPuanlariSet set2026;

  @override
  State<_SehirSecimSheet> createState() => _SehirSecimSheetState();
}

class _SehirSecimSheetState extends State<_SehirSecimSheet> {
  final _ctrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<GorevPuaniIkiliSatir> get _filtered {
    return gorevPuaniIkiliListe(widget.set2025, widget.set2026, query: _q);
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    final maxH = MediaQuery.sizeOf(context).height * 0.82;
    return SafeArea(
      child: SizedBox(
        height: maxH,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PoliceColors.outlineMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text(
                'Görev yeri seç — 2025 / 2026 puanları',
                style: TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'İl ve ilçe için her iki yılın günlük puanı ayrı gösterilir.',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _ctrl,
                onChanged: (v) => setState(() => _q = v),
                style: const TextStyle(color: PoliceColors.titleOnDark),
                decoration: InputDecoration(
                  hintText: 'İl veya ilçe ara',
                  hintStyle: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.65),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: PoliceColors.textMuted,
                  ),
                  filled: true,
                  fillColor: PoliceColors.backgroundDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        'Eşleşen yer yok.',
                        style: TextStyle(color: PoliceColors.textMuted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color:
                            PoliceColors.outlineMuted.withValues(alpha: 0.25),
                      ),
                      itemBuilder: (context, i) {
                        final s = items[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            displayGorevYeriAdi(s.yer),
                            style: const TextStyle(
                              color: PoliceColors.titleOnDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            '2025: ${s.puan2025Metni}  ·  2026: ${s.puan2026Metni}',
                            style: TextStyle(
                              color: PoliceColors.textMuted.withValues(alpha: 0.88),
                              fontSize: 11.5,
                            ),
                          ),
                          onTap: () => Navigator.of(context).pop(s.yer),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KayitTile extends StatelessWidget {
  const _KayitTile({required this.kayit, required this.onDelete});

  final GorevPuaniKaydi kayit;
  final VoidCallback onDelete;

  static final _fmt = DateFormat('dd.MM.yyyy');

  @override
  Widget build(BuildContext context) {
    final gun = kayit.guncelGunSayisi();
    final puan = kayit.guncelToplamPuan();
    final bitisMetni =
        kayit.halenGorevde ? 'devam ediyor' : _fmt.format(kayit.bitisKayitli);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PoliceColors.outlineMuted.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayGorevYeriAdi(kayit.yer),
                  style: const TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_fmt.format(kayit.baslangic)} – $bitisMetni · $gun gün',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Cetvel ${kayit.cetvelYili} · günlük ${formatGorevPuani(kayit.gunlukPuan)}',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.75),
                    fontSize: 11,
                  ),
                ),
                if (kayit.halenGorevde)
                  Text(
                    'Halen görevde · güncel',
                    style: TextStyle(
                      color: PoliceColors.primaryBlue.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            formatGorevPuani(puan),
            style: const TextStyle(
              color: PoliceColors.primaryBlue,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: PoliceColors.textMuted.withValues(alpha: 0.8),
            ),
            onPressed: onDelete,
            tooltip: 'Sil',
          ),
        ],
      ),
    );
  }
}
