import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/theme/police_colors.dart';
import '../kariyer_profil_provider.dart';

/// Gazi personel için ana sayfada sürekli görünen teşekkür kartı (kapatılamaz).
class GaziTesekkurKart extends ConsumerWidget {
  const GaziTesekkurKart({super.key});

  static const mesaj =
      'Vatan uğruna göstermiş olduğunuz fedakârlık için şükranlarımızı sunarız.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profil = ref.watch(kariyerProfilProvider).valueOrNull;
    if (profil == null || !profil.gazi) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PoliceColors.gold.withValues(alpha: 0.22),
              PoliceColors.navy.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: PoliceColors.gold.withValues(alpha: 0.55),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.military_tech_rounded,
                  color: PoliceColors.gold.withValues(alpha: 0.95),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Gazi personel',
                  style: TextStyle(
                    color: PoliceColors.gold.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              mesaj,
              style: TextStyle(
                color: PoliceColors.titleOnDark.withValues(alpha: 0.95),
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
