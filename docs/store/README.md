# Mağaza Yayın Materyalleri

Bu klasör, Google Play yayını için hazırlık materyallerini içerir.

## İçerik

- [`store_listing_tr.md`](store_listing_tr.md) — uygulama adı, kısa/uzun açıklama, kategori ve form notları.
- `screenshots/` — mağaza ekran görüntüleri (aşağıdaki kurallara göre).

## 1) Uygulama ikonu

İkon `flutter_launcher_icons` ile `assets/icon/app_icon.png` kaynağından üretilir
(yapılandırma `pubspec.yaml` içinde). Kaynak görsel **512×512 px veya daha büyük**,
kare ve şeffaf olmayan arka planlı olmalıdır.

İkonları yeniden üretmek için:

```bash
flutter pub get
dart run flutter_launcher_icons
```

Play Console ayrıca **512×512 px** "yüksek çözünürlüklü simge" ister; bu, kaynak ikonun
512×512 PNG hâliyle aynıdır.

## 2) Öne çıkan görsel (Feature graphic)

- Boyut: **1024×500 px**, PNG/JPG.
- Üzerinde uygulama adı (SAHA 2559) ve kısa slogan yer alabilir.

## 3) Ekran görüntüleri

Play Console gereksinimleri:

- **En az 2**, en fazla 8 telefon ekran görüntüsü.
- Kenar uzunluğu **320–3840 px** arası; en-boy oranı 16:9 veya 9:16 (dikey önerilir).
- Önerilen dikey çözünürlük: **1080×1920 px**.

Önerilen ekranlar:

1. Ana sayfa / özet
2. Mevzuat listesi + arama
3. Madde detayı (okuma görünümü)
4. Maaş hesaplayıcı
5. Vardiya/nöbet takvimi
6. Teşkilat veya kültür ekranı

Ekran görüntüsü almak için:

```bash
# Web önizleme (hızlı): tarayıcı penceresini dikey/uygun boyuta getirip yakalayın
flutter run -d chrome

# Gerçek cihaz/emülatör (mağaza için önerilir)
flutter run -d android
```

Çıktıları `docs/store/screenshots/` altına `01-anasayfa.png`, `02-mevzuat.png` gibi
sıralı adlarla koyun.

## 4) Yayın öncesi kontrol listesi

- [ ] `applicationId` = `com.coderipple.saha2559` (kalıcı kimlik)
- [ ] `android/key.properties` ile release imzalama yapılandırıldı (keystore yedeği alındı)
- [ ] `flutter build appbundle` ile `.aab` üretildi
- [ ] Gizlilik politikası URL'si Play Console'a girildi (`PRIVACY.md`)
- [ ] Destek e-postası gerçek adresle güncellendi (`lib/.../app_publisher_contact.dart`)
- [ ] Ekran görüntüleri ve feature graphic yüklendi
- [ ] Veri güvenliği formu dolduruldu ("veri toplanmıyor")
- [ ] İçerik derecelendirmesi anketi tamamlandı
