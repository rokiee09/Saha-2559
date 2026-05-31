import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../common/theme/police_colors.dart';
import '../../haklar/vardiya/vardiya_ui_widgets.dart';
import 'lojman_puani_calculator.dart';

final _dateFmt = DateFormat('dd.MM.yyyy', 'tr_TR');

class LojmanPuaniPage extends StatefulWidget {
  const LojmanPuaniPage({super.key});

  @override
  State<LojmanPuaniPage> createState() => _LojmanPuaniPageState();
}

class _LojmanPuaniPageState extends State<LojmanPuaniPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  DateTime? _iseBaslama;
  bool _esCalisiyor = false;
  bool _evli = false;
  bool _gelirSiniriAsildi = false;

  int _cocukSayisi = 0;
  final _gaziCtrl = TextEditingController(text: '0');
  final _engelliCtrl = TextEditingController(text: '0');
  final _digerAileCtrl = TextEditingController(text: '0');
  final _beklenenYilCtrl = TextEditingController(text: '0');
  final _beklenenAyCtrl = TextEditingController(text: '0');
  final _askerlikAyCtrl = TextEditingController(text: '0');
  final _oncekiYilCtrl = TextEditingController(text: '0');
  final _oncekiAyCtrl = TextEditingController(text: '0');
  final _ilIciKonutCtrl = TextEditingController(text: '0');
  final _ilDisiKonutCtrl = TextEditingController(text: '0');

  LojmanPuaniSonuc? _sonuc;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _gaziCtrl.dispose();
    _engelliCtrl.dispose();
    _digerAileCtrl.dispose();
    _beklenenYilCtrl.dispose();
    _beklenenAyCtrl.dispose();
    _askerlikAyCtrl.dispose();
    _oncekiYilCtrl.dispose();
    _oncekiAyCtrl.dispose();
    _ilIciKonutCtrl.dispose();
    _ilDisiKonutCtrl.dispose();
    super.dispose();
  }

  int _int(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  LojmanPuaniGirdi _girdi() => LojmanPuaniGirdi(
        iseBaslama: _iseBaslama,
        esCalisiyor: _esCalisiyor,
        evli: _evli,
        cocukSayisi: _cocukSayisi,
        gaziYakini: _int(_gaziCtrl),
        engelliAileFerdi: _int(_engelliCtrl),
        digerAileFerdi: _int(_digerAileCtrl),
        beklenenYil: _int(_beklenenYilCtrl),
        beklenenAy: _int(_beklenenAyCtrl),
        askerlikAy: _int(_askerlikAyCtrl),
        gelirSiniriAsildi: _gelirSiniriAsildi,
        oncekiKonutYil: _int(_oncekiYilCtrl),
        oncekiKonutAy: _int(_oncekiAyCtrl),
        ilIciKonut: _int(_ilIciKonutCtrl),
        ilDisiKonut: _int(_ilDisiKonutCtrl),
      );

  Future<void> _tarihSec() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _iseBaslama ?? DateTime(now.year - 8, now.month, now.day),
      firstDate: DateTime(1980),
      lastDate: now,
      locale: const Locale('tr', 'TR'),
    );
    if (picked == null) return;
    setState(() => _iseBaslama = picked);
  }

  void _hesapla() {
    HapticFeedback.mediumImpact();
    setState(() => _sonuc = hesaplaLojmanPuani(_girdi()));
    _tabs.animateTo(0);
  }

  void _temizle() {
    setState(() {
      _iseBaslama = null;
      _esCalisiyor = false;
      _evli = false;
      _gelirSiniriAsildi = false;
      _cocukSayisi = 0;
      for (final c in [
        _gaziCtrl,
        _engelliCtrl,
        _digerAileCtrl,
        _beklenenYilCtrl,
        _beklenenAyCtrl,
        _askerlikAyCtrl,
        _oncekiYilCtrl,
        _oncekiAyCtrl,
        _ilIciKonutCtrl,
        _ilDisiKonutCtrl,
      ]) {
        c.text = '0';
      }
      _sonuc = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VardiyaUi.pageBackground,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Lojman Puanı Hesaplama'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: PoliceColors.primaryBlue,
          labelColor: PoliceColors.titleOnDark,
          unselectedLabelColor: PoliceColors.textMuted,
          tabs: const [
            Tab(
                icon: Icon(Icons.calculate_outlined, size: 20),
                text: 'Hesapla'),
            Tab(
                icon: Icon(Icons.description_outlined, size: 20),
                text: 'Örnek'),
            Tab(icon: Icon(Icons.info_outline_rounded, size: 20), text: 'Not'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildHesapTab(),
          _OrnekRaporTab(),
          const _YonergeNotuTab(),
        ],
      ),
    );
  }

  Widget _buildHesapTab() {
    final hizmet = lojmanHizmetSuresi(_iseBaslama);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _HeroCard(sonuc: _sonuc),
        const SizedBox(height: 12),
        VardiyaSectionCard(
          title: 'Kişisel bilgiler',
          subtitle:
              'Aile durumu ve hizmet süresi puanı bu bölümden hesaplanır.',
          child: Column(
            children: [
              _DatePickTile(
                title: 'İşe başlama tarihi',
                subtitle: _iseBaslama == null
                    ? 'Hizmet yılı/ayı için tarih seçin.'
                    : 'Hizmet: ${hizmet.yil} yıl ${hizmet.ay} ay',
                value: _iseBaslama == null
                    ? 'Tarih seçiniz'
                    : _dateFmt.format(_iseBaslama!),
                onTap: _tarihSec,
              ),
              const SizedBox(height: 10),
              _SwitchRow(
                icon: PhosphorIconsRegular.user,
                label: 'Medeni durum: evli',
                value: _evli,
                onChanged: (v) => setState(() => _evli = v),
              ),
              _SwitchRow(
                icon: PhosphorIconsRegular.users,
                label: 'Eşim çalışıyor',
                value: _esCalisiyor,
                onChanged: (v) => setState(() => _esCalisiyor = v),
              ),
              _CounterRow(
                icon: PhosphorIconsRegular.baby,
                label: 'Çocuk sayısı',
                value: _cocukSayisi,
                onChanged: (v) => setState(() => _cocukSayisi = v),
              ),
              const SizedBox(height: 10),
              _NumField(
                controller: _gaziCtrl,
                icon: PhosphorIconsRegular.shieldStar,
                label: 'Gazi / şehit yakını',
                helper: 'Gazilerin kendileri ve şehit yakınları.',
              ),
              const SizedBox(height: 10),
              _NumField(
                controller: _engelliCtrl,
                icon: PhosphorIconsRegular.wheelchair,
                label: 'Engelli aile ferdi',
                helper: '%40 üzeri bakmakla yükümlü olunan aile ferdi.',
              ),
              const SizedBox(height: 10),
              _NumField(
                controller: _digerAileCtrl,
                icon: PhosphorIconsRegular.usersThree,
                label: 'Diğer aile fertleri',
                helper: 'Bakmakla yükümlü olunan diğer aile fertleri.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        VardiyaSectionCard(
          title: 'Lojman bekleme ve askerlik',
          subtitle:
              'Bekleme süresi, lojman talebinizin/başvurunuzun sırada beklediği toplam süredir.',
          child: Column(
            children: [
              _NumField(
                controller: _beklenenYilCtrl,
                icon: PhosphorIconsRegular.hourglass,
                label: 'Lojman için beklenen yıl',
                helper:
                    'Başvuru/talep sonrası lojman sırası için beklenen tam yıl.',
              ),
              const SizedBox(height: 12),
              _NumField(
                controller: _beklenenAyCtrl,
                icon: PhosphorIconsRegular.hourglassLow,
                label: 'Lojman için beklenen ay',
                helper: 'Tam yıl dışındaki ilave bekleme ayı.',
              ),
              const SizedBox(height: 12),
              _NumField(
                controller: _askerlikAyCtrl,
                icon: PhosphorIconsRegular.shield,
                label: 'Askerlik hizmetinden sayılan süre (ay)',
                helper:
                    'Lojman puanına hizmet süresi gibi eklenen askerlik ayı varsa girin.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        VardiyaSectionCard(
          title: 'Negatif puanlar',
          subtitle:
              'Önceki konut kullanımı ve konut sahipliği düşüm oluşturur.',
          child: Column(
            children: [
              _SwitchRow(
                icon: PhosphorIconsRegular.currencyDollarSimple,
                label: 'Yıllık gelir sınırı aşıldı',
                value: _gelirSiniriAsildi,
                negative: true,
                onChanged: (v) => setState(() => _gelirSiniriAsildi = v),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _NumField(
                      controller: _oncekiYilCtrl,
                      icon: PhosphorIconsRegular.house,
                      label: 'Önceki kullanım yıl',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _NumField(
                      controller: _oncekiAyCtrl,
                      icon: PhosphorIconsRegular.houseLine,
                      label: 'Önceki kullanım ay',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _NumField(
                controller: _ilIciKonutCtrl,
                icon: PhosphorIconsRegular.buildings,
                label: 'İl içi konut',
                helper: 'İl içinde sahip olunan konut sayısı.',
              ),
              const SizedBox(height: 10),
              _NumField(
                controller: _ilDisiKonutCtrl,
                icon: PhosphorIconsRegular.mapPin,
                label: 'İl dışı konut',
                helper: 'İl dışında sahip olunan konut sayısı.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        VardiyaPrimaryButton(label: 'Puan Hesapla', onPressed: _hesapla),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: _temizle, child: const Text('Temizle')),
        if (_sonuc != null) ...[
          const SizedBox(height: 14),
          _SonucCard(sonuc: _sonuc!),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.sonuc});
  final LojmanPuaniSonuc? sonuc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PoliceColors.primaryBlue.withValues(alpha: 0.28),
            PoliceColors.surfaceDark,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: PoliceColors.primaryBlue.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const PhosphorIcon(
            PhosphorIconsRegular.houseLine,
            color: PoliceColors.primaryBlue,
            size: 38,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sonuc == null
                      ? 'Lojman puanı'
                      : 'Toplam: ${_puan(sonuc!.toplam)}',
                  style: const TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Emniyet lojman yönergesindeki yaygın puan kalemlerine göre yerel hesaplama.',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.94),
                    height: 1.35,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickTile extends StatelessWidget {
  const _DatePickTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PoliceColors.surfaceDarkElevated,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const PhosphorIcon(
                PhosphorIconsRegular.calendarBlank,
                color: PoliceColors.primaryBlue,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _labelStyle),
                    const SizedBox(height: 2),
                    Text(subtitle, style: _helperStyle),
                  ],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.negative = false,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    final color = negative ? Colors.redAccent : PoliceColors.primaryBlue;
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      secondary: PhosphorIcon(icon, color: color),
      title: Text(label, style: _labelStyle),
      value: value,
      activeThumbColor: color,
      onChanged: onChanged,
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PhosphorIcon(icon, color: PoliceColors.gold),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: _labelStyle)),
        IconButton(
          onPressed: value <= 0 ? null : () => onChanged(value - 1),
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          '$value',
          style: const TextStyle(
            color: PoliceColors.titleOnDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        IconButton(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add_circle, color: PoliceColors.gold),
        ),
      ],
    );
  }
}

class _NumField extends StatelessWidget {
  const _NumField({
    required this.controller,
    required this.icon,
    required this.label,
    this.helper,
  });

  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: PoliceColors.titleOnDark),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child:
                  PhosphorIcon(icon, color: PoliceColors.textMuted, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            filled: true,
            fillColor: PoliceColors.surfaceDarkElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: PoliceColors.outlineMuted),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: PoliceColors.outlineMuted.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 6),
            child: Text(
              helper!,
              style: _helperStyle,
            ),
          ),
        ],
      ],
    );
  }
}

class _SonucCard extends StatelessWidget {
  const _SonucCard({required this.sonuc});
  final LojmanPuaniSonuc sonuc;

  @override
  Widget build(BuildContext context) {
    return VardiyaSectionCard(
      title: 'Puan dökümü',
      subtitle: 'Pozitif ve negatif kalemler ayrı satırda gösterilir.',
      child: Column(
        children: [
          for (final row in sonuc.satirlar)
            _ReportRow(label: row.aciklama, value: _puan(row.sonuc)),
          const Divider(height: 24, color: PoliceColors.outlineMuted),
          _ReportRow(
            label: 'Toplam puan',
            value: _puan(sonuc.toplam),
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _OrnekRaporTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sonuc = hesaplaLojmanPuani(
      ornekLojmanGirdi,
      now: DateTime(2026, 1, 30),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        VardiyaSectionCard(
          title: 'Örnek lojman puan raporu',
          subtitle: 'Ekran görüntüsündeki örnek değerlere yakın model.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'POLİS 2559',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PoliceColors.gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lojman Puan Raporu · ${_dateFmt.format(DateTime(2026, 1, 30))}',
                textAlign: TextAlign.center,
                style: _helperStyle,
              ),
              const SizedBox(height: 18),
              for (final row in sonuc.satirlar)
                _ReportRow(
                  label: row.aciklama,
                  value: _puan(row.sonuc),
                  detail: '${row.deger} × ${_puan(row.katsayi)}',
                ),
              const Divider(height: 24, color: PoliceColors.outlineMuted),
              _ReportRow(
                label: 'Toplam puan',
                value: _puan(sonuc.toplam),
                strong: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _YonergeNotuTab extends StatelessWidget {
  const _YonergeNotuTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: const [
        VardiyaInfoBanner(
          text:
              'Bu hesaplama kişisel takip ve ön değerlendirme içindir. Kesin sıra, puan ve tahsis işlemlerinde yürürlükteki Emniyet Genel Müdürlüğü lojman yönergesi ve kurum değerlendirmesi esas alınır.',
        ),
        SizedBox(height: 12),
        VardiyaSectionCard(
          title: 'Hesaba dahil edilen kalemler',
          child: Text(
            'Medeni durum, eşin çalışma durumu, çocuk sayısı, gazi/şehit yakını, engelli aile ferdi, hizmet süresi, lojman için bekleme süresi, askerlik süresi, gelir sınırı, önceki konut kullanımı ve sahip olunan konut bilgileri.',
            style: TextStyle(
              color: PoliceColors.textMuted,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.label,
    required this.value,
    this.detail,
    this.strong = false,
  });

  final String label;
  final String value;
  final String? detail;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
                    fontSize: strong ? 15.5 : 13.5,
                  ),
                ),
                if (detail != null)
                  Text(
                    detail!,
                    style: _helperStyle,
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: strong ? PoliceColors.gold : PoliceColors.textMuted,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
              fontSize: strong ? 17 : 13.5,
            ),
          ),
        ],
      ),
    );
  }
}

const _labelStyle = TextStyle(
  color: PoliceColors.titleOnDark,
  fontWeight: FontWeight.w700,
  fontSize: 14.5,
);

final _helperStyle = TextStyle(
  color: PoliceColors.textMuted.withValues(alpha: 0.9),
  fontSize: 12.2,
  height: 1.3,
);

String _puan(double v) {
  final fixed = v.toStringAsFixed(2);
  if (fixed.endsWith('00')) return v.toStringAsFixed(0);
  if (fixed.endsWith('0')) return v.toStringAsFixed(1);
  return fixed;
}
