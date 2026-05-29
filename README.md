<div align="center">

# SAHA 2559

**Polis mevzuat, teşkilat, haklar ve kültür bilgileri — çevrimdışı.**

Mağaza yayın markası: **Coderipple**

[![CI](https://github.com/rokiee09/Saha-2559/actions/workflows/ci.yml/badge.svg)](https://github.com/rokiee09/Saha-2559/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.29%2B-02569B?logo=flutter)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Web%20%7C%20Windows-555)

</div>

> **Bilgilendirme:** Bu uygulama resmî bir kurum uygulaması değildir ve bilgilendirme amaçlıdır.
> Resmî ve güncel mevzuat için [mevzuat.gov.tr](https://www.mevzuat.gov.tr) esas alınmalıdır.

---

## İçindekiler

- [Genel bakış](#genel-bakış)
- [Özellikler](#özellikler)
- [Ekran görüntüleri](#ekran-görüntüleri)
- [Mimari ve teknoloji](#mimari-ve-teknoloji)
- [Başlangıç](#başlangıç)
- [Çalıştırma](#çalıştırma)
- [Test ve statik analiz](#test-ve-statik-analiz)
- [Sürüm derlemesi (release)](#sürüm-derlemesi-release)
- [Proje yapısı](#proje-yapısı)
- [Veri modelleri ve JSON şeması](#veri-modelleri-ve-json-şeması)
- [Gizlilik](#gizlilik)
- [Katkı](#katkı)
- [Lisans](#lisans)

## Genel bakış

SAHA 2559, sahadaki/masadaki polis personeli için mevzuat ve referans bilgilerini **internet
bağlantısı olmadan** sunmayı hedefler. Kanun ve yönetmelik metinleri uygulama paketinde gelir;
metroda, nöbet boşluğunda veya zayıf çekimde de madde arayıp okuyabilirsiniz.

Dört ana hat: **Mevzuat · Teşkilat · Haklar · Kültür** (artı yerel "Saha defteri" notları).

## Özellikler

- **Mevzuat okuyucu**: Kanun/yönetmelik metinleri, madde arama, favoriler, son görüntülenenler ve
  kişisel madde notları (yalnızca cihazda).
- **Haklar**: Vatandaşlık/disiplin-savunma içerikleri; **maaş tahmin hesaplayıcı** ve
  **vardiya/nöbet takvimi** (çakma 12/36 dâhil örnek döngüler).
- **Teşkilat**: Birimler ve teşkilat yapısı özetleri, rütbe görselleri.
- **Kültür**: Polis tarihi, polis andı, önemli günler, Atatürk ve Türk Polisi.
- **İl iletişim & Türkiye haritası**: İl bazlı iletişim, SVG harita ile seçim.
- **Çevrimdışı öncelikli**: İçerik pakette; sürekli internet gerekmez.
- **Kişisel veri sunucuya gitmez**: Tüm tercih/notlar cihazda saklanır.

## Ekran görüntüleri

> Mağaza için ekran görüntüleri `docs/store/screenshots/` altında tutulur.
> Üretmek için: `flutter run -d chrome` veya bir cihaz/emülatör ile uygulamayı açıp ekranları kaydedin.
> Mağaza metni ve görsel rehberi: [`docs/store/`](docs/store/).

| Ana sayfa | Mevzuat | Maaş hesap | Vardiya |
| --- | --- | --- | --- |
| _eklenecek_ | _eklenecek_ | _eklenecek_ | _eklenecek_ |

## Mimari ve teknoloji

- **Flutter** (stable, 3.29+) · **Dart** `>=3.4.0 <4.0.0`
- **Durum yönetimi**: `flutter_riverpod`
- **Yerel veritabanı**: `isar` + `isar_flutter_libs` (içe aktarılan liste verileri için)
- **Yerel tercih deposu**: `shared_preferences`
- **Diğer**: `flutter_svg`, `url_launcher`, `share_plus`, `phosphor_flutter`, `path_provider`

Platform notu: Mevzuat metinleri tüm platformlarda asset JSON'dan okunur; Isar yalnızca
isteğe bağlı içe aktarma akışında kullanılır (web'de uygun stub'lar mevcuttur).

## Başlangıç

### Gereksinimler

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable, 3.29+)
- Android için: Android Studio + Android SDK
- Windows masaüstü derlemesi için: **Geliştirici Modu** açık olmalı
  (eklenti symlink desteği için): Ayarlar → `start ms-settings:developers` → Geliştirici Modu.

### Kurulum

```bash
git clone https://github.com/rokiee09/Saha-2559.git
cd Saha-2559
flutter pub get
```

## Çalıştırma

```bash
# Web (en hızlı önizleme)
flutter run -d chrome

# Android (cihaz/emülatör bağlıyken)
flutter run -d android

# Windows masaüstü
flutter run -d windows
```

Yardımcı betikler: `run_chrome.ps1`, `run_web_chrome.ps1` (Windows/PowerShell).

## Test ve statik analiz

```bash
flutter analyze        # statik analiz / lint
flutter test           # birim ve widget testleri
```

CI üzerinde her push ve pull request'te `flutter pub get → analyze → test` otomatik çalışır
(bkz. [`.github/workflows/ci.yml`](.github/workflows/ci.yml)).

## Sürüm derlemesi (release)

Release imzalama bilgileri **depoya eklenmeyen** `android/key.properties` dosyasından okunur.

1. Bir upload keystore oluşturun:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. `android/key.properties.example` dosyasını `android/key.properties` olarak kopyalayıp doldurun
   (`storePassword`, `keyPassword`, `keyAlias`, `storeFile`).
3. `.jks` ve `key.properties` `.gitignore` ile korunur — **bunları paylaşmayın, yedekleyin.**
   Anahtarı kaybederseniz uygulamayı Play Store'da güncelleyemezsiniz.
4. Derleyin:

```bash
flutter build appbundle   # Play Store için .aab
flutter build apk --release
```

`key.properties` yoksa release derlemesi (yalnızca yerel test için) debug anahtarıyla imzalanır.

## Proje yapısı

```
lib/
  main.dart
  src/
    app.dart
    common/        # tema, sabitler, widget'lar, harita, yasal metinler
    data/          # modeller, Isar servis, repository'ler
    features/      # mevzuat, haklar (maaş/vardiya), teşkilat, kültür, saha, ayarlar ...
assets/
  mevzuat/         # kanun & yönetmelik JSON metinleri + catalog.json
  json/            # maas_katsayilari.json, city_contacts.json, martyrs.json
  map/ kultur/ images/ icon/
test/              # birim & widget testleri
docs/store/        # mağaza metni ve görsel rehberi
```

## Veri modelleri ve JSON şeması

### Mevzuat (`assets/mevzuat/catalog.json` + madde dosyaları)

```json
{
  "kanunlar": [
    { "id": "kanun-pvsk", "code": "2559", "name": "Polis Vazife ve Salahiyet Kanunu",
      "path": "kanunlar/pvsk.json", "sourceUrl": "https://www.mevzuat.gov.tr/..." }
  ],
  "yonetmelikler": []
}
```

Madde dosyası:

```json
{
  "law": "Polis Vazife ve Salahiyet Kanunu",
  "source": "mevzuat.gov.tr",
  "sourceUrl": "https://www.mevzuat.gov.tr/...",
  "lastContentReview": "2024-01-01",
  "articles": [
    { "id": "m16", "article": "Madde 16", "title": "...", "text": "...", "source": "mevzuat.gov.tr" }
  ]
}
```

### Maaş katsayıları (`assets/json/maas_katsayilari.json`)

```json
{
  "sonGuncelleme": "2024-07",
  "genelUyari": "Tahmini değerdir; resmî bordro esastır.",
  "formulAciklama": "...",
  "varsayilanDonem": "2024_2",
  "donemler": [
    { "id": "2024_2", "etiket": "2024 Temmuz", "memurAylikKatsayisi": 0.0, "tabanAylik": 0.0, "tahminiNetOrani": 0.7 }
  ]
}
```

### CityContact (`assets/json/city_contacts.json`)

```json
[ { "cityName": "Ankara", "phone": "0312XXXXXXX", "sourceUrl": "https://..." } ]
```

### Martyr (`assets/json/martyrs.json`)

```json
[ { "fullName": "...", "cityName": "İstanbul", "dateOfMartyrdom": "2016-07-15", "location": "İstanbul", "story": "Saygı odaklı kısa hayat hikayesi..." } ]
```

## Gizlilik

Uygulama **internet izni dahi istemez**, kişisel verileri sunucuya göndermez, reklam/analitik
içermez. Tüm tercih ve notlar cihazda saklanır. Ayrıntılar: [PRIVACY.md](PRIVACY.md).

## Katkı

1. Bir konu/branch açın, değişikliği yapın.
2. `flutter analyze` ve `flutter test` yerelde temiz geçsin.
3. PR açın; CI yeşil olmalı.

## Lisans

Lisans henüz belirtilmedi. Kullanım koşulları netleşene kadar tüm hakları saklıdır
(uygulama içi kullanıcı sözleşmesine de bakınız).
