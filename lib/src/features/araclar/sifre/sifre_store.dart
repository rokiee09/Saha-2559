import 'dart:convert';

import '../../../security/vault_platform.dart';

/// Kayıtlı şifreler yalnızca bu cihazda, kasa AES-256-GCM ile şifrelenir;
/// sunucuya gönderilmez.

/// Şifrenin kullanılacağı sistem/banka hedefi.
class SifreHedef {
  const SifreHedef({
    required this.id,
    required this.label,
    this.banka = false,
  });

  final String id;
  final String label;
  final bool banka;

  static const String digerId = 'diger';

  /// Kurumsal sistemler.
  static const List<SifreHedef> sistemler = [
    SifreHedef(id: 'polnet', label: 'POLNET'),
    SifreHedef(id: 'ebys', label: 'EBYS'),
    SifreHedef(id: 'pbs', label: 'PBS'),
    SifreHedef(id: 'kdm', label: 'KDM'),
    SifreHedef(id: 'tembis', label: 'TEMBİS'),
    SifreHedef(id: 'kapan', label: 'KAPAN'),
    SifreHedef(id: 'sibernet', label: 'SİBERNET'),
  ];

  /// Bankalar.
  static const List<SifreHedef> bankalar = [
    SifreHedef(id: 'garanti', label: 'Garanti BBVA', banka: true),
    SifreHedef(id: 'ziraat', label: 'Ziraat Bankası', banka: true),
    SifreHedef(id: 'isbank', label: 'İş Bankası', banka: true),
    SifreHedef(id: 'vakifbank', label: 'VakıfBank', banka: true),
    SifreHedef(id: 'halkbank', label: 'Halkbank', banka: true),
  ];

  static const SifreHedef diger =
      SifreHedef(id: digerId, label: 'Diğer');

  static List<SifreHedef> get all => [...sistemler, ...bankalar, diger];

  static String labelOf(String id) {
    for (final h in all) {
      if (h.id == id) return h.label;
    }
    return id;
  }
}

class KayitliSifre {
  const KayitliSifre({
    required this.id,
    required this.hedefId,
    required this.hedefLabel,
    required this.sifre,
    required this.createdAtMs,
    this.not = '',
  });

  final String id;
  final String hedefId;

  /// "Diğer" seçilirse kullanıcının yazdığı ad; aksi halde hedef etiketi.
  final String hedefLabel;
  final String sifre;
  final int createdAtMs;
  final String not;

  Map<String, dynamic> toJson() => {
        'id': id,
        'hedefId': hedefId,
        'hedefLabel': hedefLabel,
        // base64 (gerçek şifreleme değil; düz metin okumayı zorlaştırır).
        'sifre': base64Encode(utf8.encode(sifre)),
        'createdAtMs': createdAtMs,
        'not': not,
      };

  factory KayitliSifre.fromJson(Map<String, dynamic> j) {
    var sifre = '';
    final raw = j['sifre'] as String? ?? '';
    if (raw.isNotEmpty) {
      try {
        sifre = utf8.decode(base64Decode(raw));
      } catch (_) {
        sifre = raw;
      }
    }
    return KayitliSifre(
      id: j['id'] as String? ?? '',
      hedefId: j['hedefId'] as String? ?? SifreHedef.digerId,
      hedefLabel: j['hedefLabel'] as String? ?? '',
      sifre: sifre,
      createdAtMs: (j['createdAtMs'] as num?)?.toInt() ?? 0,
      not: j['not'] as String? ?? '',
    );
  }
}

const _prefsKey = 'sifre_kayitli_v1';

Future<List<KayitliSifre>> sifreLoadAll() async {
  final raw = await VaultPlatform.readSensitive(_prefsKey);
  if (raw == null || raw.isEmpty) return [];
  try {
    final dec = jsonDecode(raw);
    if (dec is! List) return [];
    return dec
        .whereType<Map<String, dynamic>>()
        .map(KayitliSifre.fromJson)
        .toList()
      ..sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
  } catch (_) {
    return [];
  }
}

Future<void> _saveAll(List<KayitliSifre> list) async {
  await VaultPlatform.writeSensitive(
    _prefsKey,
    jsonEncode(list.map((e) => e.toJson()).toList()),
  );
}

/// Aynı hedefe ait varsa onu günceller (en güncel kayıt esas), aksi halde ekler.
Future<void> sifreUpsert(KayitliSifre entry) async {
  final list = await sifreLoadAll();
  final idx = list.indexWhere((e) => e.id == entry.id);
  if (idx >= 0) {
    list[idx] = entry;
  } else {
    list.add(entry);
  }
  await _saveAll(list);
}

Future<void> sifreDelete(String id) async {
  final list = (await sifreLoadAll()).where((e) => e.id != id).toList();
  await _saveAll(list);
}

String sifreGenerateId() => 'sifre_${DateTime.now().microsecondsSinceEpoch}';
