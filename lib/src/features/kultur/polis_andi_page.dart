import 'package:flutter/material.dart';

class PolisAndiPage extends StatelessWidget {
  const PolisAndiPage({super.key});

  static const _oathText = '''
Devletimin ve milletimin önünde, namusum ve şerefim üzerine and içerim ki:

• Türkiye Cumhuriyeti Anayasasına, Atatürk ilke ve inkılaplarına, anayasal düzene ve kanunlara sadakatten ayrılmayacağıma,

• Türk milletinin milli menfaatlerini, demokratik, laik ve sosyal hukuk devleti olan Türkiye Cumhuriyeti\'nin varlığını, bağımsızlığını ve ülke bütünlüğünü her şeyin üzerinde tutacağıma,

• Görevimi, tarafsızlık ve eşitlik ilkelerine uygun olarak yapacağıma,

• İnsan haklarına saygılı olacağıma,

• Görevime hiçbir etki altında kalmadan, siyasi düşünce ve inançlara karşı tarafsız davranarak, dil, ırk, cinsiyet, siyasi düşünce, felsefi inanç, din ve mezhep ayrımı yapmadan yerine getireceğime,

• Devlet sırlarını mesleğim gereği öğrendiğim kişisel ve ailevi sırları açıklamayacağıma, görevden ayrılsam bile bu sırları saklayacağıma,

• Görevimi yaparken kanunlara ve nizamlara tam riayet edeceğime,

• Her zaman halkın hizmetinde ve yardımında bulunacağıma,

• Emirlere itaat edeceğime,

Namussuz, şerefsiz bir hareketim olmayacağına, bu andımı hiçbir çıkar ve tesir altında kalmadan tam bir sadakat ve vicdani kanaatle yerine getireceğime,

Allah\'a and içerim.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Polis Andı')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _oathText.trim(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Polis andı, göreve başlarken yapılan yemin metnidir. İlgili mevzuatta düzenlenir.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
