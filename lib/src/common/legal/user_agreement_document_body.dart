import 'package:flutter/material.dart';

import '../constants/app_branding.dart';
import '../constants/app_publisher_contact.dart';
import '../theme/police_colors.dart';
import 'user_agreement_sections.dart';

/// Tam kullanıcı sözleşmesi gövdesi (ön izleme ve ayarlar için ortak).
class UserAgreementDocumentBody extends StatelessWidget {
  const UserAgreementDocumentBody({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          kAppDisplayName,
          textAlign: TextAlign.center,
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Son kullanıcı lisansı ve kullanım koşulları',
          textAlign: TextAlign.center,
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          legalPublisherSummaryLine(),
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: cs.onSurface.withValues(alpha: 0.78),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: PoliceColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: PoliceColors.primaryBlue.withValues(alpha: 0.22),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sözleşme sürümü: $kUserAgreementVersion',
                style: tt.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              Text(
                'Son güncelleme: $kUserAgreementEffectiveLabel',
                style: tt.bodySmall?.copyWith(height: 1.35),
              ),
              Text(
                'Durum: Yürürlükte',
                style: tt.bodySmall?.copyWith(height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.error.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.error.withValues(alpha: 0.38)),
          ),
          child: Text(
            'Önemli: Bu uygulama bağımsız bir yazılımdır; Emniyet veya başka bir kamu kurumuyla '
            'resmî bağlantısı yoktur. Veriler yalnızca cihazınızda tutulur; sunucuya gönderilmez.',
            style: tt.bodySmall?.copyWith(
              height: 1.42,
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 20),
        for (final s in kUserAgreementSections) ...[
          Text(
            s.title,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.body,
            style: tt.bodyMedium?.copyWith(height: 1.48),
          ),
          const SizedBox(height: 18),
        ],
        Text(
          '15. İletişim ve geri bildirim',
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          userAgreementContactSectionBody(),
          style: tt.bodyMedium?.copyWith(height: 1.48),
        ),
        const SizedBox(height: 28),
        Text(
          '© ${DateTime.now().year} $kLegalPublisherDisplayName · $kAppDisplayName',
          textAlign: TextAlign.center,
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.55),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
