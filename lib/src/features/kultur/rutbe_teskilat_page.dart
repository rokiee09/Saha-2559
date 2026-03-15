import 'package:flutter/material.dart';

class RutbeTeskilatPage extends StatelessWidget {
  const RutbeTeskilatPage({super.key});

  /// EGM resmî rütbe sırası (alttan üste).
  static final _ranks = [
    _RankItem('Polis Memuru', 'Emniyet teşkilatındaki temel rütbe.', 1),
    _RankItem('Başpolis Memuru', 'Polis memurluğunun üst kademelerinden biridir.', 2),
    _RankItem('Kıdemli Başpolis Memuru', 'Kıdeme dayalı üst rütbe basamaklarından biridir.', 3),
    _RankItem('Komiser Yardımcısı', 'Amirlik sınıfına geçişte ilk rütbe basamaklarındandır.', 4),
    _RankItem('Komiser', 'Amir sınıfındaki temel rütbelerden biridir.', 5),
    _RankItem('Başkomiser', 'Amir sınıfında daha üst düzey rütbedir.', 6),
    _RankItem('Emniyet Amiri', 'Yönetim ve koordinasyon kademelerinden biridir.', 7),
    _RankItem('4. Sınıf Emniyet Müdürü', 'Emniyet müdürlüğü sınıfının giriş basamaklarındandır.', 8),
    _RankItem('3. Sınıf Emniyet Müdürü', 'Emniyet müdürlüğü sınıfının orta kademelerindendir.', 9),
    _RankItem('2. Sınıf Emniyet Müdürü', 'Üst düzey yönetim kademelerinden biridir.', 10),
    _RankItem('1. Sınıf Emniyet Müdürü', 'Emniyet müdürlüğü sınıfının en üst basamaklarındandır.', 11),
    _RankItem('Emniyet Genel Müdürü', 'Derece üstü. Teşkilatın en üst amiri.', 12),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rütbeler')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emniyet teşkilatındaki rütbeler kurumsal hiyerarşiyi ve meslek içi derece yapısını gösterir.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Rütbeler (alttan üste)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ..._ranks.map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        '${r.order}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      r.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(r.description),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _RankItem {
  final String title;
  final String description;
  final int order;
  _RankItem(this.title, this.description, this.order);
}
