import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import 'saglik_mevzuat_nav.dart';
import 'saglik_rehberi_data.dart';

/// Sağlık rehberi konu detayı — kullanıcı dostu özet, adımlar, mevzuat linkleri.
class SaglikRehberDetayPage extends StatelessWidget {
  const SaglikRehberDetayPage({super.key, required this.konu});

  final SaglikRehberKonu konu;

  Future<void> _openRef(BuildContext context, SaglikMevzuatRef ref) async {
    HapticFeedback.lightImpact();
    await openSaglikMevzuatRef(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final icerik = rehberIcerik(konu);

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: Text(konu.title),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          _InfoBanner(text: icerik.ozet),
          const SizedBox(height: 16),
          _Block(
            title: 'Uygulamada ne yapmalısınız?',
            child: Text(
              icerik.uygulamada,
              style: const TextStyle(
                color: PoliceColors.mevzuatBodyText,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Block(
            title: 'Adım adım',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < icerik.adimlar.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: PoliceColors.saglikAccent
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: PoliceColors.saglikAccent,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            icerik.adimlar[i],
                            style: const TextStyle(
                              color: PoliceColors.mevzuatBodyText,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Block(
            title: 'Kaynak mevzuat',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ref in icerik.mevzuatRefs)
                  ActionChip(
                    avatar: PhosphorIcon(
                      ref.isInApp
                          ? PhosphorIconsRegular.bookOpen
                          : PhosphorIconsRegular.arrowSquareOut,
                      size: 16,
                      color: PoliceColors.saglikAccent,
                    ),
                    label: Text(ref.label, style: const TextStyle(fontSize: 12)),
                    backgroundColor: PoliceColors.surfaceDark,
                    side: BorderSide(
                      color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
                    ),
                    onPressed: () => _openRef(context, ref),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PoliceColors.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PoliceColors.gold.withValues(alpha: 0.28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Önemli',
                  style: TextStyle(
                    color: PoliceColors.gold.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                for (final u in icerik.uyarilar)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $u',
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.92),
                        fontSize: 12.5,
                        height: 1.35,
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

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceColors.saglikAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.saglikAccent.withValues(alpha: 0.32),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: PoliceColors.titleOnDark,
          fontSize: 13.5,
          height: 1.45,
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child});

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
          color: PoliceColors.outlineMuted.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
