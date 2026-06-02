import 'package:flutter/material.dart';

import '../../common/theme/police_colors.dart';
import '../device_integrity.dart';

class SecurityWarningBanner extends StatelessWidget {
  const SecurityWarningBanner({
    super.key,
    required this.report,
  });

  final DeviceIntegrityReport report;

  @override
  Widget build(BuildContext context) {
    if (!report.hasWarning) return const SizedBox.shrink();
    return Material(
      color: PoliceColors.gold.withValues(alpha: 0.14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 22,
              color: PoliceColors.gold.withValues(alpha: 0.95),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Güvenlik uyarısı',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: PoliceColors.titleOnDark.withValues(alpha: 0.95),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...report.messages.map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        m,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: PoliceColors.mevzuatBodyText
                              .withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kişisel kayıtlar yine de yalnızca cihazınızda şifreli tutulur; '
                    'sunucuya gönderilmez.',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: PoliceColors.textMuted.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
