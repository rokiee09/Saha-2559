import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/theme/police_colors.dart';
import 'profil_form.dart';

/// Tam ekran profil düzenleme (Kariyerim veya ana sayfa kartından açılır).
class ProfilPage extends ConsumerWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Kişisel bilgilerim'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          Text(
            'Tüm profil alanlarını detaylı doldurun. Ana sayfada yalnızca kısa özet görünür.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.88),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PoliceColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PoliceColors.primaryBlue.withValues(alpha: 0.3),
              ),
            ),
            child: const ProfilForm(),
          ),
        ],
      ),
    );
  }
}
