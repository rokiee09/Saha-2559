import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const readingScaleMin = 0.88;
const readingScaleMax = 1.22;
const readingScaleDefault = 1.0;

const _prefsKey = 'reading_text_scale_v1';

final readingScaleProvider =
    StateNotifierProvider<ReadingScaleNotifier, double>((ref) {
  return ReadingScaleNotifier();
});

class ReadingScaleNotifier extends StateNotifier<double> {
  ReadingScaleNotifier() : super(readingScaleDefault) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getDouble(_prefsKey);
    if (v != null && v >= readingScaleMin && v <= readingScaleMax) {
      state = v;
    }
  }

  Future<void> setScale(double value) async {
    final clamped = value.clamp(readingScaleMin, readingScaleMax);
    state = clamped;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefsKey, clamped);
  }
}
