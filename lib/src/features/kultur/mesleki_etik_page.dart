import 'package:flutter/material.dart';

class _Value {
  final String title;
  final String description;
  _Value(this.title, this.description);
}

class MeslekiEtikPage extends StatelessWidget {
  const MeslekiEtikPage({super.key});

  static final List<_Value> _values = [
    _Value(
      'Vatanseverlik',
      'Ülkeye ve millete bağlılık, görev bilinci polislik mesleğinin temelidir. Polis, Anayasa ve kanunlara bağlı kalarak vatandaşın can, mal ve özgürlük güvenliğini korumakla yükümlüdür. Vatanseverlik; görevi kişisel çıkar, siyaset veya etnik/dini ayrım gözetmeden, sadece hukuk ve kamu düzeni adına yerine getirmeyi gerektirir.',
    ),
    _Value(
      'Dürüstlük',
      'Doğruluk, şeffaflık ve güvenilirlik hem sahada hem büroda esastır. Tutanak, rapor ve ifadelerde gerçeğe sadakat şarttır; delil karartma, yalan ifade veya belgede sahtecilik meslek onuruna aykırıdır. Vatandaşa ve amire karşı dürüst davranmak, polisin toplumdaki güvenin temelidir.',
    ),
    _Value(
      'Adalet',
      'Hukuka saygı, eşitlik ve hakkaniyet polisin her davranışında rehber olmalıdır. Herkese kanun önünde eşit muamele; dil, din, ırk, cinsiyet veya siyasi görüşe göre ayrım yapılmaması gerekir. Adalet, sadece suçlunun cezalandırılması değil, masumun korunması ve hakların çiğnenmemesidir.',
    ),
    _Value(
      'Cesaret',
      'Zorluklar karşısında kararlılık ve özveri; görev uğruna riski göze almak, ancak kanun ve orantılılık sınırları içinde hareket etmek. Cesaret, gerektiğinde tehlikeye müdahale etmek kadar, haksız emre itaat etmemek ve hukuka aykırılığı üst makama bildirmektir.',
    ),
    _Value(
      'Mesleki Etik ve Ahlak',
      'Meslek ahlakı ve sorumluluk bilinci; rüşvet, kayırmacılık, görevi kötüye kullanma ve menfaat karşılığı taviz kabul edilemez. Özel hayatta da polis kimliğine yakışır davranmak, sosyal medyada ve toplum içinde mesleğin saygınlığını korumak gerekir. Disiplin ve ceza hukuku bu ilkeleri destekler.',
    ),
    _Value(
      'Takım Ruhu ve Dayanışma',
      'Birlik, dayanışma ve iş birliği sahada can güvenliği ve görev başarısı için zorunludur. Ekip çalışması, amir–ast uyumu ve birimler arası koordinasyon; bilgi ve deneyim paylaşımı mesleki gelişimi artırır. Bireysel kahramanlık değil, ekip disiplini ve karşılıklı güven esastır.',
    ),
    _Value(
      'İnsan Onuru ve İnsan Hakları',
      'Görev icabı zor kullanım veya yakalama olsa bile, kişinin insan onuruna saygı gösterilir. İşkence, kötü muamele, aşağılama veya orantısız güç kullanımı kesinlikle yasaktır. CMK, PVSK ve Anayasa çerçevesinde her bireyin temel hakları polis tarafından korunmalıdır.',
    ),
    _Value(
      'Gizlilik ve Sır Saklama',
      'Görev sırasında öğrenilen bilgi, ifade ve kişisel veriler sır olarak saklanır. Yetkisiz kişi veya kurumlara bilgi verilmez; sosyal medya veya özel sohbetlerde olay/mağdur/şüpheli detayları paylaşılmaz. KVKK ve ilgili mevzuat bu yükümlülüğü düzenler.',
    ),
  ];

  static const String _intro =
      'Polislik mesleği, toplumun güvenliği ve hukukun üstünlüğü için gerekli temel değerler üzerine kuruludur. '
      'Aşağıdaki ilkeler hem eğitimde hem sahada rehber niteliğindedir; 657 sayılı DMK, 2559 sayılı PVSK ve Emniyet Teşkilatı etik davranış rehberleriyle uyumludur.';

  static const String _principlesTitle = 'Görevde Uyulacak Temel Kurallar';
  static const String _principlesBody =
      '• Kanun ve mevzuata bağlı kalınır; yetki sınırları aşılmaz.\n'
      '• Amirlerin meşru emirleri yerine getirilir; hukuka aykırı emir verilmez, verilirse yerine getirilmez ve üst makama bildirilir.\n'
      '• Tutanak ve raporlar eksiksiz, doğru ve zamanında düzenlenir.\n'
      '• Rüşvet, hediye (görevi etkileyebilecek nitelikte) ve kayırmacılık kabul edilmez.\n'
      '• Görevde siyasi veya kişisel propaganda yapılmaz; tarafsızlık korunur.\n'
      '• Zor kullanımı ve silah kullanımı yalnızca kanunda öngörülen hallerde ve orantılı biçimde uygulanır.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mesleki Etik & Değerler')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_intro, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Text(
              'Temel Değerler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ..._values.map(
              (v) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        v.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _principlesTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _principlesBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
