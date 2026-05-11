/// Mağaza ve kullanıcı sözleşmesinde görünen yayımcı / iletişim bilgileri.
///
/// **Tek yer:** Bu dosyayı güncellemeniz yeterli; sözleşme ve ayarlar buradan okur.
library app_publisher_contact;

import 'app_branding.dart';

/// Uygulama ve sözleşmede görünen geliştirici adı.
const String kLegalPublisherDisplayName = 'Burak';

/// Şirket unvanı veya ticari işletme adı. Boş bırakılırsa metinde yalnızca
/// [kLegalPublisherDisplayName] kullanılır.
const String kLegalPublisherLegalEntity = '';

/// Destek ve hukuki bildirimler için e-posta. Mağaza ile aynı adresi kullanmanız önerilir.
/// Boş bırakılırsa sözleşmede yalnızca mağaza kanalı ve yayımcı adı yer alır.
const String kSupportEmail = '';

/// Başlık altı kısa satır (sözleşme özeti).
String legalPublisherSummaryLine() {
  final entity = kLegalPublisherLegalEntity.trim();
  if (entity.isEmpty) {
    return 'Yayımcı / geliştirici: $kLegalPublisherDisplayName';
  }
  return 'Yayımcı: $entity · İletişim adı: $kLegalPublisherDisplayName';
}

/// Madde 15 gövdesi.
String userAgreementContactSectionBody() {
  final entity = kLegalPublisherLegalEntity.trim();
  final email = kSupportEmail.trim();

  final buf = StringBuffer();
  buf.writeln(
    'Bu uygulamanın kullanıcıya yönelik bildirimlerde görünen yayımcı/geliştirici '
    'kimliği: $kLegalPublisherDisplayName.',
  );
  if (entity.isNotEmpty) {
    buf.writeln('\nTicari veya hukuki unvan: $entity.');
  }
  buf.writeln();
  if (email.isNotEmpty) {
    buf.writeln(
      'Destek talepleri, içerik bildirimi ve bu sözleşmeye ilişkin yazılı başvurular '
      'için e-posta: $email.',
    );
    buf.writeln();
  }
  buf.write(
    'Geri bildirim için ayrıca ilgili uygulama mağazası (örneğin Google Play) '
    'sayfasındaki iletişim kanalları kullanılabilir.',
  );
  buf.writeln();
  buf.writeln(
    'Google Play ve benzeri mağazalarda yayın vitrin kimliği olarak '
    '"$kMarketBrandName" kullanılabilir; bu, uygulamanın adı olan '
    '"$kAppDisplayName" ile karıştırılmamalıdır.',
  );
  return buf.toString();
}
