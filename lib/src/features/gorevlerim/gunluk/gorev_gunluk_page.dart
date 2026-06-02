import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../common/theme/police_colors.dart';
import 'gorev_gunluk_calendar.dart';
import 'gorev_gunluk_editor_page.dart';
import 'gorev_gunluk_models.dart';
import 'gorev_gunluk_stats.dart';
import 'gorev_gunluk_store.dart';

/// Görev günlüğü: kayıt, takvim, aylık/yıllık istatistik.
class GorevGunlukPage extends StatefulWidget {
  const GorevGunlukPage({super.key});

  @override
  State<GorevGunlukPage> createState() => _GorevGunlukPageState();
}

class _GorevGunlukPageState extends State<GorevGunlukPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<GorevGunlukKayit> _kayitlar = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final list = await gorevGunlukLoadAll();
    if (!mounted) return;
    setState(() {
      _kayitlar = list;
      _loading = false;
    });
  }

  Future<void> _openEditor([GorevGunlukKayit? existing]) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => GorevGunlukEditorPage(existing: existing),
      ),
    );
    if (ok == true) await _load();
  }

  Future<void> _delete(GorevGunlukKayit k) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PoliceColors.surfaceDark,
        title: const Text('Sil', style: TextStyle(color: PoliceColors.titleOnDark)),
        content: const Text(
          'Bu görev kaydı silinsin mi?',
          style: TextStyle(color: PoliceColors.mevzuatBodyText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await gorevGunlukDelete(k.id);
    await _load();
  }

  void _showDaySheet(DateTime day, List<GorevGunlukKayit> items) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: PoliceColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${day.day} ${kAyAdlari[day.month]} ${day.year}',
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 12),
              for (final k in items) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    k.gorevAdi,
                    style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${k.saat} · ${formatSaat(k.sureSaat)} saat',
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.85),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openEditor(k);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ay = ayIstatistik(_kayitlar);
    final yil = yilIstatistik(_kayitlar);

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Görev Günlüğüm'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: PoliceColors.gold,
          labelColor: PoliceColors.gold,
          unselectedLabelColor: PoliceColors.textMuted,
          tabs: const [
            Tab(text: 'Liste'),
            Tab(text: 'Takvim'),
            Tab(text: 'İstatistik'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          _openEditor();
        },
        backgroundColor: PoliceColors.primaryBlue,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Görev ekle'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
            )
          : TabBarView(
              controller: _tabs,
              children: [
                _listeTab(),
                _takvimTab(),
                _istatistikTab(ay, yil),
              ],
            ),
    );
  }

  Widget _listeTab() {
    if (_kayitlar.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            'Henüz görev kaydı yok.\n\nVali Koruma, Mahkeme, Nokta gibi '
            'görev adını serbest yaz; takvimde ay ay gör.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.95),
              height: 1.5,
            ),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: _kayitlar.length,
      itemBuilder: (_, i) => _kayitTile(_kayitlar[i]),
    );
  }

  Widget _takvimTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PoliceColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
            ),
          ),
          child: GorevGunlukCalendar(
            kayitlar: _kayitlar,
            onDayTap: _showDaySheet,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Mavi günlerde görev var. Güne dokunarak o günün kayıtlarını gör.',
          style: TextStyle(
            color: PoliceColors.textMuted.withValues(alpha: 0.85),
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _istatistikTab(GorevGunlukAyIstatistik ay, GorevGunlukYilIstatistik yil) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
      children: [
        _statCard(
          title: 'Bu Ay',
          rows: [
            _StatRow('Toplam Görev', '${ay.toplamGorev}'),
            _StatRow('Toplam Saat', formatSaat(ay.toplamSaat)),
            if (ay.enYogunGunLabel != null)
              _StatRow('En Yoğun Gün', ay.enYogunGunLabel!),
          ],
        ),
        const SizedBox(height: 12),
        _statCard(
          title: 'Bu Yıl (${yil.yil})',
          rows: [
            _StatRow('Toplam Görev', '${yil.toplamGorev}'),
            _StatRow('Toplam Görev Süresi', '${formatSaat(yil.toplamSaat)} saat'),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'İstatistikler görev türüne göre değil; tüm kayıtların toplamıdır. '
          'Veriler yalnızca bu cihazda tutulur.',
          style: TextStyle(
            color: PoliceColors.textMuted.withValues(alpha: 0.8),
            fontSize: 11.5,
            height: 1.4,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _statCard({required String title, required List<Widget> rows}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: PoliceColors.gold,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _kayitTile(GorevGunlukKayit k) {
    final tarih =
        '${k.tarih.day.toString().padLeft(2, '0')}.${k.tarih.month.toString().padLeft(2, '0')}.${k.tarih.year}';
    final konum = [k.il, k.ilce].where((e) => e.isNotEmpty).join(' / ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _openEditor(k),
          onLongPress: () => _delete(k),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (k.fotoPaths.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(k.fotoPaths.first),
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        k.gorevAdi,
                        style: const TextStyle(
                          color: PoliceColors.titleOnDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$tarih · ${k.saat} · ${formatSaat(k.sureSaat)} saat',
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.9),
                          fontSize: 12.5,
                        ),
                      ),
                      if (konum.isNotEmpty)
                        Text(
                          konum,
                          style: TextStyle(
                            color: PoliceColors.textMuted.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                      if (k.not.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          k.not,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: PoliceColors.mevzuatBodyText
                                .withValues(alpha: 0.85),
                            fontSize: 12.5,
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

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.9),
                fontSize: 13.5,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
