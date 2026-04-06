import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/city_contact.dart';
import 'city_contacts_controller.dart';

void _showCityContactDetail(BuildContext context, CityContact city) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(city.cityName),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (city.directorName != null && city.directorName!.trim().isNotEmpty) ...[
              Text(
                city.directorName!,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
            ],
            Text('Telefon: ${city.phone}'),
            if (city.address != null && city.address!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Adres: ${city.address}'),
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
            callPhone(city.phone);
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

    return Scaffold(
      appBar: AppBar(title: const Text('İl Emniyet Müdürlükleri')),
      body: contactsAsync.when(
        data: (cities) {
          if (cities.isEmpty) {
            return const Center(
              child: Text('Henüz kayıtlı il bilgisi yok.'),
            );
          }
          return ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(city.cityName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(city.phone),
                      if (city.directorName != null &&
                          city.directorName!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            city.directorName!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (city.address != null && city.address!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            city.address!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  isThreeLine: (city.address != null &&
                          city.address!.isNotEmpty) ||
                      (city.directorName != null &&
                          city.directorName!.trim().isNotEmpty),
                  trailing: IconButton(
                    icon: const Icon(Icons.call),
                    onPressed: () => callPhone(city.phone),
                  ),
                  onTap: () => _showCityContactDetail(context, city),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}

