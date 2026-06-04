import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pin_auth_service.dart';

/// Manuel kasa kilidi — [VaultGate] dinler.
final vaultLockEpochProvider = StateProvider<int>((ref) => 0);

void requestVaultLock(WidgetRef ref) {
  PinAuthService.lockSession();
  ref.read(vaultLockEpochProvider.notifier).update((n) => n + 1);
}
