import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../common/routing/transitions.dart';
import '../../../common/theme/police_colors.dart';
import '../../mevzuat/mevzuat_article_detail_page.dart';
import 'arama_rehberi_data.dart';

/// Seçilen arama türü: hukuki özet + interaktif checklist.
class AramaTurDetayPage extends StatefulWidget {
  const AramaTurDetayPage({super.key, required this.tur});

  final AramaTuru tur;

  @override
  State<AramaTurDetayPage> createState() => _AramaTurDetayPageState();
}

class _AramaTurDetayPageState extends State<AramaTurDetayPage> {
  late final List<bool> _checked;

  @override
  void initState() {
    super.initState();
    _checked = List.filled(checklistFor(widget.tur).length, false);
  }

  @override
  Widget build(BuildContext context) {
    final ozet = hukukiOzet(widget.tur);
    final items = checklistFor(widget.tur);
    final done = _checked.where((c) => c).length;

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: Text(widget.tur.title),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          _InfoBlock(
            title: 'Hızlı hukuki çerçeve',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ozet.aciklama,
                  style: const TextStyle(
                    color: PoliceColors.mevzuatBodyText,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                _QuickRow(
                  icon: PhosphorIconsRegular.scales,
                  label: 'Hâkim kararı',
                  value: ozet.hakimKarari,
                ),
                _QuickRow(
                  icon: PhosphorIconsRegular.userGear,
                  label: 'Savcı talimatı',
                  value: ozet.savciTalimati,
                ),
                _QuickRow(
                  icon: PhosphorIconsRegular.bookOpen,
                  label: 'CMK',
                  value: ozet.cmk,
                ),
                _QuickRow(
                  icon: PhosphorIconsRegular.shield,
                  label: 'PVSK',
                  value: ozet.pvsk,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Kontrol listesi',
                style: TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                '$done / ${items.length}',
                style: TextStyle(
                  color: PoliceColors.gold.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < items.length; i++)
            CheckboxListTile(
              value: _checked[i],
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _checked[i] = v ?? false);
              },
              title: Text(
                items[i],
                style: TextStyle(
                  color: _checked[i]
                      ? PoliceColors.textMuted.withValues(alpha: 0.75)
                      : PoliceColors.titleOnDark,
                  fontSize: 14,
                  decoration:
                      _checked[i] ? TextDecoration.lineThrough : null,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: PoliceColors.primaryBlue,
              checkColor: Colors.white,
              tileColor: PoliceColors.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          const SizedBox(height: 14),
          const Text(
            'Mevzuat',
            style: TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final ref in kAramaMevzuatRefs)
                ActionChip(
                  label: Text(ref.label, style: const TextStyle(fontSize: 12)),
                  backgroundColor: PoliceColors.surfaceDark,
                  side: BorderSide(
                    color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      fadeRoute(
                        MevzuatArticleDetailPage(
                          entryId: ref.entryId,
                          focusSectionId: ref.sectionId,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _QuickRow extends StatelessWidget {
  const _QuickRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhosphorIcon(icon, color: PoliceColors.primaryBlue, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: PoliceColors.gold.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.9),
                    fontSize: 12.5,
                    height: 1.35,
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
