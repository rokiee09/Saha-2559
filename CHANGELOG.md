# Değişiklik Günlüğü

Bu projedeki önemli değişiklikler bu dosyada tutulur.
Biçim [Keep a Changelog](https://keepachangelog.com/tr/1.0.0/) esas alır;
sürümleme [Semantic Versioning](https://semver.org/lang/tr/) ile uyumludur.

## [Yayımlanmadı]

### Eklendi
- INTERNET izni kaldırıldı; uygulama artık hiçbir ağ izni istemiyor.
- Uygulama içi "Veri güncelliği" ekranı: kaynak, son içerik kontrol tarihleri,
  "resmî kaynak değildir" uyarısı ve resmî kaynağa erişim butonu.
- Mevzuat verisi bütünlük doğrulayıcısı (`tool/validate_mevzuat.dart`) ve CI adımı.
- GitHub Pages için gizlilik politikası sayfası (`docs/index.html`).
- CHANGELOG.md, SECURITY.md ve sürüm öncesi cihaz test listesi.

### Değiştirildi
- Mağaza metni "bağımsız bilgilendirme uygulaması" çizgisiyle güçlendirildi.

### Düzeltildi
- Jandarma Kanunu (2803) verisindeki metni boş iki "Ek Madde" artığı temizlendi.

## [1.0.0+1] — İlk yayın

### Modüller
- **Mevzuat**: Kanun/yönetmelik metinleri, madde arama, favoriler,
  son görüntülenenler, kişisel madde notları (çevrimdışı).
- **Teşkilat**: Birimler ve teşkilat yapısı, rütbe görselleri.
- **Haklar**: Vatandaşlık/disiplin-savunma içerikleri, maaş tahmin hesaplayıcı,
  vardiya/nöbet takvimi (çakma 12/36 dâhil).
- **Kültür**: Polis tarihi, polis andı, önemli günler, Atatürk ve Türk Polisi.
- **İl iletişim & Türkiye haritası**, yerel "saha defteri" notları.

### Altyapı
- Flutter + Riverpod; içerik uygulama paketinde (offline-first).
- Android `applicationId`: `com.coderipple.saha2559`.
- Release imzalama `android/key.properties` üzerinden.
- GitHub Actions CI: `flutter pub get` + `analyze` + veri doğrulama + `test`.

> Veri güncelleme tarihleri: Mevzuat metinleri mevzuat.gov.tr esas alınarak derlenmiştir.
> Metin bazında son içerik kontrol tarihleri uygulama içi "Veri güncelliği" ekranında görülebilir.
