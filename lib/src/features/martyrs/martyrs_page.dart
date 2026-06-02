import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/theme/police_colors.dart';
import '../../common/widgets/turkish_flag_circle_icon.dart';
import '../../data/models/martyr.dart';
import 'martyrs_anniversary.dart';
import 'martyrs_controller.dart';
import 'martyr_detail_page.dart';
import 'widgets/sehit_devriye_kayar_bant.dart';

class MartyrsPage extends ConsumerWidget {
  const MartyrsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final martyrsAsync = ref.watch(martyrsFilteredProvider);
    final citiesAsync = ref.watch(martyrCitiesProvider);
    final selectedCity = ref.watch(martyrCityFilterProvider);
    final anniversaryOnly = ref.watch(martyrsAnniversaryFilterProvider);
    final todayAsync = ref.watch(martyrsAnniversaryTodayProvider);

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: martyrsAsync.maybeWhen(
          data: (items) => Text(
            anniversaryOnly
                ? 'Yıldönümü devriyesi (${items.length})'
                : 'Şehitlerimiz (${items.length})',
          ),
          orElse: () => const Text('Şehitlerimiz'),
        ),
        actions: [
          if (anniversaryOnly)
            IconButton(
              tooltip: 'Tüm şehitler',
              onPressed: () {
                ref.read(martyrsAnniversaryFilterProvider.notifier).state =
                    false;
              },
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primaryContainer
                  .withValues(alpha: 0.4),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Kahramanlar can verir, yurdu yaşatmak için.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Nihal Atsız',
                      textAlign: TextAlign.end,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          todayAsync.when(
            data: (today) {
              if (today.martyrs.isEmpty) return const SizedBox.shrink();
              final marquee = buildSehitDevriyeMarqueeText(today.martyrs);
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Card(
                  color: PoliceColors.surfaceDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: PoliceColors.sehitAccent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Bugün — ${formatAnniversaryGunLabel(today.gun)}',
                          style: const TextStyle(
                            color: PoliceColors.gold,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          martyrAnniversarySubtitle(today.martyrs, today.gun),
                          style: TextStyle(
                            color: PoliceColors.textMuted.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SehitDevriyeKayarBant(text: marquee, height: 44),
                        const SizedBox(height: 8),
                        Text(
                          sehitDevriyeKapanis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: PoliceColors.gold.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        if (!anniversaryOnly) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ref
                                    .read(martyrsAnniversaryFilterProvider
                                        .notifier)
                                    .state = true;
                              },
                              child: const Text('Yalnızca bugünkü yıldönümü'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Text(
                  'Ad, ünvan, şehit olma tarihi ve (varsa) il alanları uygulama verisinde tutulur. '
                  'Son dönem kayıtları, isim ve tarih bakımından egm.gov.tr üzerindeki “Şehitlerimiz” listesiyle eşleştirilmiştir; '
                  'o sayfada il ayrıntısı olmayan girdilerde il alanı “Belirtilmedi” olabilir. '
                  'Güncel ve tam resmî bilgi için https://www.egm.gov.tr/sehitlerimiz adresini esas alınız.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          if (!anniversaryOnly)
            Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: citiesAsync.when(
                    data: (cities) {
                      return DropdownButtonFormField<String>(
                        value: selectedCity,
                        decoration: const InputDecoration(
                          labelText: 'İl filtresi',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tümü'),
                          ),
                          ...cities.map(
                            (c) => DropdownMenuItem<String>(
                              value: c,
                              child: Text(c),
                            ),
                          ),
                        ],
                        onChanged: (value) => ref
                            .read(martyrCityFilterProvider.notifier)
                            .state = value,
                      );
                    },
                    loading: () => const SizedBox(
                      height: 48,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Text('Hata: $e'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'İsim ara',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) => ref
                        .read(martyrNameQueryProvider.notifier)
                        .state = value,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: martyrsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text('Henüz kayıtlı şehit bilgisi yok.'),
                  );
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final martyr = items[index];
                    return _MartyrListItem(
                      martyr: martyr,
                      index: index,
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Hata: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _MartyrListItem extends StatelessWidget {
  final Martyr martyr;
  final int index;

  const _MartyrListItem({required this.martyr, required this.index});

  @override
  Widget build(BuildContext context) {
    final dateText = formatMartyrDate(martyr.dateOfMartyrdom);
    final cityLabel = martyr.cityName.trim().isEmpty ||
            martyr.cityName.toLowerCase() == 'belirtilmedi'
        ? null
        : martyr.cityName;
    final subtitle = [
      if (cityLabel != null) cityLabel,
      if (martyr.dateOfMartyrdom != null) dateText,
    ].join(' • ');

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 40)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        color: PoliceColors.surfaceDark,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: const TurkishFlagAssetCircleIcon(size: 44),
          title: Text(
            martyr.fullName,
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: subtitle.isEmpty
              ? null
              : Text(
                  subtitle,
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.95),
                  ),
                ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MartyrDetailPage(martyrId: martyr.id),
              ),
            );
          },
        ),
      ),
    );
  }
}

