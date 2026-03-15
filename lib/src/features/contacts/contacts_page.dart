import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'city_contacts_controller.dart';

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
                  isThreeLine: city.address != null && city.address!.isNotEmpty,
                  trailing: IconButton(
                    icon: const Icon(Icons.call),
                    onPressed: () => callPhone(city.phone),
                  ),
                  onTap: () {
                    if (city.sourceUrl != null &&
                        city.sourceUrl!.trim().isNotEmpty) {
                      openSourceUrl(city.sourceUrl!);
                    }
                  },
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

