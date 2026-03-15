import 'package:flutter/material.dart';

class BirimlerPage extends StatelessWidget {
  const BirimlerPage({super.key});

  static const List<(String, String)> _units = [
    (
      'Asayiş',
      'Genel asayiş hizmetleri, kamu düzeninin korunması ve genel güvenlik faaliyetleri.',
    ),
    (
      'Trafik',
      'Karayolu trafik hizmetleri, trafik güvenliği ve trafikle ilgili idari işlemler.',
    ),
    (
      'Narkotik Suçlarla Mücadele',
      'Uyuşturucu ve uyarıcı maddelerle ilgili suçlarla mücadeleye yönelik çalışmalar.',
    ),
    (
      'Kaçakçılık ve Organize Suçlarla Mücadele',
      'Kaçakçılık, mali suçlar ve organize suç yapılarıyla ilgili birim faaliyetleri.',
    ),
    (
      'Terörle Mücadele',
      'Terör suçlarıyla ilgili kurumsal görev alanında yürütülen faaliyetler.',
    ),
    (
      'İstihbarat',
      'Kurumsal istihbarat toplama, değerlendirme ve raporlama süreçleri.',
    ),
    (
      'Kriminal',
      'Kriminal inceleme, laboratuvar ve teknik analiz hizmetleri.',
    ),
    (
      'Siber Suçlarla Mücadele',
      'Bilişim sistemleri üzerinden işlenen suçlara ilişkin çalışmalar.',
    ),
    (
      'Özel Harekat',
      'Emniyet teşkilatı bünyesindeki özel görev birimleri hakkında genel kurumsal bilgi.',
    ),
    (
      'Koruma',
      'Kişi koruma ve koruma hizmetleriyle ilgili kurumsal yapı.',
    ),
    (
      'Personel',
      'Atama, özlük, sicil ve personel işlemlerinin yürütüldüğü birimler.',
    ),
    (
      'Eğitim',
      'Mesleki eğitim, hizmet içi eğitim ve akademik gelişim alanındaki birimler.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Birimler')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Emniyet teşkilatı merkez ve taşra yapısında farklı hizmet alanlarına ayrılan birimlerden oluşur.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ..._units.map(
            (unit) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  unit.$1,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(unit.$2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
