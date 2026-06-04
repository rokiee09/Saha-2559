import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../common/theme/police_colors.dart';
import '../../common/theme/saha_module_theme.dart';
import '../../common/widgets/module_section_header.dart';
import '../../security/device_integrity.dart';
import '../../security/secure_vault_storage.dart';
import '../../security/vault_backup_service.dart';
import '../../security/vault_data_inventory.dart';
import '../../security/vault_gate.dart';
import '../../security/vault_lock_notifier.dart';
import '../../security/vault_session.dart';
import '../../security/widgets/security_warning_banner.dart';
import 'vault_security_settings.dart';

final vaultInventoryProvider = FutureProvider.autoDispose<List<VaultInventoryRow>>(
  (ref) => VaultDataInventory.scan(),
);

/// Güvenlik merkezi: kasa durumu, şifreli veri listesi, yedekleme.
class SecurityCenterPage extends ConsumerStatefulWidget {
  const SecurityCenterPage({super.key});

  @override
  ConsumerState<SecurityCenterPage> createState() => _SecurityCenterPageState();
}

class _SecurityCenterPageState extends ConsumerState<SecurityCenterPage> {
  DeviceIntegrityReport? _integrity;
  bool _pinConfigured = false;
  bool _bioOn = false;
  bool _loadingMeta = true;

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    final integrity = await DeviceIntegrityService.scan();
    final pin = await SecureVaultStorage.isPinConfigured();
    final bio = await SecureVaultStorage.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _integrity = integrity;
        _pinConfigured = pin;
        _bioOn = bio;
        _loadingMeta = false;
      });
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _exportBackup() async {
    if (!VaultSession.isUnlocked) {
      _snack('Yedek için kasa açık olmalıdır.');
      return;
    }
    try {
      final json = await VaultBackupService.exportJson();
      final name =
          'saha2559_yedek_${DateTime.now().toIso8601String().substring(0, 10)}.json';
      if (kIsWeb) {
        await Clipboard.setData(ClipboardData(text: json));
        _snack('Yedek JSON panoya kopyalandı.');
        return;
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$name');
      await file.writeAsString(json);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json', name: name)],
        subject: 'SAHA 2559 yerel yedek',
        text:
            'Hassas veri içerir; güvenli kanalla paylaşın ve işiniz bitince silin.',
      );
    } catch (e) {
      _snack('Yedek oluşturulamadı: $e');
    }
  }

  Future<void> _importBackup() async {
    if (!VaultSession.isUnlocked) {
      _snack('Geri yükleme için kasa açık olmalıdır.');
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yedeği geri yükle'),
        content: const Text(
          'Seçilen dosyadaki kayıtlar mevcut şifreli verinin üzerine yazılır. '
          'Devam etmeden önce güncel bir yedek almanız önerilir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Geri yükle'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final raw = file.bytes != null
          ? String.fromCharCodes(file.bytes!)
          : await File(file.path!).readAsString();
      final payload = VaultBackupService.parseJson(raw);
      final n = await VaultBackupService.importPayload(payload);
      ref.invalidate(vaultInventoryProvider);
      _snack('$n kategori geri yüklendi.');
    } catch (e) {
      _snack('Geri yükleme başarısız: $e');
    }
  }

  void _lockNow() {
    if (!VaultGate.vaultRequired) {
      _snack('Bu platformda kasa kullanılmıyor.');
      return;
    }
    requestVaultLock(ref);
    _snack('Kasa kilitlendi.');
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(vaultInventoryProvider);
    final unlocked = VaultSession.isUnlocked || !VaultGate.vaultRequired;
    final theme = SahaModuleTheme.forArea(SahaModuleArea.vault);

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Güvenlik merkezi'),
      ),
      body: RefreshIndicator(
        color: PoliceColors.primaryBlue,
        onRefresh: () async {
          await _loadMeta();
          ref.invalidate(vaultInventoryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (_integrity != null) SecurityWarningBanner(report: _integrity!),
            _StatusCard(
              theme: theme,
              unlocked: unlocked,
              pinConfigured: _pinConfigured,
              bioOn: _bioOn,
              vaultRequired: VaultGate.vaultRequired,
              loading: _loadingMeta,
            ),
            const ModuleSectionHeader(
              'Şifreli veriler',
              subtitle: 'Yalnızca bu cihazda; sunucuya çıkmaz',
              area: SahaModuleArea.vault,
            ),
            inventory.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
                ),
              ),
              error: (e, _) => Text('Liste yüklenemedi: $e'),
              data: (rows) => Column(
                children: [
                  for (final row in rows) _InventoryTile(row: row),
                ],
              ),
            ),
            const ModuleSectionHeader(
              'Yedekleme',
              subtitle: 'JSON dosyası — hassas içerik',
              topGap: 12,
              area: SahaModuleArea.vault,
            ),
            _ActionTile(
              icon: PhosphorIconsRegular.export,
              title: 'Yedek al',
              subtitle: unlocked
                  ? 'Saha notları, günlük, gider ve şifre kasası'
                  : 'Kasa kilitliyken kullanılamaz',
              enabled: unlocked,
              onTap: _exportBackup,
            ),
            _ActionTile(
              icon: PhosphorIconsRegular.upload,
              title: 'Yedekten geri yükle',
              subtitle: 'JSON dosyası seçin (mevcut kayıtların üzerine yazar)',
              enabled: unlocked,
              onTap: _importBackup,
            ),
            const ModuleSectionHeader(
              'Ayarlar',
              topGap: 12,
              area: SahaModuleArea.vault,
            ),
            _ActionTile(
              icon: PhosphorIconsRegular.gear,
              title: 'PIN ve biyometrik',
              subtitle: 'PIN değiştir, parmak izi / yüz tanıma',
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const VaultSecuritySettings(),
                ),
              ),
            ),
            if (VaultGate.vaultRequired)
              _ActionTile(
                icon: PhosphorIconsRegular.lock,
                title: 'Şimdi kilitle',
                subtitle: 'Kasa oturumunu kapat; PIN ile tekrar açın',
                onTap: _lockNow,
              ),
            const SizedBox(height: 12),
            Text(
              'Yedek dosyası düz JSON içerir; üçüncü kişilerle paylaşmayın. '
              'Resmî kayıt veya bulut senkronu yoktur.',
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.8),
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.theme,
    required this.unlocked,
    required this.pinConfigured,
    required this.bioOn,
    required this.vaultRequired,
    required this.loading,
  });

  final SahaModuleTheme theme;
  final bool unlocked;
  final bool pinConfigured;
  final bool bioOn;
  final bool vaultRequired;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final accent = theme.accentColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: PhosphorIcon(
              unlocked ? PhosphorIconsRegular.lockOpen : PhosphorIconsRegular.lock,
              color: accent,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loading
                      ? 'Durum yükleniyor…'
                      : unlocked
                          ? 'Kasa açık'
                          : 'Kasa kilitli',
                  style: const TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vaultRequired
                      ? pinConfigured
                          ? 'PIN tanımlı${bioOn ? ' · Biyometrik açık' : ''}'
                          : 'PIN henüz kurulmadı'
                      : 'Masaüstü/web: kasa devre dışı',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.9),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'AES-256-GCM · PBKDF2 PIN · Keystore/Keychain',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.75),
                    fontSize: 11,
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

class _InventoryTile extends StatelessWidget {
  const _InventoryTile({required this.row});

  final VaultInventoryRow row;

  IconData get _statusIcon => switch (row.status) {
        VaultInventoryStatus.unlocked => PhosphorIconsRegular.checkCircle,
        VaultInventoryStatus.encrypted => PhosphorIconsRegular.lock,
        VaultInventoryStatus.plainLegacy => PhosphorIconsRegular.warning,
        VaultInventoryStatus.empty => PhosphorIconsRegular.circle,
      };

  Color get _statusColor => switch (row.status) {
        VaultInventoryStatus.unlocked => PoliceColors.primaryBlue,
        VaultInventoryStatus.encrypted => PoliceColors.gold,
        VaultInventoryStatus.plainLegacy => const Color(0xFFF59E0B),
        VaultInventoryStatus.empty => PoliceColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: PhosphorIcon(_statusIcon, color: _statusColor, size: 22),
          title: Text(
            row.category.title,
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${row.detail}\n${row.category.routeHint}',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.88),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          enabled: enabled,
          leading: PhosphorIcon(
            icon,
            color: enabled
                ? PoliceColors.primaryBlue
                : PoliceColors.textMuted.withValues(alpha: 0.5),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.88),
              fontSize: 12.5,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onTap();
                }
              : null,
        ),
      ),
    );
  }
}
