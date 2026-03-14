import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/widgets/primary_card.dart';
import 'law_management_controller.dart';
import 'law_article_list_page.dart';
import 'law_article_form_page.dart';

class LawManagementPage extends ConsumerWidget {
  const LawManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lawsAsync = ref.watch(lawsGroupedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kanun Yönetimi')),
      body: lawsAsync.when(
        data: (laws) {
          if (laws.isEmpty) {
            return const Center(
              child: Text(
                'Henüz kanun eklenmemiş.\n"Yeni madde" ile ilk maddeyi ekleyebilirsiniz.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: laws.length,
            itemBuilder: (context, index) {
              final law = laws[index];
              return PrimaryCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LawArticleListPage(
                        lawCode: law.lawCode,
                        lawName: law.lawName,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(
                    law.lawName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${law.lawCode} · ${law.count} madde'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const LawArticleFormPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni madde'),
      ),
    );
  }
}
