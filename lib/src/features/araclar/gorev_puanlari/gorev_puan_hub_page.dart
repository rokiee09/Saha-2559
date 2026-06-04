import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../common/theme/police_colors.dart';
import 'gorev_puan_cetvel_policy.dart';
import 'gorev_puan_sark_prefs.dart';
import 'gorev_hizmet_sureleri_page.dart';
import 'gorev_puani_giris_page.dart';
import 'gorev_puanlari_page.dart';
import '../../il_analiz/il_analiz_hub_page.dart';

/// Görev puanı merkezi — cetvel, hesaplama ve PBS uyarısı (2025 / 2026).
class GorevPuanHubPage extends ConsumerWidget {
  const GorevPuanHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sarkAsync = ref.watch(gorevPuanSarkBaslangicProvider);

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Görev Puanı Hesaplama'),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _MenuCard(
            icon: PhosphorIconsRegular.mapTrifold,
            title: 'İl Analizi (Tayin)',
            subtitle:
                'Yaşam, lojman, görev puanı ve ilçe profilleri — kart görünümü.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const IlAnalizHubPage(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: PhosphorIconsRegular.calculator,
            title: '2025 Puan Hesaplama',
            subtitle:
                '31.12.2025\'e kadar olan çalışmalar bu bölümden hesaplanmalı',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const GorevPuaniGirisPage(tercihYil: 2025),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: PhosphorIconsRegular.calculator,
            title: '2026 Puan Hesaplama',
            subtitle:
                '01.01.2026\'dan sonraki çalışmalar bu bölümden hesaplanmalı',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const GorevPuaniGirisPage(tercihYil: 2026),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: PhosphorIconsRegular.calendarCheck,
            title: 'Günlük Görev Puanları (Cetvel)',
            subtitle:
                '2025 ve 2026 il / ilçe puanları — girişte yıl seçimi yapılır',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const GorevPuanlariPage(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _MenuCard(
            icon: PhosphorIconsRegular.mapTrifold,
            title: 'Zorunlu Hizmet Süreleri (EK-1)',
            subtitle:
                '5.12.2025 kararı — il / ilçe bölge ve zorunlu görev yılı',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const GorevHizmetSureleriPage(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SarkTarihCard(
            sarkTarih: sarkAsync.valueOrNull,
            onPick: () => _sarkTarihSec(context, ref),
            onClear: () => gorevPuanSarkBaslangicKaydet(ref, null),
          ),
          const SizedBox(height: 14),
          _PbsUyariKutusu(),
        ],
      ),
    );
  }

  Future<void> _sarkTarihSec(BuildContext context, WidgetRef ref) async {
    final mevcut = ref.read(gorevPuanSarkBaslangicProvider).valueOrNull;
    final picked = await showDatePicker(
      context: context,
      initialDate: mevcut ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('tr', 'TR'),
      helpText: 'Şarka başlama tarihi',
    );
    if (picked == null) return;
    await gorevPuanSarkBaslangicKaydet(ref, picked);
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PoliceColors.surfaceDark,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: PoliceColors.outlineMuted.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              PhosphorIcon(icon, color: PoliceColors.primaryBlue, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.9),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: PoliceColors.textMuted.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SarkTarihCard extends StatelessWidget {
  const _SarkTarihCard({
    required this.sarkTarih,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? sarkTarih;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final fmt = sarkTarih != null
        ? '${sarkTarih!.day.toString().padLeft(2, '0')}.'
            '${sarkTarih!.month.toString().padLeft(2, '0')}.'
            '${sarkTarih!.year}'
        : 'Henüz girilmedi';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Şarka başlama tarihi',
            style: TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'İl / ilçe puanı seçerken ve dönem hesabında bu tarih esas alınır. '
            'Şark dönemindeki görevler için cetvel yılı şark ve 01.01.2026 kesitine göre belirlenir.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.88),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            fmt,
            style: TextStyle(
              color: sarkTarih != null
                  ? PoliceColors.primaryBlue
                  : PoliceColors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onPick,
                  child: const Text('Tarih seç'),
                ),
              ),
              if (sarkTarih != null) ...[
                const SizedBox(width: 8),
                TextButton(onPressed: onClear, child: const Text('Temizle')),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PbsUyariKutusu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF3D1515).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE53935), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade300,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Dikkat',
                style: TextStyle(
                  color: Colors.red.shade200,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'PBS sisteminde gördüğünüz puan, 2025 yılında yayınlanan günlük görev '
            'puanına göre hesaplanmıştır; hesaplama 31.12.2025 öncesini baz alır.',
            style: TextStyle(
              color: PoliceColors.titleOnDark.withValues(alpha: 0.92),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            gorevPuanCetvelYilAciklama(2026),
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
