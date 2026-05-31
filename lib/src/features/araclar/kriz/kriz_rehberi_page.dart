import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../common/routing/transitions.dart';
import '../../../common/theme/police_colors.dart';
import 'kriz_rehberi_data.dart';

/// Kriz rehberi: senaryo listesi → adım adım kontrol listesi.
class KrizRehberiPage extends StatelessWidget {
  const KrizRehberiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Kriz Rehberi'),
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
              color: Colors.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFFF8A80), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bu kontrol listeleri hızlı hatırlatma içindir. Önce can '
                    'güvenliği. Resmî protokol, birim talimatı ve mevzuat esastır.',
                    style: TextStyle(
                      color: Colors.red.shade100,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final s in kKrizSenaryolari)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: PoliceColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context)
                        .push(fadeRoute(KrizDetayPage(senaryo: s)));
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: PhosphorIcon(
                            s.icon,
                            color: const Color(0xFFFF8A80),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.title,
                                style: const TextStyle(
                                  color: PoliceColors.titleOnDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${s.adimlar.length} adımlık kontrol listesi',
                                style: TextStyle(
                                  color: PoliceColors.textMuted
                                      .withValues(alpha: 0.9),
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PhosphorIcon(
                          PhosphorIconsRegular.caretRight,
                          color: PoliceColors.textMuted,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class KrizDetayPage extends StatefulWidget {
  const KrizDetayPage({super.key, required this.senaryo});

  final KrizSenaryo senaryo;

  @override
  State<KrizDetayPage> createState() => _KrizDetayPageState();
}

class _KrizDetayPageState extends State<KrizDetayPage> {
  late final List<bool> _checked;

  @override
  void initState() {
    super.initState();
    _checked = List<bool>.filled(widget.senaryo.adimlar.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.senaryo;
    final done = _checked.where((e) => e).length;
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: Text(s.title),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
        actions: [
          if (done > 0)
            TextButton(
              onPressed: () => setState(() {
                for (var i = 0; i < _checked.length; i++) {
                  _checked[i] = false;
                }
              }),
              child: const Text('Sıfırla',
                  style: TextStyle(color: PoliceColors.primaryBlue)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          Text(
            s.ozet,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.95),
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: _checked.isEmpty ? 0 : done / _checked.length,
            backgroundColor: PoliceColors.surfaceDark,
            color: PoliceColors.primaryBlue,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 6),
          Text(
            '$done / ${_checked.length} adım',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < s.adimlar.length; i++)
            _StepTile(
              index: i + 1,
              text: s.adimlar[i],
              checked: _checked[i],
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _checked[i] = v);
              },
            ),
          if (s.yapma.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Block(
              title: 'Yapma',
              color: const Color(0xFFE53935),
              icon: Icons.block_rounded,
              items: s.yapma,
            ),
          ],
          if (s.numaralar.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Block(
              title: 'İlgili hatlar',
              color: PoliceColors.primaryBlue,
              icon: Icons.phone_in_talk_rounded,
              items: s.numaralar,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.index,
    required this.text,
    required this.checked,
    required this.onChanged,
  });

  final int index;
  final String text;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onChanged(!checked),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        checked ? PoliceColors.primaryBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: checked
                          ? PoliceColors.primaryBlue
                          : PoliceColors.textMuted.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: checked
                      ? const Icon(Icons.check_rounded,
                          size: 16, color: Colors.white)
                      : Text(
                          '$index',
                          style: const TextStyle(
                            color: PoliceColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: checked
                          ? PoliceColors.textMuted.withValues(alpha: 0.7)
                          : PoliceColors.titleOnDark,
                      fontSize: 13.8,
                      height: 1.4,
                      decoration: checked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.title,
    required this.color,
    required this.icon,
    required this.items,
  });

  final String title;
  final Color color;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ',
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.w700)),
                  Expanded(
                    child: Text(
                      it,
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontSize: 13,
                        height: 1.4,
                      ),
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
