import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import '../haklar/maas_hesaplama_page.dart';
import '../haklar/vardiya/vardiya_hesaplama_page.dart';
import '../home/root_drawer_scope.dart';
import '../saha/saha_category_page.dart';
import 'disiplin/disiplin_rehberi_page.dart';
import 'izin/izin_page.dart';
import 'kariyer/kariyer_page.dart';

/// Görevlerim: polisin kendi durumu — izin, maaş, vardiya, harcama.
/// Tayin/lojman gibi resmî kriter/puan gerektiren bölümler, yanıltıcı tahmin
/// üretmemek için veri hazırlanana kadar "hazırlanıyor" olarak işaretlidir.
class GorevlerimPage extends StatelessWidget {
  const GorevlerimPage({super.key});

  void _openSaha(BuildContext context, String categoryId) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SahaCategoryPage(categoryId: categoryId),
      ),
    );
  }

  void _comingSoon(BuildContext context, String title, String detail) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: PoliceColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const PhosphorIcon(
                      PhosphorIconsRegular.wrench,
                      color: PoliceColors.gold,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$title · hazırlanıyor',
                        style: const TextStyle(
                          color: PoliceColors.titleOnDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  detail,
                  style: TextStyle(
                    color: PoliceColors.mevzuatBodyText.withValues(alpha: 0.92),
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Anladım'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: const HomeDrawerButton(),
        automaticallyImplyLeading: false,
        title: const Text(
          'Görevlerim',
          style: TextStyle(
            color: PoliceColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          _GorevTile(
            icon: PhosphorIconsRegular.calendarBlank,
            title: 'İzinlerim',
            subtitle: 'Yıllık, mazeret, refakat ve doğum izni gün sayacı.',
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(fadeRoute(const IzinPage()));
            },
          ),
          _GorevTile(
            icon: PhosphorIconsRegular.calculator,
            title: 'Maaşım',
            subtitle: 'Katsayıya göre tahmini maaş (bağlayıcı değildir).',
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(fadeRoute(const MaasHesaplamaPage()));
            },
          ),
          _GorevTile(
            icon: PhosphorIconsRegular.calendarCheck,
            title: 'Vardiyam',
            subtitle: 'Vardiya kalıbını seç, ayını planla.',
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context)
                  .push(fadeRoute(const VardiyaHesaplamaPage()));
            },
          ),
          _GorevTile(
            icon: PhosphorIconsRegular.wallet,
            title: 'Harcamalarım',
            subtitle: 'Görevle ilgili kişisel harcama notların.',
            onTap: () => _openSaha(context, 'harcama'),
          ),
          _GorevTile(
            icon: PhosphorIconsRegular.scales,
            title: 'Disiplinlerim',
            subtitle: 'Fiil → olası ceza, savunma süreci ve itiraz yolu.',
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context)
                  .push(fadeRoute(const DisiplinRehberiPage()));
            },
          ),
          _GorevTile(
            icon: PhosphorIconsRegular.medal,
            title: 'Kariyerim',
            subtitle: 'Başarı belgesi, eğitim ve şark görev kayıtların.',
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(fadeRoute(const KariyerPage()));
            },
          ),
          _GorevTile(
            icon: PhosphorIconsRegular.mapPinLine,
            title: 'Tayinim',
            subtitle: 'Branş, hizmet yılı ve puana göre değerlendirme.',
            comingSoon: true,
            onTap: () => _comingSoon(
              context,
              'Tayin',
              'Tayin değerlendirmesi; branş, hizmet yılı ve şark puanı gibi '
                  'resmî kriterlere dayanır. Yanıltıcı bir tahmin vermemek için '
                  'bu bölüm, doğrulanmış kriter verisi eklenince açılacak. '
                  'Kesin sonuç her zaman kurum işlemine bağlıdır.',
            ),
          ),
          _GorevTile(
            icon: PhosphorIconsRegular.house,
            title: 'Lojmanım',
            subtitle: 'Medeni durum ve çocuk sayısına göre puan.',
            comingSoon: true,
            onTap: () => _comingSoon(
              context,
              'Lojman',
              'Lojman puanı; medeni durum, çocuk sayısı ve hizmet süresi gibi '
                  'resmî kriterlere göre hesaplanır. Doğru ve güncel puan '
                  'cetveli eklendiğinde bu bölüm hesaplama yapacak. Kesin puan '
                  'kurum işlemine bağlıdır.',
            ),
          ),
        ],
      ),
    );
  }
}

class _GorevTile extends StatelessWidget {
  const _GorevTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.comingSoon = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
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
                    color: PoliceColors.primaryBlue.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PhosphorIcon(
                    icon,
                    color: PoliceColors.primaryBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: PoliceColors.titleOnDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5,
                              ),
                            ),
                          ),
                          if (comingSoon) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: PoliceColors.gold.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Hazırlanıyor',
                                style: TextStyle(
                                  color: PoliceColors.gold,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.9),
                          fontSize: 12.5,
                          height: 1.32,
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
    );
  }
}
