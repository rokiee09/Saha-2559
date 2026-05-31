import 'dart:math' as math;

/// 81 il için yaklaşık koordinatlar (enlem, boylam). Yol izni günü hesabında
/// kullanılan mesafe tahminidir; resmî karayolu mesafesi değildir.
class IlKonum {
  const IlKonum(this.ad, this.lat, this.lng);
  final String ad;
  final double lat;
  final double lng;
}

/// Plaka sırasına göre 81 il.
const List<IlKonum> kIller = [
  IlKonum('Adana', 37.00, 35.32),
  IlKonum('Adıyaman', 37.76, 38.28),
  IlKonum('Afyonkarahisar', 38.76, 30.54),
  IlKonum('Ağrı', 39.72, 43.05),
  IlKonum('Amasya', 40.65, 35.83),
  IlKonum('Ankara', 39.93, 32.85),
  IlKonum('Antalya', 36.88, 30.70),
  IlKonum('Artvin', 41.18, 41.82),
  IlKonum('Aydın', 37.85, 27.84),
  IlKonum('Balıkesir', 39.65, 27.88),
  IlKonum('Bilecik', 40.15, 29.98),
  IlKonum('Bingöl', 38.88, 40.50),
  IlKonum('Bitlis', 38.40, 42.11),
  IlKonum('Bolu', 40.74, 31.61),
  IlKonum('Burdur', 37.72, 30.29),
  IlKonum('Bursa', 40.18, 29.07),
  IlKonum('Çanakkale', 40.16, 26.41),
  IlKonum('Çankırı', 40.60, 33.62),
  IlKonum('Çorum', 40.55, 34.95),
  IlKonum('Denizli', 37.78, 29.09),
  IlKonum('Diyarbakır', 37.91, 40.24),
  IlKonum('Edirne', 41.68, 26.56),
  IlKonum('Elazığ', 38.68, 39.22),
  IlKonum('Erzincan', 39.75, 39.50),
  IlKonum('Erzurum', 39.90, 41.27),
  IlKonum('Eskişehir', 39.78, 30.52),
  IlKonum('Gaziantep', 37.07, 37.38),
  IlKonum('Giresun', 40.91, 38.39),
  IlKonum('Gümüşhane', 40.46, 39.48),
  IlKonum('Hakkari', 37.57, 43.74),
  IlKonum('Hatay', 36.20, 36.16),
  IlKonum('Isparta', 37.76, 30.55),
  IlKonum('Mersin', 36.81, 34.64),
  IlKonum('İstanbul', 41.01, 28.98),
  IlKonum('İzmir', 38.42, 27.14),
  IlKonum('Kars', 40.60, 43.10),
  IlKonum('Kastamonu', 41.39, 33.78),
  IlKonum('Kayseri', 38.73, 35.49),
  IlKonum('Kırklareli', 41.74, 27.22),
  IlKonum('Kırşehir', 39.15, 34.16),
  IlKonum('Kocaeli', 40.77, 29.92),
  IlKonum('Konya', 37.87, 32.48),
  IlKonum('Kütahya', 39.42, 29.98),
  IlKonum('Malatya', 38.36, 38.31),
  IlKonum('Manisa', 38.61, 27.43),
  IlKonum('Kahramanmaraş', 37.58, 36.93),
  IlKonum('Mardin', 37.31, 40.74),
  IlKonum('Muğla', 37.22, 28.36),
  IlKonum('Muş', 38.74, 41.49),
  IlKonum('Nevşehir', 38.62, 34.71),
  IlKonum('Niğde', 37.97, 34.68),
  IlKonum('Ordu', 40.98, 37.88),
  IlKonum('Rize', 41.02, 40.52),
  IlKonum('Sakarya', 40.78, 30.40),
  IlKonum('Samsun', 41.29, 36.33),
  IlKonum('Siirt', 37.93, 41.94),
  IlKonum('Sinop', 42.03, 35.15),
  IlKonum('Sivas', 39.75, 37.02),
  IlKonum('Tekirdağ', 40.98, 27.51),
  IlKonum('Tokat', 40.31, 36.55),
  IlKonum('Trabzon', 41.00, 39.72),
  IlKonum('Tunceli', 39.11, 39.55),
  IlKonum('Şanlıurfa', 37.17, 38.79),
  IlKonum('Uşak', 38.68, 29.41),
  IlKonum('Van', 38.49, 43.41),
  IlKonum('Yozgat', 39.82, 34.81),
  IlKonum('Zonguldak', 41.45, 31.79),
  IlKonum('Aksaray', 38.37, 34.03),
  IlKonum('Bayburt', 40.26, 40.22),
  IlKonum('Karaman', 37.18, 33.22),
  IlKonum('Kırıkkale', 39.85, 33.52),
  IlKonum('Batman', 37.88, 41.13),
  IlKonum('Şırnak', 37.52, 42.46),
  IlKonum('Bartın', 41.64, 32.34),
  IlKonum('Ardahan', 41.11, 42.70),
  IlKonum('Iğdır', 39.92, 44.04),
  IlKonum('Yalova', 40.66, 29.28),
  IlKonum('Karabük', 41.20, 32.62),
  IlKonum('Kilis', 36.72, 37.12),
  IlKonum('Osmaniye', 37.07, 36.25),
  IlKonum('Düzce', 40.84, 31.16),
];

/// Alfabetik il adları (dropdown için).
List<String> get kIlAdlariAlfabetik {
  final list = kIller.map((e) => e.ad).toList()..sort();
  return list;
}

IlKonum? _ilByAd(String ad) {
  for (final il in kIller) {
    if (il.ad == ad) return il;
  }
  return null;
}

double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0; // Dünya yarıçapı (km)
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_deg2rad(lat1)) *
          math.cos(_deg2rad(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return r * c;
}

double _deg2rad(double d) => d * math.pi / 180.0;

/// Kuş uçuşu mesafe (km), il koordinatlarından.
double ilMesafeKusUcusuKm(String fromAd, String toAd) {
  final a = _ilByAd(fromAd);
  final b = _ilByAd(toAd);
  if (a == null || b == null) return 0;
  if (a.ad == b.ad) return 0;
  return _haversineKm(a.lat, a.lng, b.lat, b.lng);
}

String _ilCiftAnahtari(String a, String b) {
  final s = [a, b]..sort();
  return '${s[0]}|${s[1]}';
}

/// KGM / karayolu cetveline yakın bilinen il merkezi mesafeleri (km).
/// Listede yoksa kuş uçuşu × katsayı ile tahmin edilir.
const Map<String, int> _mesafeCetvelKm = {
  'Ankara|İstanbul': 452,
  'Ankara|İzmir': 580,
  'Ankara|Antalya': 482,
  'Ankara|Bursa': 384,
  'Ankara|Adana': 480,
  'Ankara|Konya': 258,
  'Ankara|Samsun': 410,
  'Ankara|Trabzon': 593,
  'Ankara|Erzurum': 892,
  'Ankara|Diyarbakır': 975,
  'Ankara|Gaziantep': 678,
  'İstanbul|İzmir': 480,
  'İzmir|Antalya': 448,
  'İzmir|Denizli': 220,
  'İzmir|Bursa': 330,
  'Bursa|Antalya': 450,
  'Denizli|Diyarbakır': 1243,
  'Denizli|Ankara': 482,
  'Antalya|Adana': 546,
  'Gaziantep|Şanlıurfa': 148,
  'Diyarbakır|Gaziantep': 335,
  'Erzurum|Trabzon': 285,
  'Samsun|Trabzon': 245,
};

/// KGM karayolu cetveline yaklaşmak için kuş uçuşu mesafeye göre katsayı (yedek).
double _karayoluKatsayisi(double straightKm) {
  if (straightKm <= 0) return 1.27;
  if (straightKm < 300) return 1.32;
  if (straightKm < 550) return 1.22;
  return 1.27;
}

/// İki il arası tahmini karayolu mesafesi (km).
int ilMesafeKm(String fromAd, String toAd) {
  final a = _ilByAd(fromAd);
  final b = _ilByAd(toAd);
  if (a == null || b == null) return 0;
  if (a.ad == b.ad) return 0;

  final cetvel = _mesafeCetvelKm[_ilCiftAnahtari(fromAd, toAd)];
  if (cetvel != null) return cetvel;

  final straight = _haversineKm(a.lat, a.lng, b.lat, b.lng);
  return (straight * _karayoluKatsayisi(straight)).round();
}

/// Yol izni günü: >600 km → 4 gün, 0<km≤600 → 2 gün, aynı il / mesafe yok → 0.
int yolIzniGunu(int km) {
  if (km <= 0) return 0;
  return km > 600 ? 4 : 2;
}
