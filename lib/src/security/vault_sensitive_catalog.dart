/// Kasa ile şifrelenen yerel veri kategorileri (görünen ad + mantıksal anahtar).
class VaultSensitiveCategory {
  const VaultSensitiveCategory({
    required this.logicalKey,
    required this.title,
    required this.subtitle,
    required this.routeHint,
  });

  final String logicalKey;
  final String title;
  final String subtitle;
  final String routeHint;
}

const kVaultSensitiveCategories = <VaultSensitiveCategory>[
  VaultSensitiveCategory(
    logicalKey: 'saha_local_notes_v1',
    title: 'Saha notları',
    subtitle: 'Kişisel görev notları ve etiketli kayıtlar',
    routeHint: 'Araçlar → Saha kategorileri',
  ),
  VaultSensitiveCategory(
    logicalKey: 'gorev_gunluk_v1',
    title: 'Görev günlüğü',
    subtitle: 'Günlük görev kayıtları',
    routeHint: 'Araçlar → Görev günlüğüm',
  ),
  VaultSensitiveCategory(
    logicalKey: 'o1_gider_v1',
    title: 'O-1 giderleri',
    subtitle: 'Harcama ve gider takibi',
    routeHint: 'Araçlar → O-1 Gider',
  ),
  VaultSensitiveCategory(
    logicalKey: 'sifre_kayitli_v1',
    title: 'Kayıtlı şifreler',
    subtitle: 'Sistem ve banka şifre kasası',
    routeHint: 'Araçlar → Kayıtlı şifreler',
  ),
];
