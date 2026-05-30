import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gider_models.dart';

/// O-1 gider kayıtları cihazda (SharedPreferences) tutulur; fiş görüntüleri
/// uygulamanın özel belge klasöründe (o1_fis/) saklanır. Hiçbir veri buluta
/// gönderilmez.

const _prefsKey = 'o1_gider_v1';

Future<List<GiderKayit>> giderLoadAll() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_prefsKey);
  if (raw == null || raw.isEmpty) return [];
  try {
    final dec = jsonDecode(raw);
    if (dec is! List) return [];
    return dec
        .whereType<Map<String, dynamic>>()
        .map(GiderKayit.fromJson)
        .toList()
      ..sort((a, b) => b.tarihMs.compareTo(a.tarihMs));
  } catch (_) {
    return [];
  }
}

Future<void> _saveAll(List<GiderKayit> list) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _prefsKey,
    jsonEncode(list.map((e) => e.toJson()).toList()),
  );
}

Future<void> giderUpsert(GiderKayit entry) async {
  final list = await giderLoadAll();
  final idx = list.indexWhere((e) => e.id == entry.id);
  if (idx >= 0) {
    list[idx] = entry;
  } else {
    list.add(entry);
  }
  await _saveAll(list);
}

Future<void> giderDelete(String id) async {
  final list = await giderLoadAll();
  final target = list.where((e) => e.id == id).toList();
  for (final e in target) {
    for (final path in e.fisPaths) {
      await giderDeleteImageFile(path);
    }
  }
  await _saveAll(list.where((e) => e.id != id).toList());
}

String giderGenerateId() => 'gider_${DateTime.now().microsecondsSinceEpoch}';

Future<Directory> _fisDir() async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}${Platform.pathSeparator}o1_fis');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}

String _extOf(String path) {
  final dot = path.lastIndexOf('.');
  final slash = path.lastIndexOf(RegExp(r'[\\/]'));
  if (dot > slash && dot != -1) {
    final ext = path.substring(dot);
    if (ext.length <= 5) return ext;
  }
  return '.jpg';
}

/// Seçilen/çekilen görüntüyü uygulama klasörüne kopyalar ve yeni yolu döndürür.
Future<String> giderSaveImage(String sourcePath) async {
  final dir = await _fisDir();
  final ext = _extOf(sourcePath);
  final dest =
      '${dir.path}${Platform.pathSeparator}fis_${DateTime.now().microsecondsSinceEpoch}$ext';
  await File(sourcePath).copy(dest);
  return dest;
}

Future<void> giderDeleteImageFile(String path) async {
  try {
    final f = File(path);
    if (await f.exists()) await f.delete();
  } catch (_) {
    // Dosya yoksa/erişilemiyorsa sessiz geç.
  }
}
