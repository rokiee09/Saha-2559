import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gorev_gunluk_models.dart';

const _prefsKey = 'gorev_gunluk_v1';

Future<List<GorevGunlukKayit>> gorevGunlukLoadAll() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_prefsKey);
  if (raw == null || raw.isEmpty) return [];
  try {
    final dec = jsonDecode(raw);
    if (dec is! List) return [];
    return dec
        .whereType<Map<String, dynamic>>()
        .map(GorevGunlukKayit.fromJson)
        .toList()
      ..sort((a, b) {
        final c = b.tarihMs.compareTo(a.tarihMs);
        if (c != 0) return c;
        return b.saat.compareTo(a.saat);
      });
  } catch (_) {
    return [];
  }
}

Future<void> _saveAll(List<GorevGunlukKayit> list) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _prefsKey,
    jsonEncode(list.map((e) => e.toJson()).toList()),
  );
}

Future<void> gorevGunlukUpsert(GorevGunlukKayit entry) async {
  final list = await gorevGunlukLoadAll();
  final idx = list.indexWhere((e) => e.id == entry.id);
  if (idx >= 0) {
    list[idx] = entry;
  } else {
    list.add(entry);
  }
  await _saveAll(list);
}

Future<void> gorevGunlukDelete(String id) async {
  final list = await gorevGunlukLoadAll();
  for (final e in list.where((e) => e.id == id)) {
    for (final path in e.fotoPaths) {
      await gorevGunlukDeleteImageFile(path);
    }
  }
  await _saveAll(list.where((e) => e.id != id).toList());
}

String gorevGunlukGenerateId() =>
    'gg_${DateTime.now().microsecondsSinceEpoch}';

Future<Directory> _fotoDir() async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}${Platform.pathSeparator}gorev_gunluk');
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

Future<String> gorevGunlukSaveImage(String sourcePath) async {
  final dir = await _fotoDir();
  final ext = _extOf(sourcePath);
  final dest =
      '${dir.path}${Platform.pathSeparator}f_${DateTime.now().microsecondsSinceEpoch}$ext';
  await File(sourcePath).copy(dest);
  return dest;
}

Future<void> gorevGunlukDeleteImageFile(String path) async {
  try {
    final f = File(path);
    if (await f.exists()) await f.delete();
  } catch (_) {}
}
