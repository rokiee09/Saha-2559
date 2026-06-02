import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../common/theme/police_colors.dart';
import 'atis_editor_page.dart';
import 'atis_models.dart';
import 'atis_store.dart';

/// Atış takibi: 4 dönem, puanlar, izin kullanımı.
class AtisTakipPage extends StatefulWidget {
  const AtisTakipPage({super.key});

  @override
  State<AtisTakipPage> createState() => _AtisTakipPageState();
}

class _AtisTakipPageState extends State<AtisTakipPage> {
  List<AtisKayit> _kayitlar = [];
  int _yil = DateTime.now().year;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await atisLoadAll();
    if (!mounted) return;
    setState(() {
      _kayitlar = list;
      _loading = false;
    });
  }

  Future<void> _openEditor({AtisKayit? existing, int? donem}) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AtisEditorPage(
          existing: existing,
          initialDonem: donem,
          initialYil: _yil,
        ),
      ),
    );
    if (ok == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final donemler = atisDonemOzetleri(_kayitlar, yil: _yil);
    final tamamlanan = atisTamamlananDonemSayisi(_kayitlar, yil: _yil);
    final yilPuanlar = _kayitlar
        .where((k) => k.yil == _yil)
        .map((k) => k.puan)
        .toList();
    final ortPuan = yilPuanlar.isEmpty
        ? null
        : yilPuanlar.reduce((a, b) => a + b) / yilPuanlar.length;

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Atış Takibim'),
        actions: [
          IconButton(
            tooltip: 'Önceki yıl',
            onPressed: () => setState(() => _yil--),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text(
            '$_yil',
            style: const TextStyle(
              color: PoliceColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            tooltip: 'Sonraki yıl',
            onPressed: () => setState(() => _yil++),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          int? bekleyenDonem;
          for (final d in donemler) {
            if (d.durum == AtisDonemDurum.bekliyor) {
              bekleyenDonem = d.donem;
              break;
            }
          }
          _openEditor(donem: bekleyenDonem ?? 1);
        },
        backgroundColor: PoliceColors.primaryBlue,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Atış kaydı'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
              children: [
                _statBanner(
                  tamamlanan: tamamlanan,
                  ortPuan: ortPuan,
                  puanlar: yilPuanlar,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dönem durumu',
                  style: TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                for (final d in donemler) _donemTile(d),
                const SizedBox(height: 16),
                const Text(
                  'Puanlarım',
                  style: TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                if (yilPuanlar.isEmpty)
                  Text(
                    'Bu yıl için henüz atış kaydı yok.',
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.85),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final k in _kayitlar.where((e) => e.yil == _yil))
                        Chip(
                          label: Text(
                            '${k.donem}. dönem: ${k.puan}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          backgroundColor:
                              PoliceColors.primaryBlue.withValues(alpha: 0.15),
                        ),
                    ],
                  ),
                const SizedBox(height: 12),
                Text(
                  'Kayıtlar yalnızca bu cihazda tutulur.',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.75),
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _statBanner({
    required int tamamlanan,
    required double? ortPuan,
    required List<double> puanlar,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PoliceColors.gold.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tamamlanan dönem',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$tamamlanan / 4',
                  style: const TextStyle(
                    color: PoliceColors.gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          if (ortPuan != null) ...[
            Container(width: 1, height: 40, color: PoliceColors.outlineMuted),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ortalama puan',
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    ortPuan.toStringAsFixed(1).replaceAll('.', ','),
                    style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _donemTile(AtisDonemOzet d) {
    final tamam = d.durum == AtisDonemDurum.tamamlandi;
    final emoji = tamam ? '🟢' : '🔴';
    final durumMetin = tamam
        ? '${d.donem}. Dönem Tamamlandı'
        : '${d.donem}. Dönem Bekliyor';
    final kayit = d.kayit;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _openEditor(
            existing: kayit,
            donem: d.donem,
          ),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: tamam
                    ? const Color(0xFF4ADE80).withValues(alpha: 0.35)
                    : Colors.redAccent.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        durumMetin,
                        style: const TextStyle(
                          color: PoliceColors.titleOnDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                      if (kayit != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Puan: ${kayit.puan} · '
                          '${kayit.tarih.day}.${kayit.tarih.month}.${kayit.tarih.year}'
                          '${kayit.izinKullanildi ? ' · İzin kullanıldı' : ''}',
                          style: TextStyle(
                            color: PoliceColors.textMuted.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const PhosphorIcon(
                  PhosphorIconsRegular.caretRight,
                  color: PoliceColors.textMuted,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
