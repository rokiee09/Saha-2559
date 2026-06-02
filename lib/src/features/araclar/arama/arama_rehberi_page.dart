import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../common/routing/transitions.dart';
import '../../../common/theme/police_colors.dart';
import '../../mevzuat/mevzuat_article_detail_page.dart';
import 'arama_rehberi_data.dart';
import 'arama_tur_detay_page.dart';

/// Arama işlemleri rehberi: tür seçimi, checklist, mevzuat, senaryo.
class AramaRehberiPage extends StatefulWidget {
  const AramaRehberiPage({super.key});

  @override
  State<AramaRehberiPage> createState() => _AramaRehberiPageState();
}

class _AramaRehberiPageState extends State<AramaRehberiPage> {
  final _senaryoCtrl = TextEditingController();
  List<AramaSenaryo> _senaryolar = [];

  @override
  void dispose() {
    _senaryoCtrl.dispose();
    super.dispose();
  }

  void _onSenaryoChanged(String v) {
    setState(() => _senaryolar = aramaSenaryoEslestir(v));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Arama Rehberi'),
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
              color: PoliceColors.primaryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: PoliceColors.primaryBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'Mahkeme kararı saklama alanı değil; sahada hızlı kontrol '
              'rehberidir. Resmî işlem öncesi mevzuat ve talimat esastır.',
              style: TextStyle(
                color: PoliceColors.titleOnDark.withValues(alpha: 0.9),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionLabel('Hızlı kontrol — arama türü seç'),
          const SizedBox(height: 8),
          for (final tur in AramaTuru.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: PoliceColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(
                      fadeRoute(AramaTurDetayPage(tur: tur)),
                    );
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
                            color: PoliceColors.gold.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: PhosphorIcon(
                            tur.icon,
                            color: PoliceColors.gold,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            tur.title,
                            style: const TextStyle(
                              color: PoliceColors.titleOnDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5,
                            ),
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
          const SizedBox(height: 8),
          const _SectionLabel('İlgili maddeler'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final ref in kAramaMevzuatRefs)
                ActionChip(
                  label: Text(ref.label),
                  labelStyle: const TextStyle(fontSize: 12),
                  backgroundColor: PoliceColors.surfaceDark,
                  side: BorderSide(
                    color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
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
          const SizedBox(height: 18),
          const _SectionLabel('Senaryo asistanı'),
          const SizedBox(height: 8),
          TextField(
            controller: _senaryoCtrl,
            onChanged: _onSenaryoChanged,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: InputDecoration(
              hintText: 'Örn: Araçta uyuşturucu şüphesi var',
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
          if (_senaryolar.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final s in _senaryolar) _SenaryoCard(senaryo: s),
          ] else if (_senaryoCtrl.text.trim().length >= 3) ...[
            const SizedBox(height: 12),
            Text(
              'Eşleşen senaryo bulunamadı. Çalışma Asistanı veya Mevzuat '
              'sekmesinden detaylı arama yapabilirsiniz.',
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: PoliceColors.titleOnDark,
        fontWeight: FontWeight.w800,
        fontSize: 14.5,
      ),
    );
  }
}

class _SenaryoCard extends StatelessWidget {
  const _SenaryoCard({required this.senaryo});

  final AramaSenaryo senaryo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            senaryo.baslik,
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w700,
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
            'İlgili mevzuat / işlem:',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          for (final n in senaryo.mevzuatNotlari)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '• $n',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.85),
                  fontSize: 12.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
