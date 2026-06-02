import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/theme/police_colors.dart';
import '../../../../common/widgets/rutbe_level_icon.dart';
import '../../emeklilik/emeklilik_calculator.dart';
import '../kariyer_constants.dart';
import '../kariyer_profil.dart';
import '../kariyer_profil_provider.dart';
import 'profil_form.dart';

/// Tam ekran profil düzenleme (Kariyerim veya ana sayfa kartından açılır).
class ProfilPage extends ConsumerStatefulWidget {
  const ProfilPage({super.key});

  @override
  ConsumerState<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends ConsumerState<ProfilPage> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final profilAsync = ref.watch(kariyerProfilProvider);

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
            'Bilgileri girerken form görünür. Kaydettikten sonra kısa özet kalır; gerektiğinde Düzenle ile tekrar açılır.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.88),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          profilAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
            ),
            error: (_, __) => const Text('Profil yüklenemedi.'),
            data: (profil) {
              final formAcik = _editing || !profil.hasOzet;
              if (!formAcik) {
                return _ProfilKayitOzet(
                  profil: profil,
                  onEdit: () => setState(() => _editing = true),
                );
              }
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PoliceColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: PoliceColors.primaryBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: ProfilForm(
                  onSaved: () => setState(() => _editing = false),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfilKayitOzet extends StatelessWidget {
  const _ProfilKayitOzet({
    required this.profil,
    required this.onEdit,
  });

  final KariyerProfil profil;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final rutbe = KariyerRutbe.byId(profil.rutbeId);
    final egitim = EgitimDurumuX.fromId(profil.egitimId)?.label;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PoliceColors.primaryBlue.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: rutbe == null
                    ? const Icon(
                        Icons.account_circle_rounded,
                        color: PoliceColors.primaryBlue,
                        size: 32,
                      )
                    : RutbeRankIcon(
                        levelIndex: rutbe.levelIndex,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profil.adSoyad.isEmpty ? 'Profil kaydı' : profil.adSoyad,
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Bilgiler kaydedildi. Form kapalı tutuluyor.',
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.85),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: onEdit, child: const Text('Düzenle')),
            ],
          ),
          const Divider(height: 22, color: PoliceColors.outlineMuted),
          _ozetSatir('Rütbe', rutbe?.label ?? '—'),
          _ozetSatir('Sicil', profil.sicil.isEmpty ? '—' : profil.sicil),
          _ozetSatir('Birim', profil.birim.isEmpty ? '—' : profil.birim),
          _ozetSatir('İl', profil.il.isEmpty ? '—' : profil.il),
          _ozetSatir('Eğitim', egitim ?? '—'),
          if (profil.gorevBaslamaMs > 0)
            _ozetSatir(
              'Mesleğe giriş',
              formatTrTarih(
                DateTime.fromMillisecondsSinceEpoch(profil.gorevBaslamaMs),
              ),
            ),
          if (profil.dogumTarihiMs > 0)
            _ozetSatir(
              'Doğum tarihi',
              formatTrTarih(
                DateTime.fromMillisecondsSinceEpoch(profil.dogumTarihiMs),
              ),
            ),
        ],
      ),
    );
  }

  Widget _ozetSatir(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.82),
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: PoliceColors.titleOnDark,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
