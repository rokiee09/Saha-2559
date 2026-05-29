# Sürüm Öncesi Kontrol Listesi

Yayından önce bu listeyi gerçek cihaz(lar)da yürütün.

## Cihaz / OS matrisi

Mümkün olduğunca farklı Android sürümlerinde test edin:

- [ ] Android 10
- [ ] Android 11
- [ ] Android 12
- [ ] Android 13
- [ ] Android 14
- [ ] Android 15

(En az: bir eski + bir güncel sürüm.)

## İşlevsel testler (her cihazda)

- [ ] İlk açılış / onboarding sorunsuz
- [ ] Kullanıcı sözleşmesi onayı kaydediliyor
- [ ] Mevzuat listesi açılıyor, arama çalışıyor
- [ ] Madde detayı okunuyor; favori ekleme/çıkarma çalışıyor
- [ ] Kişisel madde notu kaydediliyor (yeniden açınca duruyor)
- [ ] Saha defteri notu ekleme/silme
- [ ] Maaş hesaplayıcı sonuç üretiyor (uç/sıfır değerlerde patlamıyor)
- [ ] Vardiya takvimi doğru günleri gösteriyor
- [ ] "Veri güncelliği" ekranı açılıyor; resmî kaynak butonu tarayıcıyı açıyor
- [ ] İl iletişim/harita çalışıyor; numara arama telefon uygulamasını açıyor

## Görünüm / erişilebilirlik

- [ ] Koyu tema
- [ ] Açık tema
- [ ] Büyük sistem yazı tipi (ayar + uygulama içi okuma ölçeği)
- [ ] Yatay/dikey ve küçük ekran

## Ağ / gizlilik

- [ ] Uçak modunda tüm içerik açılıyor (offline doğrulaması)
- [ ] Uygulama izinleri: yalnızca beklenenler (INTERNET dahi istenmiyor)
- [ ] Harici bağlantılar yalnızca kullanıcı dokununca açılıyor

## Yayın paketi

- [ ] `flutter analyze --no-fatal-infos` temiz
- [ ] `dart run tool/validate_mevzuat.dart` 0 hata
- [ ] `flutter test` tüm testler geçiyor
- [ ] `android/key.properties` ile imzalı `flutter build appbundle`
- [ ] Sürüm numarası (`pubspec.yaml` `version`) artırıldı
- [ ] CHANGELOG.md güncellendi

## Play Console

- [ ] Gizlilik politikası URL'si girildi (GitHub Pages: `https://rokiee09.github.io/Saha-2559/`)
- [ ] Veri güvenliği formu: "veri toplanmıyor / paylaşılmıyor"
- [ ] Ekran görüntüleri ve feature graphic yüklendi
- [ ] İçerik derecelendirme anketi tamamlandı
- [ ] Açıklama dili "bağımsız bilgilendirme" çizgisinde (resmî kurum izlenimi vermiyor)

---

## GitHub repo açıklaması ve topics

Repo ana sayfasında (sağ üst **About** ⚙️) ayarlayın:

- **Description:**
  `Offline Flutter reference app for Turkish police legislation, rights, organization and field notes.`
- **Topics:**
  `flutter`, `dart`, `offline-first`, `android`, `law`, `reference-app`, `riverpod`

---

## GitHub Pages'i etkinleştirme (gizlilik URL'si için)

1. GitHub'da repo → **Settings → Pages**.
2. **Build and deployment → Source**: "Deploy from a branch".
3. **Branch**: `main`, **Folder**: `/docs` → **Save**.
4. Birkaç dakika sonra yayınlanır: `https://rokiee09.github.io/Saha-2559/`
   (gizlilik politikası `docs/index.html` üzerinden).
