import 'dart:typed_data';

/// Bellekte tutulan veri şifreleme anahtarı; kilitlenince sıfırlanır.
class VaultSession {
  VaultSession._();

  static Uint8List? _dek;

  static bool get isUnlocked => _dek != null;

  static Uint8List get dek {
    final k = _dek;
    if (k == null) {
      throw StateError('Kasa kilitli');
    }
    return k;
  }

  static void unlock(Uint8List dek) {
    lock();
    _dek = Uint8List.fromList(dek);
  }

  static void lock() {
    if (_dek != null) {
      for (var i = 0; i < _dek!.length; i++) {
        _dek![i] = 0;
      }
      _dek = null;
    }
  }
}
