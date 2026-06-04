import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import 'saglik_mevzuat_nav.dart';
import 'saglik_rehber_detay_page.dart';
import 'saglik_rehberi_data.dart';

/// Sağlık asistanı — senaryo eşleştirme; teşhis koymaz, mevzuata yönlendirir.
class SaglikAsistaniPage extends StatefulWidget {
  const SaglikAsistaniPage({super.key});

  @override
  State<SaglikAsistaniPage> createState() => _SaglikAsistaniPageState();
}

class _SaglikAsistaniPageState extends State<SaglikAsistaniPage> {
  final _ctrl = TextEditingController();
  List<SaglikSenaryo> _hits = [];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    setState(() => _hits = saglikSenaryoEslestir(v));
  }

  Future<void> _openRef(SaglikMevzuatRef ref) async {
    await openSaglikMevzuatRef(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Sağlık Asistanı'),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PoliceColors.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: PoliceColors.gold.withValues(alpha: 0.28),
              ),
            ),
            child: const Text(
              'Hastalığınızı teşhis etmez; “İlgili mevzuata göre…” '
              'ifadesiyle süreç ve hak yönlendirmesi sunar. Bağlayıcı '
              'tıbbi veya hukuki tavsiye değildir.',
              style: TextStyle(
                color: PoliceColors.titleOnDark,
                fontSize: 12.5,
                height: 1.42,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            onChanged: _onChanged,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: InputDecoration(
              hintText: 'Örn: Bel fıtığı ameliyatı oldum, durumum ne?',
              hintStyle: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.55),
              ),
              filled: true,
              fillColor: PoliceColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const PhosphorIcon(
                PhosphorIconsRegular.magnifyingGlass,
                color: PoliceColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Örnek sorular',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in kSaglikSenaryolari)
                ActionChip(
                  label: Text(s.baslik, style: const TextStyle(fontSize: 11.5)),
                  backgroundColor: PoliceColors.surfaceDark,
                  side: BorderSide(
                    color: PoliceColors.saglikAccent.withValues(alpha: 0.35),
                  ),
                  onPressed: () {
                    _ctrl.text = s.baslik;
                    _onChanged(s.baslik);
                  },
                ),
            ],
          ),
          if (_hits.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final s in _hits) _SenaryoCard(senaryo: s, onOpenRef: _openRef),
          ] else if (_ctrl.text.trim().length >= 3) ...[
            const SizedBox(height: 16),
            Text(
              'Eşleşen senaryo bulunamadı. Sağlık Rehberi konularına '
              'bakın veya Mevzuat sekmesinden 657 DMK m. 105’i açın.',
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.85),
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SenaryoCard extends StatelessWidget {
  const _SenaryoCard({required this.senaryo, required this.onOpenRef});

  final SaglikSenaryo senaryo;
  final Future<void> Function(SaglikMevzuatRef ref) onOpenRef;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.saglikAccent.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            senaryo.baslik,
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            senaryo.ozet,
            style: const TextStyle(
              color: PoliceColors.mevzuatBodyText,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Uygulamada',
            style: TextStyle(
              color: PoliceColors.saglikAccent.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            senaryo.uygulamada,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.92),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          for (final n in senaryo.mevzuatNotlari)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• $n',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.88),
                  fontSize: 12.5,
                ),
              ),
            ),
          if (senaryo.mevzuatRefs.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final ref in senaryo.mevzuatRefs)
                  TextButton(
                    onPressed: () => onOpenRef(ref),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      ref.label,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
          if (senaryo.ilgiliKonu != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).push(
                  fadeRoute(
                    SaglikRehberDetayPage(konu: senaryo.ilgiliKonu!),
                  ),
                );
              },
              icon: const PhosphorIcon(
                PhosphorIconsRegular.bookOpenText,
                size: 18,
              ),
              label: const Text('Detaylı rehberi aç'),
            ),
          ],
        ],
      ),
    );
  }
}
