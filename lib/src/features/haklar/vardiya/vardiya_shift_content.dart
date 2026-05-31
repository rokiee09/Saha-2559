/// Vardiya türlerine göre bilgilendirici metinler (örnek anlatım; resmî görev çizelgesi değildir).
String vardiyaDescriptionFor(String id) {
  return _vardiyaDescriptions[id] ?? _vardiyaDefault;
}

const String _vardiyaDefault =
    'Bu vardiya düzenine ilişkin özet metin henüz eklenmedi. '
    'Kesin görev saatleri ve nöbet sırası yalnızca kurumunuzdaki resmî çizelge ve emirlerle belirlenir.';

const Map<String, String> _vardiyaDescriptions = {
  '12_24':
      'On iki saat hizmet, yirmi dört saat dinlenme çevrimine dayanan klasik bir iş–dinlenme örüntüsüdür.\n\n'
      'Kurulum ekranında bugün gündüz mü, gece mi yoksa istirahat mi olduğunuzu seçersiniz. '
      'Gündüz nöbeti 08:00–20:00, gece nöbeti 20:00–08:00 (ertesi gün) olarak özetlenir.\n\n'
      'Pratikte mesai başlangıç ve bitiş saatleri kurum içi yönergelere göre değişir; kesin sıra cetvelden doğrulanmalıdır.',
  'cakma_12_36':
      'Çakma 12/36 örnek modelde sıra iki bloktan oluşur: önce 5 gün gündüz, sonra 10 gün gece.\n\n'
      'Gündüz bloğunda her gün 12 saat görev (08:00–20:00) ve 12 saat dinlenme vardır; yani gündüzler peş peşe günlük gelir. '
      'Gece bloğunda ise 12 saat görev (20:00–08:00) ve 36 saat dinlenme uygulanır; yani gece nöbetleri gün aşırı düşer.\n\n'
      'Yukarıdaki “gündüz / gece başla” seçimi, çizelgenin hangi blokla başladığını belirler. '
      'Bu ekran örnektir; blok günleri ve saatler biriminize göre değişebilir, kesin sıra cetvel ve emir ile doğrulanmalıdır.',
  'gercek_12_36':
      'Gerçek (orijinal) 12/36 örnek modelde 15 gün gece, 15 gün gündüz blokları birbirini izler. '
      'Hem gündüz hem gece nöbetinde 12 saat görev, 36 saat dinlenme vardır; nöbetler gün aşırı düşer.\n\n'
      'Kurulumda tarih, grup (1–4), şu anki vardiya (gündüz/gece) ve tablo süresini (5–15 gün) seçersiniz. '
      'Gece nöbeti 20:00’de başlar, ertesi gün 08:00’de biter; gündüz nöbeti 08:00–20:00 arasıdır. '
      'Geceden gündüze geçerken 24 saat, gündüzden geceye geçerken 48 saat dinlenme bırakılır.\n\n'
      'Grup seçimi döngü kaymasını simüle eder. Çıktı örnektir; bordro ve özlük işlemleri için resmî kayıtlar esastır.',
  '24_48':
      'Yirmi dört saat kesintisiz veya blok halinde görev, kırk sekiz saat dinlenme mantığıyla çalışan nöbet tiplerinde '
      'fiziksel ve yasal yorgunluk sınırları ayrıca düzenlenir.\n\n'
      'Bu başlık altında yalnızca kavramsal bilgi sunulur; fiili kalıp içişleri ve sağlık düzenlemeleriyle uyumlu olmalıdır.',
  '8_24':
      'Sekiz saatlik günlük görev periyotlarının yirmi dört saatlik döngüde tekrarlandığı düzenlerde '
      'sabah, öğleden sonra ve akşam vardiyaları 08:00–20:00 aralığında özetlenir.\n\n'
      'Kurulumda bugün hangi vardiyada olduğunuzu veya izinli olup olmadığınızı seçersiniz. '
      'Haftalık çalışma süresi üst sınırları mevzuata ve kurum içi plana bağlıdır.',
  '222':
      '“2 + 2 + 2” ifadesi çoğu zaman ikişer saatlik veya ikişer vardiyalık blokların art arda geldiği özel planları anlatır; '
      'hangi rakamın hangi birimi (saat, gün, nöbet tipi) temsil ettiği birim talimatıyla netleşir.\n\n'
      'Uygulama, açıklamayı genel örnek düzeyinde tutar; terimler kurum içinde farklı adlandırılabilir.',
  '11':
      '“1 + 1” ile anılan bazı nöbet kümelerinde iki ayrı iş günü veya iki ayrı nöbet görevi üst üste planlanır; '
      'ara dinlenme ve ulaşım süreleri ayrıca hesaplanır.\n\n'
      'Kesin sayım ve sıra listeniz, birim nöbet tertip cetvelinden okunmalıdır.',
  '21':
      'İki birim veya iki blok artı tek tamamlayıcı blok şeklinde özetlenen çizelgelerde, orta dinlenme günleri kritiktir. '
      'Hafta sonu nöbetleri ve idari izin günleri sırayı kaydırır.\n\n'
      'Bu metin hatırlatma içindir; resmî emir ve cetvel olmadan fiili nöbet üstlenilmemelidir.',
  '31':
      'Üçlü blok ve tek tamamlayıcı bloktan oluşan uzun periyotlu düzenlerde tatil üst üste gelince telafi günleri oluşur. '
      'Personel sayısı düşük birimlerde sık telafi nöbeti görülebilir.\n\n'
      'Özlük hakları ve dinlenme süreleri mevzuatla sınırlıdır; uygulama tavsiye vermez.',
  'asayis_11':
      'Asayiş hizmetlerinde kullanılan “1+1” tipi sıralar genelde yoğun olay günlerinde kısa dönüşümlü nöbetleri ifade eder; '
      'birim ve olay türüne göre süreler değişir.\n\n'
      'Ayrıntı yalnızca görev emrinde ve resmî nöbet dağıtımında yer alır.',
};
