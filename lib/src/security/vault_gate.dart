import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/constants/app_branding.dart';
import '../common/theme/police_colors.dart';
import '../features/home/home_shell.dart';
import 'biometric_auth_service.dart';
import 'device_integrity.dart';
import 'pin_auth_service.dart';
import 'screenshot_guard.dart';
import 'secure_vault_storage.dart';
import 'vault_lock_notifier.dart';
import 'vault_migration.dart';
import 'vault_session.dart';
import 'widgets/pin_pad.dart';
import 'widgets/security_warning_banner.dart';

enum _VaultPhase { loading, setup, unlock, unlocked }

/// Onboarding sonrası yerel kasa: PIN, biyometrik, arka planda kilit.
class VaultGate extends ConsumerStatefulWidget {
  const VaultGate({super.key});

  static bool get vaultRequired =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  ConsumerState<VaultGate> createState() => _VaultGateState();
}

class _VaultGateState extends ConsumerState<VaultGate>
    with WidgetsBindingObserver {
  _VaultPhase _phase = _VaultPhase.loading;
  String? _error;
  String? _setupFirstPin;
  DeviceIntegrityReport? _integrity;
  bool _bioAvailable = false;
  bool _bioEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ScreenshotGuard.enable();
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_phase != _VaultPhase.unlocked) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _lockFromBackground();
    }
  }

  Future<void> _bootstrap() async {
    if (!VaultGate.vaultRequired) {
      setState(() => _phase = _VaultPhase.unlocked);
      return;
    }

    final integrity = await DeviceIntegrityService.scan();
    final bioDevice = await BiometricAuthService.isDeviceSupported();
    final bioCan = await BiometricAuthService.canCheckBiometrics();
    final configured = await SecureVaultStorage.isPinConfigured();
    final bioOn = await SecureVaultStorage.isBiometricEnabled();

    if (!configured) {
      setState(() {
        _integrity = integrity;
        _bioAvailable = bioDevice && bioCan;
        _phase = _VaultPhase.setup;
      });
      return;
    }

    if (bioOn && bioDevice && bioCan) {
      final opened = await BiometricAuthService.tryUnlockWithBiometric();
      if (opened) {
        await VaultMigration.runIfNeeded();
        setState(() {
          _integrity = integrity;
          _phase = _VaultPhase.unlocked;
        });
        return;
      }
    }

    setState(() {
      _integrity = integrity;
      _bioAvailable = bioDevice && bioCan;
      _bioEnabled = bioOn;
      _phase = _VaultPhase.unlock;
    });
  }

  void _lockFromBackground() {
    PinAuthService.lockSession();
    setState(() {
      _phase = _VaultPhase.unlock;
      _error = null;
      _setupFirstPin = null;
    });
  }

  Future<void> _onSetupPin(String pin) async {
    if (_setupFirstPin == null) {
      setState(() {
        _setupFirstPin = pin;
        _error = null;
      });
      return;
    }
    if (_setupFirstPin != pin) {
      setState(() {
        _setupFirstPin = null;
        _error = 'PIN\'ler eşleşmedi. Tekrar deneyin.';
      });
      return;
    }
    final r = await PinAuthService.setupPin(pin);
    if (r != PinVerifyResult.success) {
      setState(() {
        _setupFirstPin = null;
        _error = 'PIN oluşturulamadı.';
      });
      return;
    }
    await VaultMigration.runIfNeeded();
    if (_bioAvailable && mounted) {
      final useBio = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Biyometrik giriş'),
          content: const Text(
            'Parmak izi veya yüz tanıma ile kasayı hızlı açmak ister misiniz? '
            'PIN her zaman geçerlidir.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hayır'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Evet'),
            ),
          ],
        ),
      );
      if (useBio == true) {
        await BiometricAuthService.enableAfterPinUnlock();
      }
    }
    if (mounted) {
      setState(() {
        _phase = _VaultPhase.unlocked;
        _error = null;
        _setupFirstPin = null;
      });
    }
  }

  Future<void> _onUnlockPin(String pin) async {
    final left = await PinAuthService.lockRemainingMs();
    if (left != null) {
      final sec = (left / 1000).ceil();
      setState(() => _error = 'Çok fazla deneme. $sec sn sonra tekrar deneyin.');
      return;
    }
    final r = await PinAuthService.verifyPin(pin);
    switch (r) {
      case PinVerifyResult.success:
        await VaultMigration.runIfNeeded();
        if (mounted) {
          setState(() {
            _phase = _VaultPhase.unlocked;
            _error = null;
          });
        }
      case PinVerifyResult.wrongPin:
        setState(() => _error = 'Hatalı PIN.');
      case PinVerifyResult.locked:
        final ms = await PinAuthService.lockRemainingMs();
        final sec = ((ms ?? 30000) / 1000).ceil();
        setState(() => _error = 'Kilitli. $sec sn bekleyin.');
      default:
        setState(() => _error = 'PIN doğrulanamadı.');
    }
  }

  Future<void> _tryBiometric() async {
    final ok = await BiometricAuthService.tryUnlockWithBiometric();
    if (!ok) {
      setState(() => _error = 'Biyometrik doğrulama başarısız.');
      return;
    }
    await VaultMigration.runIfNeeded();
    if (mounted) {
      setState(() {
        _phase = _VaultPhase.unlocked;
        _error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(vaultLockEpochProvider, (prev, next) {
      if (prev != null && next > prev && _phase == _VaultPhase.unlocked) {
        _lockFromBackground();
      }
    });

    if (_phase == _VaultPhase.unlocked) {
      return const HomeShell();
    }

    final isSetup = _phase == _VaultPhase.setup;
    final loading = _phase == _VaultPhase.loading;

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            if (_integrity != null) SecurityWarningBanner(report: _integrity!),
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: PoliceColors.primaryBlue,
                        strokeWidth: 2.5,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          Image.asset(
                            'assets/icon/app_icon.png',
                            height: 72,
                            width: 72,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.lock_outline_rounded,
                              size: 64,
                              color: PoliceColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            kAppDisplayName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: PoliceColors.titleOnDark,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isSetup
                                ? 'Yerel kasa — 6 haneli PIN belirleyin'
                                : 'Yerel kasa kilidi',
                            style: TextStyle(
                              color: PoliceColors.textMuted
                                  .withValues(alpha: 0.95),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Görev notları, tutanaklar ve kişisel kayıtlar '
                              'AES-256-GCM ile şifrelenir; internete gönderilmez.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.4,
                                color: PoliceColors.textMuted
                                    .withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          PinPad(
                            title: isSetup
                                ? (_setupFirstPin == null
                                    ? 'Yeni PIN'
                                    : 'PIN tekrar')
                                : 'PIN',
                            subtitle: isSetup && _setupFirstPin == null
                                ? 'Bu PIN düz metin olarak saklanmaz.'
                                : null,
                            errorText: _error,
                            onCompleted: isSetup ? _onSetupPin : _onUnlockPin,
                          ),
                          if (!isSetup &&
                              _bioEnabled &&
                              _bioAvailable) ...[
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              onPressed: _tryBiometric,
                              icon: const Icon(Icons.fingerprint_rounded),
                              label: const Text('Biyometrik ile aç'),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kasa açık mı — Riverpod ile dinlemek için.
final vaultUnlockedProvider = Provider<bool>((ref) {
  return VaultSession.isUnlocked || !VaultGate.vaultRequired;
});
