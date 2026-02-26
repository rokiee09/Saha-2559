import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/martyr.dart';
import 'martyrs_controller.dart';
import 'martyr_detail_page.dart';

class MartyrsPage extends ConsumerWidget {
  const MartyrsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final martyrsAsync = ref.watch(martyrsFilteredProvider);
    final citiesAsync = ref.watch(martyrCitiesProvider);
    final selectedCity = ref.watch(martyrCityFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Şehitler')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
    final dateText = martyr.dateOfMartyrdom != null
        ? martyr.dateOfMartyrdom!
            .toLocal()
            .toIso8601String()
            .split("T")
            .first
        : null;

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
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          title: Text(martyr.fullName),
          subtitle: Text(
            [
              martyr.cityName,
              if (dateText != null) dateText,
            ].join(' • '),
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

