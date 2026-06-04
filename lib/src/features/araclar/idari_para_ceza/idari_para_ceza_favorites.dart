import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'idari_para_ceza_favorites_v1';

class IdariParaCezaFavoritesNotifier extends StateNotifier<Set<String>> {
  IdariParaCezaFavoritesNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key);
    if (raw != null) state = raw.toSet();
  }

  Future<void> toggle(String id) async {
    final next = {...state};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, next.toList()..sort());
  }

  bool isFavorite(String id) => state.contains(id);
}

final idariParaCezaFavoritesProvider =
    StateNotifierProvider<IdariParaCezaFavoritesNotifier, Set<String>>(
  (ref) => IdariParaCezaFavoritesNotifier(),
);
