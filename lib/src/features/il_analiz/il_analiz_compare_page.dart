import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/theme/police_colors.dart';
import 'il_analiz_data.dart';
import 'il_analiz_display.dart';
import 'il_analiz_models.dart';

class IlAnalizComparePage extends ConsumerStatefulWidget {
  const IlAnalizComparePage({
    super.key,
    this.initialLeft,
    this.initialRight,
  });

  final String? initialLeft;
  final String? initialRight;

  @override
  ConsumerState<IlAnalizComparePage> createState() => _IlAnalizComparePageState();
}

class _IlAnalizComparePageState extends ConsumerState<IlAnalizComparePage> {
  String? _leftId;
  String? _rightId;

  @override
  void initState() {
    super.initState();
    _leftId = widget.initialLeft;
    _rightId = widget.initialRight ?? 'mugla';
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(ilAnalizKatalogProvider);
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('İl karşılaştırma'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (k) {
          final hazir = k.hazirProfiller();
          final left = _leftId != null ? k.profil(_leftId!) : null;
          final right = _rightId != null ? k.profil(_rightId!) : null;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _IlPicker(
                      label: 'İl 1',
                      value: _leftId,
                      options: hazir,
                      onChanged: (v) => setState(() => _leftId = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _IlPicker(
                      label: 'İl 2',
                      value: _rightId,
                      options: hazir,
                      onChanged: (v) => setState(() => _rightId = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (left == null || right == null)
                Text(
                  'Karşılaştırma için iki profilli il seçin.',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.9),
                  ),
                )
              else
                ..._compareRows(left, right),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _compareRows(IlAnalizProfil a, IlAnalizProfil b) {
    return [
      _CompareHeader(a: a.ad, b: b.ad),
      _CompareRow(
        label: 'Nüfus',
        a: formatNufus(a.genel.nufus),
        b: formatNufus(b.genel.nufus),
      ),
      _CompareRow(
        label: 'Ortalama kira',
        a: formatTl(a.ekonomi.ortalamaKiraTl),
        b: formatTl(b.ekonomi.ortalamaKiraTl),
      ),
      _CompareRow(
        label: 'Görev puanı',
        a: formatIlGorevPuaniVeyaDash(a.polis.gorevPuani),
        b: formatIlGorevPuaniVeyaDash(b.polis.gorevPuani),
      ),
      _CompareRow(
        label: 'Yaşam endeksi',
        a: formatIlYasamIndeksiSira(a.genel.yasamIndeksiSira, yil: a.genel.yasamIndeksiYil).isEmpty
            ? '—'
            : formatIlYasamIndeksiSira(a.genel.yasamIndeksiSira, yil: a.genel.yasamIndeksiYil),
        b: formatIlYasamIndeksiSira(b.genel.yasamIndeksiSira, yil: b.genel.yasamIndeksiYil).isEmpty
            ? '—'
            : formatIlYasamIndeksiSira(b.genel.yasamIndeksiSira, yil: b.genel.yasamIndeksiYil),
      ),
      _CompareRow(
        label: 'Tazminat derecesi',
        a: formatIlTazminatDerece(a.polis.tazminatDerece).isEmpty
            ? '—'
            : formatIlTazminatDerece(a.polis.tazminatDerece),
        b: formatIlTazminatDerece(b.polis.tazminatDerece).isEmpty
            ? '—'
            : formatIlTazminatDerece(b.polis.tazminatDerece),
      ),
      _CompareRow(
        label: 'Ek ödeme',
        a: formatIlTl(a.polis.ekTazminatTl).isEmpty ? '—' : formatIlTl(a.polis.ekTazminatTl),
        b: formatIlTl(b.polis.ekTazminatTl).isEmpty ? '—' : formatIlTl(b.polis.ekTazminatTl),
      ),
      _CompareRow(
        label: 'Lojman',
        a: a.polis.lojmanDurumu ?? '—',
        b: b.polis.lojmanDurumu ?? '—',
      ),
      _CompareRow(
        label: 'Devlet hastane',
        a: '${a.saglik.devletHastanesi ?? "—"}',
        b: '${b.saglik.devletHastanesi ?? "—"}',
      ),
      _CompareRow(
        label: 'Üniversite',
        a: '${a.egitim.universite ?? "—"}',
        b: '${b.egitim.universite ?? "—"}',
      ),
      _CompareRow(
        label: 'AVM',
        a: '${a.sosyal.avm ?? "—"}',
        b: '${b.sosyal.avm ?? "—"}',
      ),
      _CompareRow(
        label: 'Polis yaşam puanı',
        a: '${a.puanlar.polisYasam}',
        b: '${b.puanlar.polisYasam}',
        highlightHigher: true,
      ),
      _CompareRow(
        label: 'Aile uygunluk',
        a: '${a.puanlar.aile}',
        b: '${b.puanlar.aile}',
        highlightHigher: true,
      ),
      _CompareRow(
        label: 'İş yükü (özet)',
        a: a.polis.isYuku ?? '—',
        b: b.polis.isYuku ?? '—',
      ),
    ];
  }
}

class _IlPicker extends StatelessWidget {
  const _IlPicker({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<IlAnalizOzet> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: PoliceColors.surfaceDark,
      style: const TextStyle(color: PoliceColors.titleOnDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
        filled: true,
        fillColor: PoliceColors.surfaceDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: [
        for (final o in options)
          DropdownMenuItem(value: o.id, child: Text(o.ad)),
      ],
      onChanged: onChanged,
    );
  }
}

class _CompareHeader extends StatelessWidget {
  const _CompareHeader({required this.a, required this.b});

  final String a;
  final String b;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Expanded(flex: 2, child: SizedBox()),
          Expanded(
            child: Text(
              a,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PoliceColors.primaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              b,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PoliceColors.gold.withValues(alpha: 0.95),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.a,
    required this.b,
    this.highlightHigher = false,
  });

  final String label;
  final String a;
  final String b;
  final bool highlightHigher;

  @override
  Widget build(BuildContext context) {
    Color? ca;
    Color? cb;
    if (highlightHigher) {
      final na = int.tryParse(a);
      final nb = int.tryParse(b);
      if (na != null && nb != null) {
        if (na > nb) ca = PoliceColors.primaryBlue;
        if (nb > na) cb = PoliceColors.gold;
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.9),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              a,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ca ?? PoliceColors.titleOnDark,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              b,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cb ?? PoliceColors.titleOnDark,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
