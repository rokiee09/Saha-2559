import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import '../../common/widgets/module_section_header.dart';
import '../../common/widgets/police_module_icon.dart';
import '../../common/widgets/police_module_list_tile.dart';
import 'saglik_asistani_page.dart';
import 'saglik_mevzuat_nav.dart';
import 'saglik_rehber_detay_page.dart';
import 'saglik_rehberi_data.dart';

/// Sağlık ve sosyal haklar — kariyer ve mevzuat sekmesinden bağımsız hub.
class SaglikSosyalHaklarPage extends StatelessWidget {
  const SaglikSosyalHaklarPage({super.key});

  Future<void> _openRef(BuildContext context, SaglikMevzuatRef ref) async {
    await openSaglikMevzuatRef(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Sağlık ve Sosyal Haklar'),
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
              color: PoliceColors.saglikAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: PoliceColors.saglikAccent.withValues(alpha: 0.32),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PoliceModuleIconBadge(
                  style: PoliceModules.saglik,
                  size: 22,
                  padding: 8,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Rapor, heyet, göreve elverişlilik ve maluliyet süreçlerini '
                    'günlük dilde özetler. Teşhis koymaz; ilgili mevzuata '
                    'yönlendirir.',
                    style: TextStyle(
                      color: PoliceColors.titleOnDark.withValues(alpha: 0.92),
                      fontSize: 13,
                      height: 1.42,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const ModuleSectionHeader('Mevzuat', subtitle: 'Kanun ve yönetmelikler'),
          for (final ref in kSaglikMevzuatRefs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: PoliceColors.surfaceDark,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => _openRef(context, ref),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: PoliceColors.outlineMuted.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      children: [
                        PhosphorIcon(
                          ref.isInApp
                              ? PhosphorIconsRegular.bookOpen
                              : PhosphorIconsRegular.arrowSquareOut,
                          color: PoliceColors.saglikAccent,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ref.label,
                                style: const TextStyle(
                                  color: PoliceColors.titleOnDark,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              if (ref.notInAppNote != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  ref.notInAppNote!,
                                  style: TextStyle(
                                    color: PoliceColors.textMuted
                                        .withValues(alpha: 0.85),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        PhosphorIcon(
                          PhosphorIconsRegular.caretRight,
                          color: PoliceColors.textMuted.withValues(alpha: 0.7),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const ModuleSectionHeader(
            'Sağlık rehberi',
            subtitle: 'Konuya göre özet ve adımlar',
            topGap: 8,
          ),
          for (final konu in SaglikRehberKonu.values)
            PoliceModuleListTile(
              style: PoliceModules.saglik,
              title: konu.title,
              subtitle: konu.subtitle,
              onTap: () {
                Navigator.of(context).push(
                  fadeRoute(SaglikRehberDetayPage(konu: konu)),
                );
              },
            ),
          const ModuleSectionHeader(
            'Sağlık asistanı',
            subtitle: 'Durumunu yaz — mevzuat yönlendirmesi al',
            topGap: 8,
          ),
          PoliceModuleListTile(
            style: PoliceModules.asistan,
            title: 'Sağlık Asistanı',
            subtitle:
                'Bel fıtığı, heyet, istirahat… Teşhis değil, süreç rehberi.',
            onTap: () {
              Navigator.of(context).push(
                fadeRoute(const SaglikAsistaniPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
