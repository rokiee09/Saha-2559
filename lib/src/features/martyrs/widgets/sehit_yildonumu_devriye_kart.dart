import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../common/routing/transitions.dart';
import '../../../common/theme/police_colors.dart';
import '../../../common/widgets/police_module_icon.dart';
import '../martyrs_anniversary.dart';
import '../martyrs_controller.dart';
import '../martyrs_page.dart';
import 'sehit_devriye_kayar_bant.dart';

/// Ana sayfa: bugün şehadet yıldönümü olan şehitler — kayar isim bandı.
class SehitYildonumuDevriyeKart extends ConsumerWidget {
  const SehitYildonumuDevriyeKart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(martyrsAnniversaryTodayProvider);
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        if (data.martyrs.isEmpty) return const SizedBox.shrink();

        final gun = data.gun;
        final marquee = buildSehitDevriyeMarqueeText(data.martyrs);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: PoliceColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                ref.read(martyrsAnniversaryFilterProvider.notifier).state =
                    true;
                Navigator.of(context).push(
                  fadeRoute(const MartyrsPage()),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: PoliceColors.sehitAccent.withValues(alpha: 0.45),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      PoliceColors.sehitAccent.withValues(alpha: 0.12),
                      PoliceColors.navy.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        PoliceModuleIconBadge(
                          style: PoliceModules.sehitler,
                          size: 20,
                          padding: 7,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Şehitlerimizin yıldönümü devriyesi',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: PoliceColors.titleOnDark,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                martyrAnniversarySubtitle(data.martyrs, gun),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: PoliceColors.textMuted,
                                      height: 1.3,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        PhosphorIcon(
                          PhosphorIconsRegular.caretRight,
                          color: PoliceColors.textMuted.withValues(alpha: 0.85),
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SehitDevriyeKayarBant(text: marquee),
                    const SizedBox(height: 8),
                    Text(
                      sehitDevriyeKapanis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: PoliceColors.gold.withValues(alpha: 0.92),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        height: 1.35,
                      ),
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
