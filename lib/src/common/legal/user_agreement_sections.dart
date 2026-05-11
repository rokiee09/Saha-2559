import '../constants/app_branding.dart';
import '../constants/app_publisher_contact.dart';

/// SAHA 2559 kullanıcı sözleşmesi — özet hukuki çerçeve (bilgilendirme amaçlıdır;
/// bağlayıcı hukuki danışmanlık değildir).
const String kUserAgreementVersion = '1.0.0';

/// Metin güncellendiğinde kullanıcıdan yeniden onay istemek için kullanılır.
const String kUserAgreementEffectiveLabel = '30 Mart 2026';

class UserAgreementSection {
  const UserAgreementSection({required this.title, required this.body});

  final String title;
  final String body;
}

/// Tam metin — başlıklar ve gövdeler (uzun tek parça yerine okunabilir bölümler).
const List<UserAgreementSection> kUserAgreementSections = [
  UserAgreementSection(
    title: '1. Yasal uyarı ve bağımsızlık',
    body:
        '$kAppDisplayName mobil uygulaması; mesleki bilgiye hızlı erişim, offline mevzuat '
        'okuma ve kişisel hatırlatma araçları sunmak üzere geliştirilmiş bağımsız bir yazılımdır. '
        'Uygulama; Emniyet Genel Müdürlüğü, İçişleri Bakanlığı veya herhangi bir kamu kurumu '
        'veya kuruluş ile resmî bağ, ortaklık, ruhsat, onay veya entegrasyon içermez. '
        'POLNET, UYAP ve benzeri resmî sistemlerle veri alışverişi yapılmaz.\n\n'
        'Bu metinde yer alan hiçbir ifade, kamu görevlisi sıfatınıza ek yetki vermez veya '
        'kurum adına işlem yapma imkânı doğurmaz.',
  ),
  UserAgreementSection(
    title: '2. Taraflar ve kabul',
    body:
        'Bu sözleşme; uygulamayı indiren ve kullanan gerçek kişi kullanıcı ile yazılımın '
        'yayımcısı/geliştiricisi ($kLegalPublisherDisplayName) arasında elektronik ortamda kurulur. '
        'Uygulamayı kullanmaya '
        'başlamanız, bu metnin tamamını okuduğunuzu ve bağlayıcı şekilde kabul ettiğinizi '
        'gösterir.\n\n'
        'Uygulama; aktif görevdeki güvenlik personeli ve adayları düşünülerek hazırlanmış olsa da '
        'yalnızca bilgilendirme ve kişisel verimlilik amaçlıdır. On sekiz yaşın altındaki '
        'kişilerin ebeveyn/vası gözetiminde değerlendirmesi önerilir; metni kabul etmiyorsanız '
        'uygulamayı kullanmayınız.',
  ),
  UserAgreementSection(
    title: '3. Hizmetin kapsamı',
    body:
        '$kAppDisplayName; paket içi kanun/yönetmelik metinleri, teşkilat bilgileri, özet hak '
        'başlıkları, kültürel içerikler, tahmini ücret hesaplama formu (bilgilendirme niteliğinde), '
        'vardiya türü seçimi ve tarih çizelgesi için yer tutucu araçlar ile tamamen cihazınızda '
        'tutulan “Saha” notları gibi özellikler içerebilir. Özellikler zaman içinde güncellenebilir '
        'veya kaldırılabilir.\n\n'
        'Sunulan içerikler genel bilgi ve hatırlatma içindir; görev yerindeki işlem ve kararların '
        'yerine geçmez.',
  ),
  UserAgreementSection(
    title: '4. Kişisel veri, günlük kayıtları ve yerel saklama',
    body:
        'Uygulama; kullanıcı hesabı veya merkezi oturum açma gerektirmeden çalışır. '
        'Tercihleriniz (tema, okuma ölçüsü), son görüntülenenler, favoriler, madde notları, '
        'vardiya türü seçimi ve “Saha” notları gibi kayıtlar cihazınızın yerel depolama '
        'alanında tutulur; geliştiriciye otomatik olarak iletilmez.\n\n'
        'Bu nedenle geliştirici; cihazınıza yazdığınız içeriği göremez, yedekleyemez veya '
        'silmenizi uzaktan emredemez. Verinin güvenliği (ekran kilidi, cihaz şifresi, fiziksel '
        'erişim) tamamen kullanıcı sorumluluğundadır. Uygulama silindiğinde yerel kayıtlar '
        'kalıcı olarak kaybolabilir; düzenli yedek ihtiyacı kullanıcıya aittir.\n\n'
        '6698 sayılı Kişisel Verilerin Korunması Kanunu çerçevesinde geliştirici, kendi sistemlerinde '
        'işlenen kişisel veri bulunmadığından veri sorumlusu sıfatıyla talepleri yerine getiremez; '
        'cihazınızdaki kayıtları doğrudan siz yönetirsiniz.',
  ),
  UserAgreementSection(
    title: '5. Dijital onay kaydı',
    body:
        'Bu sözleşmeyi kabul ettiğiniz anda; kabul tarihi ve saati ile birlikte hangi sözleşme '
        'sürümünün ($kUserAgreementVersion) onaylandığı bilgisi yine yalnızca cihazınızdaki yerel '
        'tercih deposuna yazılır. Bu kayıt geliştiriciye iletilmez.\n\n'
        'İsterseniz Ayarlar bölümünden güncel metne yeniden erişebilirsiniz.',
  ),
  UserAgreementSection(
    title: '6. Mevzuat doğruluğu ve resmî kaynak',
    body:
        'Mevzuat metinleri uygulama paketinde yer alan dosyalardan okunabilir; güncellenmiş '
        'veya değiştirilmiş hükümler için Resmî Gazete ve kurum içi güncel kaynaklar '
        'esas alınmalıdır. Mahkeme içtihatları ve idari düzenlemeler zaman içinde değişebilir.\n\n'
        'Özet hak metinleri özet niteliğindedir; bağlayıcı işlem için ilgili kanun, '
        'yönetmelik ve kurum düzenlemelerinin tam metnine başvurmanız gerekir.',
  ),
  UserAgreementSection(
    title: '7. Tahmini maaş ve vardiya hesaplama araçları',
    body:
        'Tahmini ücret bilgisi ve vardiya ile ilgili ekranlar yalnızca kabaca hesap ve kişisel '
        'planlama için sunulur; kesin ücret ve nöbet çizelgesi kurum bordrosu ile amir '
        'onaylı görev düzenlemelerine bağlıdır. Hesaplama hataları, parametre güncelliği veya '
        'yanlış veri girişinden doğabilecek sonuçların resmî bir karşılığı yoktur.\n\n'
        'Bu araçların çıktısı; disiplin süreci, özlük işlemi veya hukuki süreçte tek başına '
        'delil veya dayanak oluşturmaz.',
  ),
  UserAgreementSection(
    title: '8. “Saha” ve yerel notlar',
    body:
        'Saha başlığı altındaki notlar hukuki kayıt, resmî tutanak veya kurum kaydı niteliği '
        'taşımaz; yalnızca kişisel hatırlatmadır. Üçüncü kişilere ilişkin kimlik, adres, plaka '
        'veya özel nitelikli veri kaydı; mevzuata aykırı veya görevin kötüye kullanımına '
        'yol açabilecek şekilde yapılmamalıdır.\n\n'
        'Bu tür kullanımlardan doğabilecek cezaî, hukukî ve idarî sonuçların sorumluluğu '
        'kullanıcıya aittir.',
  ),
  UserAgreementSection(
    title: '9. Yasaklı ve kötüye kullanım',
    body:
        'Aşağıdaki kullanımlar kesinlikle yasaktır:\n'
        '• Uygulama verilerini resmî tutanak, savunma veya idari işlemde tek başına delil '
        'olarak sunmak.\n'
        '• Vatandaş veya meslektaşlar hakkında izinsiz sistematik kayıt veya fişleme yapmak.\n'
        '• Çocuklara veya hassas suç türlerine ilişkin hukuka aykırı içerik işlemek.\n'
        '• Yazılımı tersine mühendislik, otomasyon botları veya zararlı amaçlarla kullanmak.\n\n'
        'Şüphe halinde işlemi durdurmanız ve kurum içi hukuk/disiplin süreçlerine uymanız '
        'önerilir.',
  ),
  UserAgreementSection(
    title: '10. Üçüncü taraf bağlantılar ve mağaza politikaları',
    body:
        'Varsa harici bağlantılar kolaylık amaçlıdır; içerikleri üçüncü taraflar yönetir. '
        'Google Play veya App Store kullanım şartları ayrıca uygulanır. Mağaza politikaları '
        'nedeniyle uygulamanın kaldırılması veya güncellenememesi durumunda geliştirici makul '
        'ölçüde destek vermeye çalışır ancak sürekli hizmet garantisi vermez.',
  ),
  UserAgreementSection(
    title: '11. Geliştirici sorumluluğunun sınırı',
    body:
        'Kanunun zorunlu hükümleri saklı kalmak kaydıyla; uygulamanın kullanımından doğan '
        'dolaylı zararlar, kaçırılan görev, idari veya cezaî yaptırımlar için geliştiriciye '
        'yöneltilen talepler mümkün olan ölçüde reddedilir.\n\n'
        'Yazılım “olduğu gibi” sunulur; kesintisiz veya hatasız çalışacağı garanti edilmez.',
  ),
  UserAgreementSection(
    title: '12. Fikri mülkiyet',
    body:
        '$kAppDisplayName adı, arayüz düzeni ve paket içi derlemeler geliştiriciye '
        'ait haklarla korunabilir. İçerikleri izinsiz çoğaltmak, satmak veya benzer bir '
        'üründe kullanmak yasaktır (kanunun izin verdiği kişisel kullanım istisnaları saklıdır).',
  ),
  UserAgreementSection(
    title: '13. Uygulanacak hukuk ve çözüm',
    body:
        'Bu sözleşmeden doğan uyuşmazlıklarda Türkiye Cumhuriyeti hukuku uygulanır. '
        'Kanunun kullanıcıya zorunlu kıldığı haklar saklıdır.',
  ),
  UserAgreementSection(
    title: '14. Güncelleme ve yeniden onay',
    body:
        'Bu metin zaman içinde güncellenebilir. Önemli değişikliklerde uygulama; yeni '
        'sürüm numarasını ($kUserAgreementVersion gibi) güncelleyerek ilk açılışta yeniden '
        'onay isteyebilir. Güncellenmiş metni kabul etmiyorsanız uygulamayı kullanmayı '
        'durdurmalısınız.',
  ),
];
