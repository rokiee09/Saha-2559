import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/map/turkey_map_widget.dart';
import 'city_contacts_controller.dart';

/// İl emniyet aramaları bilgilendirme amaçlıdır; tıklanan ilin tanıtım hattı açılır.
class TurkeyMapPage extends ConsumerWidget {
  const TurkeyMapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(cityContactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İl Emniyet (Harita)'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Bilgilendirme amaçlıdır. Haritada iller path id (TR34, TR06, …) ile tanımlıdır. '
                'Numara önce Isar’daki il listesinden, yoksa city_contacts.json (plateCode) kullanılır.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            Expanded(
              child: contactsAsync.when(
                data: (cities) => TurkeyMapWidget(
                  showSnackBarOnTap: true,
                  cityContacts: cities,
                ),
                loading: () => const TurkeyMapWidget(
                  showSnackBarOnTap: true,
                  cityContacts: null,
                ),
                error: (_, __) => const TurkeyMapWidget(
                  showSnackBarOnTap: true,
                  cityContacts: null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
