import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'saha_note.dart';

const _prefsKey = 'saha_local_notes_v1';

Future<List<SahaNote>> _loadAllSorted() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_prefsKey);
  if (raw == null || raw.isEmpty) return [];
  try {
    final dec = jsonDecode(raw);
    if (dec is! List<dynamic>) return [];
    final list = dec
        .whereType<Map<String, dynamic>>()
        .map(SahaNote.fromJson)
        .toList()
      ..sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
    return list;
  } catch (_) {
    return [];
  }
}

Future<void> _saveAll(List<SahaNote> notes) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _prefsKey,
    jsonEncode(notes.map((e) => e.toJson()).toList()),
  );
}

final sahaNotesVersionProvider = StateProvider<int>((ref) => 0);

final sahaNotesProvider = FutureProvider<List<SahaNote>>((ref) async {
  ref.watch(sahaNotesVersionProvider);
  return _loadAllSorted();
});

Future<void> sahaUpsertNote(WidgetRef ref, SahaNote note) async {
  final all = await _loadAllSorted();
  final idx = all.indexWhere((e) => e.id == note.id);
  if (idx >= 0) {
    all[idx] = note;
  } else {
    all.add(note);
  }
  all.sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
  await _saveAll(all);
  ref.read(sahaNotesVersionProvider.notifier).state++;
}

Future<void> sahaDeleteNote(WidgetRef ref, String id) async {
  final all = await _loadAllSorted();
  for (final e in all.where((e) => e.id == id)) {
    for (final path in e.imagePaths) {
      await sahaDeleteImageFile(path);
    }
  }
  await _saveAll(all.where((e) => e.id != id).toList());
  ref.read(sahaNotesVersionProvider.notifier).state++;
}

String sahaGenerateNoteId() =>
    'saha_${DateTime.now().microsecondsSinceEpoch}';

Future<Directory> _imgDir() async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}${Platform.pathSeparator}saha_img');
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
Future<String> sahaSaveImage(String sourcePath) async {
  final dir = await _imgDir();
  final ext = _extOf(sourcePath);
  final dest =
      '${dir.path}${Platform.pathSeparator}img_${DateTime.now().microsecondsSinceEpoch}$ext';
  await File(sourcePath).copy(dest);
  return dest;
}

Future<void> sahaDeleteImageFile(String path) async {
  try {
    final f = File(path);
    if (await f.exists()) await f.delete();
  } catch (_) {
    // Dosya yoksa/erişilemiyorsa sessiz geç.
  }
}
