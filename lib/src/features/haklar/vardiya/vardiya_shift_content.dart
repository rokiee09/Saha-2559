/// Vardiya türlerine göre bilgilendirici metinler (örnek anlatım; resmî görev çizelgesi değildir).
String vardiyaDescriptionFor(String id) {
  return _vardiyaDescriptions[id] ?? _vardiyaDefault;
}

const String _vardiyaDefault =
    'Bu vardiya düzenine ilişkin özet metin henüz eklenmedi. '
    'Kesin görev saatleri ve nöbet sırası yalnızca kurumunuzdaki resmî çizelge ve emirlerle belirlenir.';

const Map<String, String> _vardiyaDescriptions = {
  '12_24':
      'On iki saat hizmet, yirmi dört saat dinlenme çevrimine dayanan klasik bir iş–dinlenme örüntüsüdür. '
      'Uygulama; kavramsal olarak “bir gün çalış, iki gün dinlen” düzenine yaklaşan düzenleri hatırlatmanız için özet anlatır.\n\n'
      'Pratikte mesai başlangıç ve bitiş saatleri, hafta içi–hafta sonu ayrımı ve fazla mesai kurum içi yönergelere göre değişir.',
  'cakma_12_36':
      'Çakma düzende uzun vadede üst üste farklı uzunlukta gündüz ve gece blokları gelebilir; haftanın belirli günleri değil, '
      'blok içi “birim” sayısı (örnek: 3 gündüz birimi → 12 gece birimi → 5 gündüz → 10 gece → 6 gündüz → 9 gece gibi tekrarlayan bir sıra) ile düşünülür.\n\n'
      'Her gündüz biriminde on iki saat görev ve on iki saat dinlenme; gece biriminde on iki saat görev ve otuz altı saat dinlenme; '
      'bloklar arasında mod değişiminde ise örnek modele göre yirmi dört saatlik geçiş dinlenmesi eklenir.\n\n'
      'Bu ekrandaki çizelge yalnızca örnektir; rakamlar biriminize göre kodda güncellenebilir. Kesin nöbet sırası cetvel ve emir ile doğrulanmalıdır.',
  'gercek_12_36':
      'On iki saat görev, otuz altı saat dinlenme döngüsü olarak adlandırılan düzenlerde kutuplu (iş–dinlenme) günler belirginleşir. '
      'Tatiller, tatil çalışması ve yer değiştirme günleri çizelgeyi değiştirir.\n\n'
      'Uygulama çıktısı tahmindir; bordro ve özlük işlemleri için resmî kayıtlar esas alınmalıdır.',
  '24_48':
      'Yirmi dört saat kesintisiz veya blok halinde görev, kırk sekiz saat dinlenme mantığıyla çalışan nöbet tiplerinde '
      'fiziksel ve yasal yorgunluk sınırları ayrıca düzenlenir.\n\n'
      'Bu başlık altında yalnızca kavramsal bilgi sunulur; fiili kalıp içişleri ve sağlık düzenlemeleriyle uyumlu olmalıdır.',
  '8_24':
      'Sekiz saatlik günlük görev periyotlarının yirmi dört saatlik döngüde tekrarlandığı düzenlerde, '
      'vardiya başlangıç saati personel grubuna göre kaydırılabilir (sabah–akşam–gece).\n\n'
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
