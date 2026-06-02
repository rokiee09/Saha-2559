import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../security/biometric_auth_service.dart';
import '../../security/device_integrity.dart';
import '../../security/pin_auth_service.dart';
import '../../security/secure_vault_storage.dart';
import '../../security/vault_gate.dart';
import '../../security/widgets/pin_pad.dart';
import '../../security/widgets/security_warning_banner.dart';

/// Ayarlar: PIN değiştirme, biyometrik, cihaz uyarısı.
class VaultSecuritySettings extends ConsumerStatefulWidget {
  const VaultSecuritySettings({super.key});

  @override
  ConsumerState<VaultSecuritySettings> createState() =>
      _VaultSecuritySettingsState();
}

class _VaultSecuritySettingsState extends ConsumerState<VaultSecuritySettings> {
  DeviceIntegrityReport? _integrity;
  bool _bioOn = false;
  bool _bioCan = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final integrity = await DeviceIntegrityService.scan();
    final can = await BiometricAuthService.canCheckBiometrics();
    final on = await SecureVaultStorage.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _integrity = integrity;
        _bioCan = can;
        _bioOn = on;
        _loading = false;
      });
    }
  }

  Future<void> _changePinFlow() async {
    if (!VaultGate.vaultRequired) {
      _snack('PIN yalnızca Android/iOS mobil sürümde kullanılır.');
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _PinChangePage(
          onDone: () {
            if (mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yerel kasa güvenliği')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Yerel kasa güvenliği')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (_integrity != null) SecurityWarningBanner(report: _integrity!),
          const ListTile(
            title: Text('Veri konumu'),
            subtitle: Text(
              'Görev notları, tutanaklar, kişisel saha kayıtları ve kayıtlı '
              'şifreler AES-256-GCM ile şifrelenir; PIN hash olarak Android '
              'Keystore / güvenli depoda tutulur. Hiçbir kayıt sunucuya '
              'gönderilmez.',
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.pin_outlined),
            title: const Text('PIN değiştir'),
            subtitle: const Text('Mevcut PIN doğrulaması gerekir'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _changePinFlow,
          ),
          if (_bioCan) ...[
            const Divider(height: 0),
            SwitchListTile(
              title: const Text('Biyometrik giriş'),
              subtitle: const Text(
                'Parmak izi veya yüz tanıma ile kasayı aç (PIN yedek kalır)',
              ),
              value: _bioOn,
              onChanged: (v) async {
                if (v) {
                  await BiometricAuthService.enableAfterPinUnlock();
                  setState(() => _bioOn = true);
                  _snack('Biyometrik giriş etkin.');
                } else {
                  await BiometricAuthService.disable();
                  setState(() => _bioOn = false);
                  _snack('Biyometrik giriş kapatıldı.');
                }
              },
            ),
          ],
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.screenshot_monitor_outlined),
            title: const Text('Ekran görüntüsü koruması'),
            subtitle: Text(
              VaultGate.vaultRequired
                  ? 'Android\'de etkin (FLAG_SECURE).'
                  : 'Bu platformda uygulanmaz.',
            ),
          ),
          const Divider(height: 0),
          const ListTile(
            leading: Icon(Icons.lock_clock_outlined),
            title: Text('Otomatik kilit'),
            subtitle: Text(
              'Uygulama arka plana alındığında kasa kilitlenir; '
              '5 yanlış PIN sonrası süreli bekleme uygulanır.',
            ),
          ),
        ],
      ),
    );
  }
}

class _PinChangePage extends StatefulWidget {
  const _PinChangePage({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_PinChangePage> createState() => _PinChangePageState();
}

class _PinChangePageState extends State<_PinChangePage> {
  int _step = 0;
  String? _oldPin;
  String? _newPin;
  String? _error;

  Future<void> _submit(String pin) async {
    if (_step == 0) {
      final r = await PinAuthService.verifyPin(pin);
      if (r != PinVerifyResult.success) {
        setState(() => _error = 'Mevcut PIN hatalı.');
        return;
      }
      setState(() {
        _oldPin = pin;
        _step = 1;
        _error = null;
      });
      return;
    }
    if (_step == 1) {
      setState(() {
        _newPin = pin;
        _step = 2;
        _error = null;
      });
      return;
    }
    if (_newPin != pin) {
      setState(() {
        _step = 1;
        _newPin = null;
        _error = 'Yeni PIN\'ler eşleşmedi.';
      });
      return;
    }
    final r = await PinAuthService.changePin(_oldPin!, pin);
    if (r == PinVerifyResult.success) {
      widget.onDone();
    } else {
      setState(() => _error = 'PIN güncellenemedi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Mevcut PIN', 'Yeni PIN', 'Yeni PIN tekrar'];
    return Scaffold(
      appBar: AppBar(title: const Text('PIN değiştir')),
      body: SafeArea(
        child: Center(
          child: PinPad(
            title: titles[_step],
            errorText: _error,
            onCompleted: _submit,
          ),
        ),
      ),
    );
  }
}
