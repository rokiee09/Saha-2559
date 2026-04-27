import 'package:flutter/material.dart';

import '../../common/widgets/police_filigran_layer.dart';

class PolisAndiPage extends StatelessWidget {
  const PolisAndiPage({super.key});

  static const _oathText = '''
Türkiye Cumhuriyeti Anayasasına, Atatürk ilke ve inkılâplarına, anayasada ifadesi bulunan Türk bayrağının altındaki şerefli Türk polisine, Türkiye Cumhuriyeti Devletine ve Türk milletine sadakatle bağlı kalacağıma, polislik mesleğinin onuruna ve polislik mesleğinin gerektirdiği tüm yükümlülüklere uygun hareket edeceğime, polislik mesleğini icra ederken kanunların bana verdiği yetkileri, vatandaşların huzuru, devletin güvenliği için, hiçbir etki altında kalmadan, adaletle, dürüstlükle ve objektiflikle kullanacağıma, namusum ve şerefim üzerine ant içerim
''';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Polis Andı')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PoliceFiligranLayer(),
          ColoredBox(color: cs.surface.withValues(alpha: 0.88)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    Text(
                      'Polis Andı',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _oathText.trim(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            color: cs.onSurface,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Göreve başlarken okunan and metnidir. Yürürlükteki düzenlemelerde değişiklik olması halinde resmî kaynak esas alınmalıdır.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
