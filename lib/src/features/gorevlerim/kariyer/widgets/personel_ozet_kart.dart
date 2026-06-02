import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/routing/transitions.dart';
import '../../../../common/theme/police_colors.dart';
import '../../../../common/widgets/rutbe_level_icon.dart';
import '../kariyer_constants.dart';
import '../kariyer_ozet_provider.dart';
import '../profil/profil_page.dart';
/// Ana sayfa personel özeti — yalnızca kısa ön bilgiler (rütbe, ad, birim, eğitim).
class PersonelOzetKart extends ConsumerWidget {
  const PersonelOzetKart({super.key, this.onTap});

  /// Varsayılan: Profilim sekmesine geçiş veya detay sayfası.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ozetAsync = ref.watch(kariyerOzetProvider);

    return ozetAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (ozet) {
        if (!ozet.profil.hasOzet) return const SizedBox.shrink();
        final p = ozet.profil;
        final rutbe = p.rutbe;
        final egitim = p.egitim;

        void openProfil() {
          HapticFeedback.selectionClick();
          if (onTap != null) {
            onTap!();
          } else {
            Navigator.of(context).push(fadeRoute(const ProfilPage()));
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Material(
            color: PoliceColors.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: openProfil,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: PoliceColors.primaryBlue.withValues(alpha: 0.28),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (rutbe != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: RutbeRankIcon(
                          levelIndex: rutbe.levelIndex,
                          size: 44,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (rutbe != null)
                            Text(
                              rutbe.label,
                              style: TextStyle(
                                color: PoliceColors.gold.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          if (p.adSoyad.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              p.adSoyad,
                              style: const TextStyle(
                                color: PoliceColors.titleOnDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 15.5,
                              ),
                            ),
                          ],
                          if (p.birim.isNotEmpty || p.il.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              [
                                if (p.il.isNotEmpty) p.il,
                                if (p.birim.isNotEmpty) p.birim,
                              ].join(' '),
                              style: TextStyle(
                                color: PoliceColors.textMuted
                                    .withValues(alpha: 0.88),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                          if (egitim != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              egitim.kisaLabel,
                              style: TextStyle(
                                color: PoliceColors.primaryBlue
                                    .withValues(alpha: 0.88),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: PoliceColors.textMuted.withValues(alpha: 0.7),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
