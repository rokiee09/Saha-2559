import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/theme/police_colors.dart';
import '../../data/models/city_contact.dart';
import 'city_contacts_controller.dart';

void _showCityContactDetail(BuildContext context, CityContact city) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: PoliceColors.surfaceDark,
      title: Text(
        city.cityName,
        style: const TextStyle(color: PoliceColors.titleOnDark),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (city.directorName != null && city.directorName!.trim().isNotEmpty) ...[
              Text(
                city.directorName!,
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (city.address != null && city.address!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Adres: ${city.address}',
                  style: const TextStyle(color: PoliceColors.textMuted),
                ),
              ),
            Text(
              'Telefon: ${city.phone}',
              style: const TextStyle(color: PoliceColors.textMuted),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Kapat'),
        ),
        if (city.sourceUrl != null && city.sourceUrl!.trim().isNotEmpty)
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openSourceUrl(city.sourceUrl!);
            },
            child: const Text('Kaynak'),
          ),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            callPhone(city.phone, context: context);
          },
          child: const Text('Ara'),
        ),
      ],
    ),
  );
}

class ContactsPage extends ConsumerWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(cityContactsProvider);
    final platesAsync = ref.watch(cityContactPlateCodesProvider);

    Future<void> reload() async {
      ref.invalidate(cityContactsProvider);
      ref.invalidate(cityContactPlateCodesProvider);
      await ref.read(cityContactsProvider.future);
    }

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: contactsAsync.maybeWhen(
          data: (c) => Text('İl Emniyet Müdürlükleri (${c.length})'),
          orElse: () => const Text('İl Emniyet Müdürlükleri'),
        ),
      ),
      body: contactsAsync.when(
        data: (cities) {
          if (cities.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'İl listesi yüklenemedi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: PoliceColors.titleOnDark),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: reload,
                      child: const Text('Yeniden dene'),
                    ),
                  ],
                ),
              ),
            );
          }
          final plates = platesAsync.valueOrNull ?? const {};
          return RefreshIndicator(
            onRefresh: reload,
            color: PoliceColors.primaryBlue,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                final plate = plates[city.cityName];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: PoliceColors.surfaceDark,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _showCityContactDetail(context, city),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (plate != null && plate.isNotEmpty)
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: PoliceColors.primaryBlue
                                      .withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: PoliceColors.primaryBlue
                                        .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  plate,
                                  style: const TextStyle(
                                    color: PoliceColors.primaryBlue,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            if (plate != null && plate.isNotEmpty)
                              const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    city.cityName,
                                    style: const TextStyle(
                                      color: PoliceColors.titleOnDark,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (city.address != null &&
                                      city.address!.trim().isNotEmpty)
                                    Text(
                                      city.address!,
                                      style: TextStyle(
                                        color: PoliceColors.textMuted
                                            .withValues(alpha: 0.95),
                                        height: 1.35,
                                        fontSize: 13,
                                      ),
                                    )
                                  else
                                    Text(
                                      'Adres kayıtta yok',
                                      style: TextStyle(
                                        color: PoliceColors.textMuted
                                            .withValues(alpha: 0.65),
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12,
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                  Text(
                                    city.phone,
                                    style: const TextStyle(
                                      color: PoliceColors.primaryBlue,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  if (city.directorName != null &&
                                      city.directorName!.trim().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        city.directorName!,
                                        style: TextStyle(
                                          color: PoliceColors.textMuted
                                              .withValues(alpha: 0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Ara',
                              icon: const Icon(
                                Icons.call_outlined,
                                color: PoliceColors.textMuted,
                              ),
                              onPressed: () =>
                                  callPhone(city.phone, context: context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Liste yüklenirken hata oluştu.',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$e',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: reload,
                  child: const Text('Yeniden dene'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
