import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/widgets/ataturk_portrait_hero.dart';

/// Metin: [EGM – Atatürk ve Türk Polisi](https://www.egm.gov.tr/ataturk-ve-turk-polisi)
class AtaturkVeTurkPolisiPage extends StatelessWidget {
  const AtaturkVeTurkPolisiPage({super.key});

  static const _ataturkImage = 'assets/images/ataturk_matem.jpg';
  static const _egmUrl = 'https://www.egm.gov.tr/ataturk-ve-turk-polisi';

  static const _paragraflar = <String>[
    "Cumhuriyetin 10'uncu kuruluş yıldönümünde yapılan görkemli törenlere katılmak üzere İstanbul Emniyet Müdürlüğünce 100 kişilik bir polis birliği hazırlandı. Emniyet Müdürü Ekrem Şerif beyin büyük bir emek ve çaba harcayarak törene hazır hale getirdiği bu nadide birlik Ankara'daki kutlamalara katıldı. Özel olarak hazırlanan bu polis birliği 29 Ekim 1933 tarihinde yapılan resmi geçitte tüm seyredenler gibi Mustafa Kemal Atatürk'ün de takdir ve hayranlığını kazandı.",
    'Büyük Gazi; o gün Polis ve Jandarma birlikleri hakkındaki takdir ve övgülerini açıkladı. "Dün sizin hali tavrınızda..." diye başlayan bu söylemdeki "dün" her gün olabilirdi. Bu söylem polis için bir övünç vesilesi idi.',
    "Atatürk'ün bu övünç ve takdir dolu sözleri söylemesi söylenmek için söylenmemişti. Dünya siyasetinin yetiştirdiği en büyük şahsiyetlerden ilki olan Önder Polis ve Jandarma teşkilatlarının ülkenin olmazsa olmazlarından olduğunu çok iyi biliyordu. Bundan dolayı da her iki teşkilatın; bilhassa Polis Teşkilatının çağdaş yöntemlerle idare edilmesini ve çağdaş bilgilerle donanmış polislerle yenileştirilmesini istiyordu. Bu amaçla Çankaya köşkünde bir akşam toplantısı tertip ederek yönetici ve bilim adamlarının konu ile ilgili görüşlerini almak istedi. Çağdaş polislerin yetiştirilmesi için yeni polis okullarının açılmasına ve polis amirlerinin iyi bir eğitim veren bir okulda yetiştirilmeleri fikrine ilk tepki İçişleri Bakanından geldi. Ancak İçişleri Bakanının tepkisi bu uygulamaya gerek olmadığı savıyla değil ekonomik sebeplerden dolayı \"Polise mahsus ilk orta ve yüksek öğretim kurumlarının oluşturulması ve illerde teknik bürolar ve sosyal tesisler açılması bu fakir bütçemizle şimdilik mümkün değildir bir müddet daha alışıla gelmiş şekilde polis memuru alımına devam etmekte yarar vardır\" şeklinde oldu. Toplantıya katılanların çoğunluğu da bu düşünceye katıldılar.",
    "Alışıla gelmiş usul; diğer bazı devlet dairelerinde de olduğu gibi o zamanki Ankara'nın meşhur 'İtfaiye Meydanı' ve etrafındaki kahvehane ve hanlardan memur adayı toplanırdı. Memur olma niteliklerine sahip olanlar burada bulunur ve herhangi bir memurluk talebi için beklerlerdi. O zamanki şartlarda memur olabilmenin niteliği ilkokul mezunu veya okur-yazar olmak askerliğini yapmış olmak ve herhangi bir sakatlığı bulunmamaktı. Polis olmak içinse bunlara ilaveten gösterişli olmak da gerekiyordu. Polis aday adayı eğer siyasi polis olarak görevlendirilecek ise yüzünde şark çıbanı izlerinin bulunmaması önem arz ediyordu.",
    "İçişleri Bakanının ekonomist düşünceyle ortaya sürdüğü haklı gerekçelerin diğer katılımcılar tarafından da kabul görmesine karşılık Atatürk polisin eğitilmesi konusunda çok kararlıydı. Ona göre; Ülkenin iç güvenliğinin huzur ve asayişinin sağlanması ve bunun devamlılık arz etmesi çok önemli idi.",
    "İçişleri Bakanından polis aday adaylarını nasıl seçtiğini sordu. Polis aday adaylarını seçme yöntemini öğrendikten sonra davetlilerden de başkaca bir öneri gelmemesi üzerine Atatürk yaverini çağırttı. \"İtfaiye meydanında polis olabilecek vasıfta bir şahıs al getir\" dedi. Verilen emir kısa sürede yerine getirilerek Atatürk'ün emirleri doğrultusunda polis olabilecek nitelikte bir şahıs huzuruna getirildi.",
    "Mustafa Kemal Atatürk getirilen şahsa adını memleketini ve askerliğini yapıp yapmadığını sordu. Gerekli cevapları aldıktan sonra tekrar yaverini çağırarak şarjörü ile birlikte bir tüfek getirmesini emretti. Tüfek getirildiğinde \"Tüfeği Harput'lu Fikri'ye verin\" dedi. Tüfeği alan Fikri'ye de \"Tüfeği doldur\" diye emretti. Atatürk'ün kesin emri doğrultusunda tüfeği dolduran Fikri'ye bu sefer \"tavana ateş et\" emrini verdi. Emri alan Fikri hiç tereddüt etmeden tavana beş el ateş etti. Tüfekteki mermiler bitince Atatürk'ün emrini bekleyen Fikri'yi \"dışarı çık\" diyerek odadan çıkarttı.",
    "Harput'lu Fikri dışarı çıktıktan sonra Atatürk'ün bizzat yanına aldığı ve polisliğini takdir ettiği polis memuru Ragıp efendiyi yanına çağırttı. Karşısında saygılı bir şekilde emir vermesini bekleyen Ragıp efendi, diğer davetlilere teker teker baktıktan sonra tekrar Atatürk'e dönerek: \"Emriniz baş üstüne Paşam ama sebebini öğrenebilir miyim?\" diye karşı soru sorunca Atatürk \"Çıkabilirsin Ragıp efendi\" diyerek onu da odadan çıkarttı.",
    "Polis memuru Ragıp efendi odayı terk ettikten sonra İçişleri Bakanına dönen Atatürk \"Şükrü bey ilk gelen Harput'lu Fikri'ye seni vurmasını söylesem vurur muydu?\" şeklinde bir soru yönelttiğinde Şükrü bey hiç tereddüt etmeden \"Vururdu\" diye cevap verdi. Aldığı cevap karşısında yüzü aydınlanmaya başlayan Atatürk tekrar sordu; \"Ragıp efendiye seni vurmasını söylesem vurur muydu?\" deyince yine aynı kararlılıkla \"Vurmazdı paşam\" diye cevap verdi.",
    "İstediği ve toplantıda bulunanları eğitici cevapları aldıktan ve onlara uygulamalı olarak bir ders verdikten sonra tekrar Şükrü beye hitaben \"O halde kolları sıva Polis Kolejini Polis Enstitüsünü aç. Bu müesseselere en iyi ve en değerli hocaları temin et\" diye kesin emrini verdi.",
  ];

  Future<void> _openEgm(BuildContext context) async {
    final u = Uri.parse(_egmUrl);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Atatürk ve Türk Polisi')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AtaturkPortraitHero(
            assetPath: _ataturkImage,
            height: 320,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            FilledButton.tonalIcon(
              onPressed: () => _openEgm(context),
              icon: const Icon(Icons.open_in_new, size: 20),
              label: const Text('Kaynak: egm.gov.tr (tam metin ve güncel sayfa)'),
            ),
            const SizedBox(height: 16),
            Text(
              'Aşağıdaki anlatım Emniyet Genel Müdürlüğü web sitesinde yayımlanan "Atatürk ve Türk Polisi" bölümünden alınmıştır.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < _paragraflar.length; i++) ...[
              if (i > 0) const SizedBox(height: 14),
              Text(
                _paragraflar[i],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.55,
                    ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Kaynak: $_egmUrl',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
