import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../common/theme/police_colors.dart';
import 'gider_editor_page.dart';
import 'gider_models.dart';
import 'gider_store.dart';

/// O-1 giderleri: görevle ilgili harcamalar ve fişleri (yalnızca cihazda).
class O1GiderPage extends StatefulWidget {
  const O1GiderPage({super.key});

  @override
  State<O1GiderPage> createState() => _O1GiderPageState();
}

class _O1GiderPageState extends State<O1GiderPage> {
  List<GiderKayit> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await giderLoadAll();
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _openEditor([GiderKayit? existing]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => GiderEditorPage(existing: existing),
      ),
    );
    if (changed == true) await _load();
  }

  double get _toplam => _items.fold(0, (sum, e) => sum + e.tutar);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('O-1 giderleri'),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        backgroundColor: PoliceColors.primaryBlue,
        foregroundColor: PoliceColors.titleOnDark,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Gider ekle'),
      ),
      body: _loading
          ? const Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  color: PoliceColors.primaryBlue,
                  strokeWidth: 2,
                ),
              ),
            )
          : _items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      'Henüz gider yok.\n\nSağ alttan yeni gider ekleyip '
                      'kamera ile fiş çekebilirsin. Kayıtlar yalnızca bu '
                      'cihazda saklanır.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.95),
                        height: 1.5,
                      ),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  children: [
                    _toplamCard(),
                    const SizedBox(height: 12),
                    for (final e in _items) _tile(e),
                  ],
                ),
    );
  }

  Widget _toplamCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: PoliceColors.primaryBlue.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const PhosphorIcon(PhosphorIconsRegular.wallet,
              color: PoliceColors.primaryBlue, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toplam gider · ${_items.length} kayıt',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.95),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmtTutar(_toplam)} TL',
                  style: const TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(GiderKayit e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openEditor(e),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (e.fisPaths.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(e.fisPaths.first),
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fisPlaceholder(),
                    ),
                  )
                else
                  _fisPlaceholder(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.baslik.trim().isEmpty ? '(Açıklamasız)' : e.baslik,
                        style: const TextStyle(
                          color: PoliceColors.titleOnDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _fmtDate(e.tarihMs),
                            style: TextStyle(
                              color:
                                  PoliceColors.textMuted.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                          if (e.kategori.trim().isNotEmpty) ...[
                            const SizedBox(width: 8),
                            _chip(e.kategori.trim()),
                          ],
                          if (e.fisPaths.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                const PhosphorIcon(
                                  PhosphorIconsRegular.paperclip,
                                  color: PoliceColors.textMuted,
                                  size: 13,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${e.fisPaths.length}',
                                  style: TextStyle(
                                    color: PoliceColors.textMuted
                                        .withValues(alpha: 0.85),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      if (e.not.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          e.not.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: PoliceColors.textMuted.withValues(alpha: 0.8),
                            fontSize: 12.5,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  e.tutar > 0 ? '${_fmtTutar(e.tutar)} TL' : '—',
                  style: const TextStyle(
                    color: PoliceColors.gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fisPlaceholder() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: PoliceColors.backgroundDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const PhosphorIcon(
        PhosphorIconsRegular.receipt,
        color: PoliceColors.textMuted,
        size: 22,
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: PoliceColors.primaryBlue.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: PoliceColors.titleOnDark,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static String _fmtTutar(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
      buf.write(intPart[i]);
    }
    return '$buf,${parts[1]}';
  }

  static String _fmtDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }
}
