import 'package:flutter/material.dart';

import 'rutbe_teskilat_page.dart';

class KariyerRehberiPage extends StatelessWidget {
  const KariyerRehberiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rütbe & Kariyer Rehberi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              context,
              'Terfi Şartları',
              '• Kıdem: Belirli süre görevde bulunma şartı (yönetmelikle belirlenir).\n'
              '• Eğitim: Hizmet içi eğitim ve kurs tamamlama.\n'
              '• Sınav: Komiser yardımcılığı ve üstü rütbeler için merkezi veya kurum sınavı.\n'
              '• Değerlendirme: Disiplin durumu, başarı ve sicil.\n'
              '• Kontenjan: Terfi için açık kadro ve bütçe imkânı gerekir.\n\n'
              'Polis memurundan komiser yardımcılığına geçiş sınavla; üst rütbelere terfi kıdem, sınav ve değerlendirme ile yapılır. Detaylar İçişleri Bakanlığı ve EGM mevzuatında yer alır.',
            ),
            _section(
              context,
              'Sınav Sistemi',
              '• Komiser Yardımcılığı: Merkezi KPSS veya kurum sınavı, mülakat. Lisans mezuniyeti şartı aranabilir.\n'
              '• Polis Memuru Alımı: ÖSYM veya EGM duyuruları; yazılı sınav, fizikî yeterlilik, mülakat, sağlık raporu.\n'
              '• Uzmanlık Sınavları: Kriminal, trafik, siber vb. branşlar için ayrı sınavlar açılabilir.\n'
              '• Yükselme Sınavları: Kıdemli memur, çavuş, şef geçişleri için yönetmelikte belirtilen sınav ve şartlar uygulanır.\n\n'
              'Sınav tarihleri ve şartları Resmî Gazete ve EGM / İçişleri Bakanlığı internet sitelerinden duyurulur.',
            ),
            _section(
              context,
              'Branş ve Birimler (EGM)',
              'Aşağıda Emniyet Genel Müdürlüğü merkez teşkilatındaki daire başkanlıkları ve başkanlıkların tam listesi yer alır. '
              'Branş atamaları sınav, tercih ve kurum ihtiyacına göre yapılır.\n',
            ),
            _subsection(context, 'Daire Başkanlıkları',
              '• Asayiş Daire Başkanlığı: Genel asayiş, olay yeri, şikâyet, suç önleme.\n'
              '• Terörle Mücadele Dairesi Başkanlığı (TEM): Terörle mücadele, operasyon planlama.\n'
              '• Kriminal Daire Başkanlığı: Olay yeri inceleme, laboratuvar, suç analizi, delil.\n'
              '• Siber Suçlarla Mücadele Daire Başkanlığı: Siber suçlar, dijital delil, siber istihbarat.\n'
              '• Güvenlik Daire Başkanlığı: Özel güvenlik, kritik tesisler, olay yönetimi.\n'
              '• Koruma Daire Başkanlığı: Kişi ve tesis koruma (Cumhurbaşkanlığı dışındaki koruma görevleri).\n'
              '• TBMM Koruma Dairesi Başkanlığı: TBMM ve milletvekili koruma.\n'
              '• Tanık Koruma Dairesi Başkanlığı: Tanık ve mağdur koruma programları.\n'
              '• Göçmen Kaçakçılığıyla Mücadele ve Hudut Kapıları Daire Başkanlığı: Sınır, göç, kaçakçılık.\n'
              '• Dış İlişkiler Daire Başkanlığı: Uluslararası iş birliği, protokol.\n'
              '• İnterpol-Europol Daire Başkanlığı: İnterpol ve Europol iletişimi.\n'
              '• Bilgi Teknolojileri ve Haberleşme Daire Başkanlığı: Bilişim altyapısı, haberleşme.\n'
              '• Belge Yönetimi ve Koordinasyon Daire Başkanlığı: Arşiv, evrak, koordinasyon.\n'
              '• Strateji Geliştirme Daire Başkanlığı: Strateji, performans, bütçe.\n'
              '• Personel Başkanlığı (bağlı): Personel, atama, eğitim, özlük.\n'
              '• Destek Hizmetleri Daire Başkanlığı: Lojistik, satın alma, taşıma.\n'
              '• İnşaat Emlak Daire Başkanlığı: Bina, arsa, tadilat.\n'
              '• Havacılık Daire Başkanlığı: Polis havacılık, helikopter, uçuş.\n'
              '• Sosyal Hizmetler ve Sağlık Daire Başkanlığı: Personel sağlığı, sosyal destek.\n'
              '• Medya-Halkla İlişkiler ve Protokol Daire Başkanlığı: Basın, halkla ilişkiler, protokol.\n',
            ),
            _subsection(context, 'Başkanlıklar ve Diğer Birimler',
              '• Trafik Başkanlığı: Trafik düzeni, kaza, ceza, tescil, denetim.\n'
              '• Narkotik Suçlarla Mücadele Başkanlığı: Uyuşturucu ve uyarıcı maddelerle mücadele.\n'
              '• Kaçakçılık ve Organize Suçlarla Mücadele Başkanlığı (KOM): Kaçakçılık, organize suç, mali suç.\n'
              '• İstihbarat Başkanlığı: İstihbarat toplama, analiz, değerlendirme.\n'
              '• Özel Harekat Başkanlığı: Özel operasyon, kriz müdahale, yüksek risk görevleri.\n'
              '• Cumhurbaşkanlığı Koruma Başkanlığı: Cumhurbaşkanı ve ailesi koruma.\n'
              '• Özel Güvenlik Denetleme Başkanlığı: Özel güvenlik izin, denetim, ruhsat.\n'
              '• Teftiş Kurulu Başkanlığı: İç denetim, teftiş, soruşturma.\n'
              '• Hukuk Müşavirliği: Hukuki danışmanlık, dava takibi.\n\n'
              'İl ve ilçe emniyet müdürlüklerinde asayiş, trafik, kriminal, TEM, narkotik, KOM, siber, çocuk, pasaport/yabancılar vb. şube ve birimler bulunur; yapı il ve büyüklüğe göre değişir.',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RutbeTeskilatPage(),
                  ),
                );
              },
              icon: const Icon(Icons.badge),
              label: const Text('Rütbe ve Teşkilat Yapısı'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _subsection(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
