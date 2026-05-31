import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../common/theme/police_colors.dart';
import '../../gorevlerim/izin/il_mesafe.dart';
import '../../haklar/vardiya/vardiya_ui_widgets.dart';
import 'harcirah_calculator.dart';
import 'harcirah_kanunu_content.dart';

final _tlFormat = NumberFormat('#,##0.##', 'tr_TR');

/// Yol harcırahı: hesaplama, örnek rapor ve kanun özeti.
class HarcirahHesaplamaPage extends StatefulWidget {
  const HarcirahHesaplamaPage({super.key});

  @override
  State<HarcirahHesaplamaPage> createState() => _HarcirahHesaplamaPageState();
}

class _HarcirahHesaplamaPageState extends State<HarcirahHesaplamaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  String? _nereden;
  String? _nereye;
  final _mesafeCtrl = TextEditingController();
  bool _mesafeManuel = false;

  bool _bekar = true;
  HarcirahEsDurumu _esDurumu = HarcirahEsDurumu.calismiyor;
  int _cocukSayisi = 0;

  final _gunlukCtrl =
      TextEditingController(text: kHarcirahOrnekGunlukUcret.toStringAsFixed(0));
  final _otobusCtrl = TextEditingController();

  HarcirahSonuc? _sonuc;

  List<String> get _iller => kIlAdlariAlfabetik;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _mesafeCtrl.dispose();
    _gunlukCtrl.dispose();
    _otobusCtrl.dispose();
    super.dispose();
  }

  void _guncelleMesafe({bool otomatik = true}) {
    if (_mesafeManuel && !otomatik) return;
    final from = _nereden;
    final to = _nereye;
    if (from == null || to == null || from.isEmpty || to.isEmpty) {
      _mesafeCtrl.text = '0';
      return;
    }
    final km = harcirahMesafeKmTahmin(from, to);
    _mesafeCtrl.text = km.toString();
  }

  int get _mesafeKm => int.tryParse(_mesafeCtrl.text.trim()) ?? 0;

  double get _gunlukUcret =>
      double.tryParse(_gunlukCtrl.text.replaceAll(',', '.').trim()) ??
      kHarcirahOrnekGunlukUcret;

  double get _otobusUcreti =>
      double.tryParse(_otobusCtrl.text.replaceAll(',', '.').trim()) ?? 0;

  HarcirahGirdi _girdiFromForm() => HarcirahGirdi(
        nereden: _nereden ?? '',
        nereye: _nereye ?? '',
        mesafeKm: _mesafeKm,
        bekar: _bekar,
        esDurumu: _esDurumu,
        cocukSayisi: _cocukSayisi,
        gunlukUcret: _gunlukUcret,
        otobusUcreti: _otobusUcreti,
      );

  void _hesapla() {
    HapticFeedback.mediumImpact();
    if (_nereden == null || _nereye == null || _mesafeKm <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen iki il ve geçerli mesafe seçin.')),
      );
      return;
    }
    setState(() => _sonuc = hesaplaHarcirah(_girdiFromForm()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VardiyaUi.pageBackground,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Yol Harcırah Hesaplama'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: PoliceColors.primaryBlue,
          labelColor: PoliceColors.titleOnDark,
          unselectedLabelColor: PoliceColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.calculate_outlined, size: 20), text: 'Hesapla'),
            Tab(icon: Icon(Icons.description_outlined, size: 20), text: 'Örnek Rapor'),
            Tab(icon: Icon(Icons.menu_book_outlined, size: 20), text: 'Harcırah Kanunu'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildHesaplaTab(),
          _buildOrnekRaporTab(),
          _buildKanunTab(),
        ],
      ),
    );
  }

  Widget _buildHesaplaTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        VardiyaSectionCard(
          title: 'Şehir seçimi',
          subtitle: 'İl merkezleri arası tahmini mesafe (km).',
          child: Column(
            children: [
              _IlDropdown(
                label: 'Nereden',
                value: _nereden,
                iller: _iller,
                onChanged: (v) {
                  setState(() {
                    _nereden = v;
                    _guncelleMesafe();
                  });
                },
              ),
              const SizedBox(height: 10),
              _IlDropdown(
                label: 'Nereye',
                value: _nereye,
                iller: _iller,
                onChanged: (v) {
                  setState(() {
                    _nereye = v;
                    _guncelleMesafe();
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Mesafe',
                    style: TextStyle(
                      color: PoliceColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_mesafeKm > 0 ? _mesafeKm : 0} km',
                    style: TextStyle(
                      color: PoliceColors.gold,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mesafeCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: PoliceColors.titleOnDark),
                decoration: _inputDeco('Km (manuel düzenleyebilirsiniz)'),
                onChanged: (_) {
                  setState(() {
                    _mesafeManuel = true;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        VardiyaSectionCard(
          title: 'Durum bilgileri',
          child: Column(
            children: [
              _DurumSwitch(
                label: 'Bekarım',
                value: _bekar,
                onChanged: (v) => setState(() => _bekar = v),
              ),
              _DurumSwitch(
                label: 'Eşim çalışmıyor',
                value: !_bekar && _esDurumu == HarcirahEsDurumu.calismiyor,
                enabled: !_bekar,
                onChanged: (v) {
                  if (!v) return;
                  setState(() {
                    _bekar = false;
                    _esDurumu = HarcirahEsDurumu.calismiyor;
                  });
                },
              ),
              _DurumSwitch(
                label: 'Eşim çalışıyor (memur)',
                value: !_bekar && _esDurumu == HarcirahEsDurumu.memur,
                enabled: !_bekar,
                onChanged: (v) {
                  if (!v) return;
                  setState(() {
                    _bekar = false;
                    _esDurumu = HarcirahEsDurumu.memur;
                  });
                },
              ),
              _DurumSwitch(
                label: 'Eşim çalışıyor (özel sektör)',
                value: !_bekar && _esDurumu == HarcirahEsDurumu.ozelSektor,
                enabled: !_bekar,
                onChanged: (v) {
                  if (!v) return;
                  setState(() {
                    _bekar = false;
                    _esDurumu = HarcirahEsDurumu.ozelSektor;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        VardiyaSectionCard(
          title: 'Çocuk sayısı',
          child: DropdownButtonFormField<int>(
            value: _cocukSayisi,
            dropdownColor: PoliceColors.surfaceDarkElevated,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _inputDeco('Çocuk'),
            items: [
              for (var i = 0; i <= 5; i++)
                DropdownMenuItem(value: i, child: Text('$i Çocuk')),
            ],
            onChanged: (v) => setState(() => _cocukSayisi = v ?? 0),
          ),
        ),
        const SizedBox(height: 12),
        VardiyaSectionCard(
          title: 'Ücret bilgileri',
          child: Column(
            children: [
              TextField(
                controller: _gunlukCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: PoliceColors.titleOnDark),
                decoration: _inputDeco('Günlük harcırah ücreti (TL)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _otobusCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: PoliceColors.titleOnDark),
                decoration: _inputDeco('Otobüs ücreti — kişi başı (TL)'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        VardiyaPrimaryButton(
          label: 'Hesapla',
          onPressed: _hesapla,
        ),
        if (_sonuc != null) ...[
          const SizedBox(height: 16),
          _RaporKarti(
            baslik:
                '${_nereden ?? ''} → ${_nereye ?? ''} · ${_sonuc!.mesafeKm} km',
            sonuc: _sonuc!,
          ),
        ],
        const SizedBox(height: 14),
        const VardiyaInfoBanner(
          text: 'Sonuç tahminidir; kesin harcırah kurum işlemi ve güncel '
              'cetvel ile belirlenir.',
        ),
      ],
    );
  }

  Widget _buildOrnekRaporTab() {
    final ornek = hesaplaHarcirah(ornekHarcirahGirdi);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Text(
          'Denizli → Diyarbakır örnek raporu (KGM ~1243 km, eş memur, 1 çocuk).',
          style: VardiyaUi.bodyMuted(context),
        ),
        const SizedBox(height: 12),
        _RaporKarti(
          baslik:
              'Denizli → Diyarbakır · ${ornek.mesafeKm} km',
          sonuc: ornek,
        ),
        const SizedBox(height: 14),
        VardiyaSectionCard(
          title: 'Notlar',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final n in kHarcirahNotlar)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: PoliceColors.gold)),
                      Expanded(
                        child: Text(
                          n,
                          style: TextStyle(
                            color: PoliceColors.mevzuatBodyText
                                .withValues(alpha: 0.9),
                            height: 1.4,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKanunTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        VardiyaSectionCard(
          title: kHarcirahKanunuBaslik,
          child: Text(
            kHarcirahKanunuMetin,
            style: TextStyle(
              color: PoliceColors.mevzuatBodyText.withValues(alpha: 0.92),
              height: 1.48,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.8)),
        filled: true,
        fillColor: PoliceColors.surfaceDarkElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: PoliceColors.outlineMuted.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: PoliceColors.outlineMuted.withValues(alpha: 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: PoliceColors.primaryBlue, width: 1.5),
        ),
      );
}

class _IlDropdown extends StatelessWidget {
  const _IlDropdown({
    required this.label,
    required this.value,
    required this.iller,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> iller;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: PoliceColors.surfaceDarkElevated,
      style: const TextStyle(color: PoliceColors.titleOnDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: PoliceColors.textMuted),
        filled: true,
        fillColor: PoliceColors.surfaceDarkElevated,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      hint: const Text('Seçiniz', style: TextStyle(color: PoliceColors.textMuted)),
      items: iller
          .map((il) => DropdownMenuItem(value: il, child: Text(il)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _DurumSwitch extends StatelessWidget {
  const _DurumSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: enabled
                    ? PoliceColors.titleOnDark
                    : PoliceColors.textMuted.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: PoliceColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}

class _RaporKarti extends StatelessWidget {
  const _RaporKarti({required this.baslik, required this.sonuc});

  final String baslik;
  final HarcirahSonuc sonuc;

  @override
  Widget build(BuildContext context) {
    return VardiyaSectionCard(
      title: baslik,
      subtitle:
          'Günlük gün: ${sonuc.gunSayisi} · Çocuk gün: ${sonuc.cocukGunSayisi}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TabloBaslik(),
          const Divider(height: 1, color: PoliceColors.outlineMuted),
          for (final s in sonuc.satirlar) _TabloSatir(satir: s),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'TOPLAM ÜCRET',
                style: TextStyle(
                  color: PoliceColors.gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${_tlFormat.format(sonuc.toplam)} TL',
                style: TextStyle(
                  color: PoliceColors.gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabloBaslik extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      color: PoliceColors.textMuted,
    );
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('AÇIKLAMA', style: style)),
          Expanded(child: Text('DEĞER', style: style, textAlign: TextAlign.end)),
          Expanded(child: Text('KAT', style: style, textAlign: TextAlign.end)),
          Expanded(child: Text('KM', style: style, textAlign: TextAlign.end)),
          Expanded(child: Text('SONUÇ', style: style, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _TabloSatir extends StatelessWidget {
  const _TabloSatir({required this.satir});

  final HarcirahSatir satir;

  @override
  Widget build(BuildContext context) {
    const small = TextStyle(
      fontSize: 11,
      color: PoliceColors.titleOnDark,
      height: 1.25,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(satir.aciklama, style: small),
          ),
          Expanded(
            child: Text(
              _tlFormat.format(satir.deger),
              style: small,
              textAlign: TextAlign.end,
            ),
          ),
          Expanded(
            child: Text(
              satir.katSayisi != null ? '${satir.katSayisi}' : '—',
              style: small,
              textAlign: TextAlign.end,
            ),
          ),
          Expanded(
            child: Text(
              satir.mesafeKm?.toString() ?? '—',
              style: small,
              textAlign: TextAlign.end,
            ),
          ),
          Expanded(
            child: Text(
              _tlFormat.format(satir.sonuc),
              style: small.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
