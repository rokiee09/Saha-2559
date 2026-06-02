import 'package:flutter/material.dart';

import 'vardiya_shift_types.dart';

/// Tek bir “bugün durumunuz” seçeneği.
class VardiyaSetupOption {
  const VardiyaSetupOption({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon,
    this.emoji,
    required this.cycleIndex,
  });

  final String id;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? emoji;

  /// Referans gününde döngünün kaçıncı adımı olduğunu belirtir.
  final int cycleIndex;
}

/// Çakma 12/36 patern seçenekleri (referans ekran).
class CakmaPatternOption {
  const CakmaPatternOption({
    required this.id,
    required this.label,
    required this.dayBlockDays,
    required this.nightBlockDays,
  });

  final String id;
  final String label;
  final int dayBlockDays;
  final int nightBlockDays;
}

/// Vardiya türüne göre kurulum ekranı yapılandırması.
class VardiyaSetupConfig {
  const VardiyaSetupConfig({
    required this.shiftId,
    required this.questionTitle,
    required this.questionHint,
    required this.options,
    this.showDatePicker = true,
    this.showGroupPicker = false,
    this.showDayNightPicker = false,
    this.showTableDaysPicker = false,
    this.showCakmaPatternPicker = false,
    this.submitLabel = 'Takvimi oluştur & kaydet',
  });

  final String shiftId;
  final String questionTitle;
  final String questionHint;
  final List<VardiyaSetupOption> options;
  final bool showDatePicker;
  final bool showGroupPicker;
  final bool showDayNightPicker;
  final bool showTableDaysPicker;
  final bool showCakmaPatternPicker;
  final String submitLabel;

  VardiyaTur? get tur => VardiyaTur.byId(shiftId);

  static const tableDayChoices = [5, 7, 10, 15];

  static const cakmaPatterns = [
    CakmaPatternOption(
      id: '2_4',
      label: '2 Gündüz / 4 Gün (Gece-İstirahat)',
      dayBlockDays: 2,
      nightBlockDays: 4,
    ),
    CakmaPatternOption(
      id: '3_6',
      label: '3 Gündüz / 6 Gün (Gece-İstirahat)',
      dayBlockDays: 3,
      nightBlockDays: 6,
    ),
    CakmaPatternOption(
      id: '5_10',
      label: '5 Gündüz / 10 Gün (Gece-İstirahat)',
      dayBlockDays: 5,
      nightBlockDays: 10,
    ),
    CakmaPatternOption(
      id: '7_14',
      label: '7 Gündüz / 14 Gün (Gece-İstirahat)',
      dayBlockDays: 7,
      nightBlockDays: 14,
    ),
    CakmaPatternOption(
      id: '10_20',
      label: '10 Gündüz / 20 Gün (Gece-İstirahat)',
      dayBlockDays: 10,
      nightBlockDays: 20,
    ),
  ];

  static VardiyaSetupConfig? forShift(String shiftId) => _configs[shiftId];

  static const Map<String, VardiyaSetupConfig> _configs = {
    '12_24': VardiyaSetupConfig(
      shiftId: '12_24',
      questionTitle: 'Bugün hangi vardiyadasınız?',
      questionHint:
          'Seçiminiz referans günü için alınır; takvim buna göre oluşturulur.',
      options: [
        VardiyaSetupOption(
          id: 'day',
          title: 'Gündüz çalışıyorum',
          subtitle: '08:00 – 20:00',
          icon: Icons.wb_sunny_rounded,
          cycleIndex: 0,
        ),
        VardiyaSetupOption(
          id: 'night',
          title: 'Gece çalışıyorum',
          subtitle: '20:00 – 08:00 (ertesi gün)',
          icon: Icons.nightlight_round,
          cycleIndex: 1,
        ),
        VardiyaSetupOption(
          id: 'off',
          title: 'İstirahatliyim (off)',
          subtitle: 'Nöbet dışı gün',
          icon: Icons.beach_access_rounded,
          cycleIndex: 2,
        ),
      ],
    ),
    'cakma_12_36': VardiyaSetupConfig(
      shiftId: 'cakma_12_36',
      questionTitle: 'Vardiya paternini seçin',
      questionHint:
          'Blok uzunluğu biriminize göre değişebilir; kesin sıra cetvelden doğrulanmalıdır.',
      showCakmaPatternPicker: true,
      showDayNightPicker: true,
      showTableDaysPicker: true,
      options: [
        VardiyaSetupOption(
          id: 'day_start',
          title: 'Gündüz bloğu ile başlıyorum',
          subtitle: '08:00 – 20:00',
          icon: Icons.wb_sunny_rounded,
          cycleIndex: 0,
        ),
        VardiyaSetupOption(
          id: 'night_start',
          title: 'Gece bloğu ile başlıyorum',
          subtitle: '20:00 – 08:00',
          icon: Icons.nightlight_round,
          cycleIndex: 0,
        ),
      ],
    ),
    'gercek_12_36': VardiyaSetupConfig(
      shiftId: 'gercek_12_36',
      questionTitle: 'Şu an hangi vardiyadasınız?',
      questionHint:
          'Gerçek 12/36: seçtiğiniz tarih, kendi grubunuzun seçtiğiniz gece/gündüz bloğuna başladığı tarihtir.',
      showGroupPicker: true,
      showDayNightPicker: true,
      showTableDaysPicker: true,
      options: [
        VardiyaSetupOption(
          id: 'day',
          title: 'Gündüz (08:00 – 20:00)',
          icon: Icons.wb_sunny_rounded,
          cycleIndex: 0,
        ),
        VardiyaSetupOption(
          id: 'night',
          title: 'Gece (20:00 – 08:00)',
          icon: Icons.nightlight_round,
          cycleIndex: 0,
        ),
      ],
    ),
    '24_48': VardiyaSetupConfig(
      shiftId: '24_48',
      questionTitle: 'Bugün hangi durumdasınız?',
      questionHint: '24/48 örnek döngüsü: 1 görev günü, 2 dinlenme günü.',
      options: [
        VardiyaSetupOption(
          id: 'work',
          title: 'Bugün çalışıyorum (1. gün)',
          icon: Icons.work_outline_rounded,
          cycleIndex: 0,
        ),
        VardiyaSetupOption(
          id: 'rest1',
          title: 'Bugün 1. istirahat günüm',
          icon: Icons.weekend_outlined,
          cycleIndex: 1,
        ),
        VardiyaSetupOption(
          id: 'rest2',
          title: 'Bugün 2. istirahat günüm',
          icon: Icons.hotel_outlined,
          cycleIndex: 2,
        ),
      ],
    ),
    '8_24': VardiyaSetupConfig(
      shiftId: '8_24',
      questionTitle: 'Şu anda hangi vardiyadasınız?',
      questionHint:
          'Bugünkü vardiyayı seçiniz (saatler 08:00–20:00 aralığında özetlenir).',
      options: [
        VardiyaSetupOption(
          id: 'morning',
          title: 'Sabah vardiyası',
          subtitle: '08:00 – 12:00',
          emoji: '☀️',
          cycleIndex: 0,
        ),
        VardiyaSetupOption(
          id: 'afternoon',
          title: 'Öğleden sonra vardiyası',
          subtitle: '12:00 – 16:00',
          emoji: '🌤️',
          cycleIndex: 1,
        ),
        VardiyaSetupOption(
          id: 'evening',
          title: 'Akşam vardiyası',
          subtitle: '16:00 – 20:00',
          emoji: '🌙',
          cycleIndex: 2,
        ),
        VardiyaSetupOption(
          id: 'leave',
          title: 'İzinliyim',
          subtitle: '24 saat izin / nöbet dışı',
          emoji: '🏖️',
          cycleIndex: 3,
        ),
      ],
    ),
    '222': VardiyaSetupConfig(
      shiftId: '222',
      questionTitle: 'Bugün hangi vardiyadasınız?',
      questionHint: '2+2+2 örnek döngüsü: gündüz, gece ve istirahat blokları.',
      options: [
        VardiyaSetupOption(id: 'd1', title: 'Gündüz – 1. gün', cycleIndex: 0),
        VardiyaSetupOption(id: 'd2', title: 'Gündüz – 2. gün', cycleIndex: 1),
        VardiyaSetupOption(id: 'n1', title: 'Gece – 1. gün', cycleIndex: 2),
        VardiyaSetupOption(id: 'n2', title: 'Gece – 2. gün', cycleIndex: 3),
        VardiyaSetupOption(
            id: 'r1', title: 'İstirahat – 1. gün', cycleIndex: 4),
        VardiyaSetupOption(
            id: 'r2', title: 'İstirahat – 2. gün', cycleIndex: 5),
      ],
    ),
    '11': VardiyaSetupConfig(
      shiftId: '11',
      questionTitle: 'Bugün durumunuz nedir?',
      questionHint: 'Lütfen durum seçip takvimi oluştur butonuna basınız.',
      submitLabel: 'Takvimi oluştur',
      options: [
        VardiyaSetupOption(
          id: 'work',
          title: 'Çalışıyorum',
          icon: Icons.badge_outlined,
          cycleIndex: 0,
        ),
        VardiyaSetupOption(
          id: 'rest',
          title: 'İstirahatliyim',
          icon: Icons.self_improvement_outlined,
          cycleIndex: 1,
        ),
      ],
    ),
    '21': VardiyaSetupConfig(
      shiftId: '21',
      questionTitle: 'Bugün durumunuz nedir?',
      questionHint: '2+1 örnek döngüsü: iki çalışma, bir dinlenme.',
      options: [
        VardiyaSetupOption(id: 'w1', title: 'Çalışma – 1. gün', cycleIndex: 0),
        VardiyaSetupOption(id: 'w2', title: 'Çalışma – 2. gün', cycleIndex: 1),
        VardiyaSetupOption(id: 'rest', title: 'İstirahatliyim', cycleIndex: 2),
      ],
    ),
    '31': VardiyaSetupConfig(
      shiftId: '31',
      questionTitle: 'Bugün durumunuz nedir?',
      questionHint: '3+1 örnek döngüsü: üç çalışma, bir dinlenme.',
      options: [
        VardiyaSetupOption(id: 'w1', title: 'Çalışma – 1. gün', cycleIndex: 0),
        VardiyaSetupOption(id: 'w2', title: 'Çalışma – 2. gün', cycleIndex: 1),
        VardiyaSetupOption(id: 'w3', title: 'Çalışma – 3. gün', cycleIndex: 2),
        VardiyaSetupOption(id: 'rest', title: 'İstirahatliyim', cycleIndex: 3),
      ],
    ),
    'asayis_11': VardiyaSetupConfig(
      shiftId: 'asayis_11',
      questionTitle: 'Bugün hangi vardiyadasınız?',
      questionHint:
          'Asayiş tipi vardiya — saatler 08:00–20:00 aralığında özetlenir.',
      options: [
        VardiyaSetupOption(
          id: 'early',
          title: 'Sabah vardiyası',
          subtitle: '08:00 – 14:00',
          emoji: '☀️',
          cycleIndex: 0,
        ),
        VardiyaSetupOption(
          id: 'mid',
          title: 'Akşam vardiyası',
          subtitle: '14:00 – 18:00',
          emoji: '🌅',
          cycleIndex: 1,
        ),
        VardiyaSetupOption(
          id: 'late',
          title: 'Gece vardiyası',
          subtitle: '18:00 – 20:00',
          emoji: '🌙',
          cycleIndex: 2,
        ),
      ],
    ),
  };
}
