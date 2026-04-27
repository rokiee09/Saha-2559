import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'birimler_page.dart';

/// [EGM Teşkilat Şeması](https://www.egm.gov.tr/teskilat-semasi) ile uyumlu özet hiyerarşi;
/// ayrıntılı görsel şema sitede yer alır.
class TeskilatYapisiPage extends StatelessWidget {
  const TeskilatYapisiPage({super.key});

  static const _egmSemaUrl = 'https://www.egm.gov.tr/teskilat-semasi';

  static const _basinliklarMerkez = <String>[
    'Teftiş Kurulu Başkanlığı',
    'Özel Güvenlik Denetleme Başkanlığı',
    'Hukuk Müşavirliği',
    'Özel Harekat Başkanlığı',
    'İstihbarat Başkanlığı',
    'Trafik Başkanlığı',
    'KOM Başkanlığı',
    'Personel Başkanlığı',
    'Cumhurbaşkanlığı Koruma Başkanlığı',
    'Narkotik Suçlarla Mücadele Başkanlığı',
  ];

  Future<void> _openEgm(BuildContext context) async {
    final u = Uri.parse(_egmSemaUrl);
    if (!context.mounted) return;
    final ok = await launchUrl(u, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bağlantı açılamadı.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Teşkilat şeması')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Emniyet Genel Müdürlüğü, İçişleri Bakanlığına bağlı genel müdürlük düzeyinde örgütlenir. '
              'Aşağıdaki hiyerarşi, EGM web sitesindeki teşkilat şeması ve “Birimlerimiz” bölümündeki yapıya göre özetlenmiştir. '
              'Güncel görev dağılımı ve görsel organigram için resmî sayfayı açın.',
              style: tt.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () => _openEgm(context),
              icon: const Icon(Icons.open_in_new, size: 20),
              label: const Text('Resmî teşkilat şeması (egm.gov.tr)'),
            ),
            const SizedBox(height: 20),
            _SchemaBlock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SchemaLine(
                    color: cs.primary,
                    child: Text(
                      'T.C. İçişleri Bakanlığı',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  _SchemaLine(
                    color: cs.primary,
                    isLast: false,
                    child: _SchemaSubLine(
                      color: cs.primary,
                      child: Text(
                        'Emniyet Genel Müdürlüğü',
                        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const _SectionHeader('Merkez teşkilat (özet)'),
            const SizedBox(height: 6),
            _SchemaBlock(
              child: Column(
                children: [
                  const _SchemaItem(
                    label:
                        'Emniyet Genel Müdürü; genel müdür yardımcılıkları (koordinasyon ve denetim)',
                  ),
                  const _SchemaItem(
                    label: 'Başkanlıklar (EGM sitede listelenen sıra)',
                  ),
                  ..._basinliklarMerkez.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: tt.bodySmall?.copyWith(color: cs.primary)),
                          Expanded(
                            child: Text(b, style: tt.bodySmall?.copyWith(height: 1.35)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _SchemaItem(
                    label:
                        'Daire Başkanlıkları: politika, operasyonel destek ve idari hizmet birimleri (ayrıntılı liste aşağıdaki ekrana bakın).',
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const BirimlerPage()),
                        );
                      },
                      icon: const Icon(Icons.apartment_outlined, size: 20),
                      label: const Text('Daire Başkanlıkları listesi'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _SectionHeader('Taşra teşkilatı'),
            const SizedBox(height: 6),
            const _SchemaBlock(
              child: _SchemaItem(
                label:
                    'İl emniyet müdürlükleri, ilçe emniyet müdürlükleri ve ihtiyaca göre şube, karakol ve diğer birimler. '
                    'Kurum içi hiyerarşi ve sorumluluk alanları illerde farklılık gösterebilir; güncel yapı EGM teşkilat şeması ve il yönetmeliklerine tabidir.',
              ),
            ),
            const SizedBox(height: 16),
            const _SectionHeader('Eğitim ve diğer'),
            const SizedBox(height: 6),
            const _SchemaBlock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SchemaItem(
                    label:
                        'Eğitim birimleri: Polis Akademisi Başkanlığı, polis meslek eğitim merkezleri, meslek yüksekokulları ve hizmet içi eğitim yapıları (EGM, Eğitim Birimleri).',
                  ),
                  SizedBox(height: 8),
                  _SchemaItem(
                    label: 'Diğer birimler: yardımcı hizmetler, özel görev kapsamındaki birimler ve yönergeyle tanımlanan diğer yapılar.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SchemaBlock(
              child: _SchemaItem(
                label:
                    'Dayanak: 3201 sayılı Emniyet Teşkilatı Kanunu, 2559 sayılı Polis Vazife ve Salahiyet Kanunu ve ilgili mevzuat. Teşkilat ayrıntıları resmî kaynaklara göre güncellenir.',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Kaynak: Emniyet Genel Müdürlüğü — Teşkilat şeması ($_egmSemaUrl)',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}

class _SchemaBlock extends StatelessWidget {
  const _SchemaBlock({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: c.outline.withValues(alpha: 0.5), width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 2, 0, 2),
        child: child,
      ),
    );
  }
}

class _SchemaLine extends StatelessWidget {
  const _SchemaLine({
    required this.color,
    required this.child,
    this.isLast = true,
  });

  final Color color;
  final Widget child;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              Container(width: 2, height: 10, color: color.withValues(alpha: 0.6)),
              if (!isLast) Container(width: 2, height: 18, color: color.withValues(alpha: 0.45)),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(child: child),
      ],
    );
  }
}

class _SchemaSubLine extends StatelessWidget {
  const _SchemaSubLine({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 14,
            height: 2,
            color: color.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(child: child),
      ],
    );
  }
}

class _SchemaItem extends StatelessWidget {
  const _SchemaItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
    );
  }
}
