import 'package:shared_preferences/shared_preferences.dart';

import 'vardiya_setup_config.dart';

/// Cihazda saklanan vardiya kurulum tercihleri.
class VardiyaSetupState {
  const VardiyaSetupState({
    this.anchorMs,
    this.cycleIndex = 0,
    this.startNight = false,
    this.group = 1,
    this.tableDays = 15,
    this.cakmaPatternId = '5_10',
    this.optionId,
  });

  final int? anchorMs;
  final int cycleIndex;
  final bool startNight;
  final int group;
  final int tableDays;
  final String cakmaPatternId;
  final String? optionId;

  bool get isConfigured => anchorMs != null;

  DateTime? get anchorDate =>
      anchorMs != null ? DateTime.fromMillisecondsSinceEpoch(anchorMs!) : null;
}

class VardiyaSetupStore {
  static String _key(String shiftId, String suffix) =>
      'vardiya_${suffix}_$shiftId';

  static Future<VardiyaSetupState> load(String shiftId) async {
    final prefs = await SharedPreferences.getInstance();
    return VardiyaSetupState(
      anchorMs: prefs.getInt(_key(shiftId, 'anchor')),
      cycleIndex: prefs.getInt(_key(shiftId, 'cycle')) ?? 0,
      startNight: prefs.getBool(_key(shiftId, 'startnight')) ??
          (shiftId == 'gercek_12_36'),
      group: prefs.getInt(_key(shiftId, 'group')) ?? 1,
      tableDays: prefs.getInt(_key(shiftId, 'tabledays')) ?? 15,
      cakmaPatternId: prefs.getString(_key(shiftId, 'cakmapattern')) ?? '5_10',
      optionId: prefs.getString(_key(shiftId, 'option')),
    );
  }

  static Future<void> save(String shiftId, VardiyaSetupState state) async {
    final prefs = await SharedPreferences.getInstance();
    if (state.anchorMs != null) {
      await prefs.setInt(_key(shiftId, 'anchor'), state.anchorMs!);
    }
    await prefs.setInt(_key(shiftId, 'cycle'), state.cycleIndex);
    await prefs.setBool(_key(shiftId, 'startnight'), state.startNight);
    await prefs.setInt(_key(shiftId, 'group'), state.group);
    await prefs.setInt(_key(shiftId, 'tabledays'), state.tableDays);
    await prefs.setString(_key(shiftId, 'cakmapattern'), state.cakmaPatternId);
    if (state.optionId != null) {
      await prefs.setString(_key(shiftId, 'option'), state.optionId!);
    }
    // Eski anahtarlarla uyumluluk (ana sayfa paneli vb.)
    await prefs.setBool('vardiya_startnight_$shiftId', state.startNight);
    if (state.anchorMs != null) {
      await prefs.setInt('vardiya_anchor_$shiftId', state.anchorMs!);
    }
  }

  static Future<void> clear(String shiftId) async {
    final prefs = await SharedPreferences.getInstance();
    for (final suffix in [
      'anchor',
      'cycle',
      'startnight',
      'group',
      'tabledays',
      'cakmapattern',
      'option',
    ]) {
      await prefs.remove(_key(shiftId, suffix));
    }
    await prefs.remove('vardiya_anchor_$shiftId');
    await prefs.remove('vardiya_startnight_$shiftId');
  }

  static CakmaPatternOption? cakmaPatternById(String id) {
    for (final p in VardiyaSetupConfig.cakmaPatterns) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Seçilen tarih, kullanıcının kendi grubuna ait referans tarihidir.
  ///
  /// Önceden gerçek 12/36 için 2. grup seçildiğinde tarih 7 gün geri
  /// çekiliyordu. Bu, "2. grubun gece başlangıcı 24.05" gibi kullanıcı
  /// girişlerini 17.05'e kaydırıp hatalı çizelge üretiyordu.
  static int groupOffsetDays(String shiftId, int group) {
    return 0;
  }
}
