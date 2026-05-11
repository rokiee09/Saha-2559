import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final all = (await _loadAllSorted()).where((e) => e.id != id).toList();
  await _saveAll(all);
  ref.read(sahaNotesVersionProvider.notifier).state++;
}

String sahaGenerateNoteId() =>
    'saha_${DateTime.now().microsecondsSinceEpoch}';
