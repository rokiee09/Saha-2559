import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../common/routing/transitions.dart';
import '../../../common/theme/police_colors.dart';
import '../../../common/widgets/police_module_icon.dart';
import '../../../data/models/martyr.dart';
import '../martyrs_anniversary.dart';
import '../martyrs_controller.dart';
import '../martyrs_page.dart';
import 'sehit_devriye_kayar_bant.dart';

/// Ana sayfa en üst: yalnızca bugün şehadet yıldönümü olan şehitler için kayar bant.
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

        return _DevriyeBody(
          gun: data.gun,
          martyrs: data.martyrs,
          onOpen: () {
            ref.read(martyrsAnniversaryFilterProvider.notifier).state = true;
            Navigator.of(context).push(fadeRoute(const MartyrsPage()));
          },
        );
      },
    );
  }
}

class _DevriyeBody extends StatelessWidget {
  const _DevriyeBody({
    required this.gun,
    required this.martyrs,
    required this.onOpen,
  });

  final DateTime gun;
  final List<Martyr> martyrs;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final marquee = buildSehitDevriyeMarqueeText(martyrs);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PoliceColors.sehitAccent.withValues(alpha: 0.5),
              ),
              gradient: LinearGradient(
                colors: [
                  PoliceColors.sehitAccent.withValues(alpha: 0.16),
                  PoliceColors.navy.withValues(alpha: 0.55),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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
                            martyrAnniversarySubtitle(martyrs, gun),
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
                const SizedBox(height: 10),
                Text(
                  sehitDevriyeKapanis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PoliceColors.gold.withValues(alpha: 0.95),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.3,
                    height: 1.35,
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
