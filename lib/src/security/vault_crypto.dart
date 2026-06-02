import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// AES-256-GCM ile yerel kasa verisi şifreleme.
class VaultCrypto {
  VaultCrypto._();

  static final AesGcm _aes = AesGcm.with256bits();
  static final Random _rng = Random.secure();

  static Uint8List randomBytes(int length) {
    final out = Uint8List(length);
    for (var i = 0; i < length; i++) {
      out[i] = _rng.nextInt(256);
    }
    return out;
  }

  static Future<Uint8List> derivePinKey(String pin, Uint8List salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 120000,
      bits: 256,
    );
    final key = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    return Uint8List.fromList(await key.extractBytes());
  }

  static Future<Uint8List> hashPinKey(Uint8List pinKey) async {
    final digest = await Sha256().hash(pinKey);
    return Uint8List.fromList(digest.bytes);
  }

  static Future<String> encryptString(String plaintext, Uint8List dek) async {
    final nonce = randomBytes(12);
    final box = await _aes.encrypt(
      utf8.encode(plaintext),
      secretKey: SecretKey(dek),
      nonce: nonce,
    );
    final payload = <int>[
      ...nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ];
    return base64Encode(payload);
  }

  static Future<String> decryptString(String blob, Uint8List dek) async {
    final raw = base64Decode(blob);
    if (raw.length < 12 + 16) {
      throw const FormatException('Geçersiz şifreli kayıt');
    }
    final nonce = Uint8List.fromList(raw.sublist(0, 12));
    final macStart = raw.length - 16;
    final cipherText = raw.sublist(12, macStart);
    final mac = Mac(raw.sublist(macStart));
    final clear = await _aes.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: SecretKey(dek),
    );
    return utf8.decode(clear);
  }

  static Future<Uint8List> wrapDek(Uint8List dek, Uint8List pinKey) async {
    final nonce = randomBytes(12);
    final box = await _aes.encrypt(
      dek,
      secretKey: SecretKey(pinKey),
      nonce: nonce,
    );
    return Uint8List.fromList([...nonce, ...box.cipherText, ...box.mac.bytes]);
  }

  static Future<Uint8List> unwrapDek(Uint8List wrapped, Uint8List pinKey) async {
    if (wrapped.length < 12 + 32 + 16) {
      throw const FormatException('Geçersiz anahtar sarmalayıcı');
    }
    final nonce = wrapped.sublist(0, 12);
    final macStart = wrapped.length - 16;
    final cipherText = wrapped.sublist(12, macStart);
    final mac = Mac(wrapped.sublist(macStart));
    final clear = await _aes.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: SecretKey(pinKey),
    );
    return Uint8List.fromList(clear);
  }
}
