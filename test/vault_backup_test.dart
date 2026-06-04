import 'package:coderipple/src/security/encrypted_local_store.dart';
import 'package:coderipple/src/security/vault_backup_service.dart';
import 'package:coderipple/src/security/vault_crypto.dart';
import 'package:coderipple/src/security/vault_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    VaultSession.unlock(VaultCrypto.randomBytes(32));
  });

  tearDown(() {
    VaultSession.lock();
  });

  test('export ve import roundtrip', () async {
    await EncryptedLocalStore.writeString(
      'saha_local_notes_v1',
      '[{"id":"n1","title":"test"}]',
    );

    final json = await VaultBackupService.exportJson();
    final payload = VaultBackupService.parseJson(json);
    expect(payload.entries['saha_local_notes_v1'], isNotNull);

    await EncryptedLocalStore.remove('saha_local_notes_v1');
    final n = await VaultBackupService.importPayload(payload);
    expect(n, greaterThan(0));

    final restored = await EncryptedLocalStore.readString('saha_local_notes_v1');
    expect(restored, contains('n1'));
  });

  test('geçersiz yedek reddedilir', () {
    expect(
      () => VaultBackupService.parseJson('{"format":"other"}'),
      throwsFormatException,
    );
  });
}
