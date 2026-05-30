import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../common/routing/transitions.dart';
import '../../../common/theme/police_colors.dart';
import 'tutanak_form_page.dart';
import 'tutanak_templates.dart';

/// Tutanak asistanı: hazır şablonlardan yapılandırılmış taslak üretir.
class TutanakPage extends StatelessWidget {
  const TutanakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Tutanak Asistanı'),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
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
            child: Row(
              children: [
                const PhosphorIcon(
                  PhosphorIconsRegular.info,
                  color: PoliceColors.primaryBlue,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Şablonu doldur, taslak metin otomatik oluşsun. '
                    'Üretilen metin resmî form değildir; kontrol edip '
                    'düzenlemelisin. Saha defterine kaydedebilir veya kopyalayabilirsin.',
                    style: TextStyle(
                      color: PoliceColors.titleOnDark.withValues(alpha: 0.9),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final t in TutanakTemplate.all)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: PoliceColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(
                      fadeRoute(TutanakFormPage(templateId: t.id)),
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
                            color:
                                PoliceColors.primaryBlue.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: PhosphorIcon(
                            t.icon,
                            color: PoliceColors.primaryBlue,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: const TextStyle(
                                  color: PoliceColors.titleOnDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                t.description,
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
