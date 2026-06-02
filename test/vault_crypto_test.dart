import 'package:coderipple/src/security/vault_crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AES-256-GCM roundtrip', () async {
    final dek = VaultCrypto.randomBytes(32);
    const plain = '{"test":true,"not":"görev"}';
    final enc = await VaultCrypto.encryptString(plain, dek);
    final dec = await VaultCrypto.decryptString(enc, dek);
    expect(dec, plain);
  });

  test('PIN wrap unwrap preserves DEK', () async {
    final dek = VaultCrypto.randomBytes(32);
    final salt = VaultCrypto.randomBytes(16);
    const pin = '482910';
    final pinKey = await VaultCrypto.derivePinKey(pin, salt);
    final wrapped = await VaultCrypto.wrapDek(dek, pinKey);
    final unwrapped = await VaultCrypto.unwrapDek(wrapped, pinKey);
    expect(unwrapped, dek);
  });
}
