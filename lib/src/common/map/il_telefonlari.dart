// İl emniyet (tanıtım) telefonları — yalnızca rakam (tel: URI için).
// Kaynak: assets/json/city_contacts.json ile uyumlu; güncel numara kurum onayıyla doğrulanmalıdır.
//
// Arama anahtarları: normalize edilmiş il adı (ör. "istanbul", "adiyaman") veya
// 2 haneli plaka ("34", "06").

import 'package:flutter/foundation.dart';

/// Telefonu yalnızca rakam (tel: URI).
String phoneDigitsForDial(String raw) {
  return raw.replaceAll(RegExp(r'\D'), '');
}

/// Telefonu yalnızca rakam + baştaki 0.
@visibleForTesting
String digitsOnly(String raw) {
  return phoneDigitsForDial(raw);
}

/// SVG id / il adı için tek tip anahtar (küçük harf, Türkçe harfsiz).
String normalizeIlKey(String raw) {
  var s = raw.trim().toLowerCase();
  s = s.replaceAll('ı', 'i');
  s = s.replaceAll('ğ', 'g');
  s = s.replaceAll('ü', 'u');
  s = s.replaceAll('ş', 's');
  s = s.replaceAll('ö', 'o');
  s = s.replaceAll('ç', 'c');
  s = s.replaceAll('â', 'a');
  s = s.replaceAll('î', 'i');
  s = s.replaceAll('û', 'u');
  s = s.replaceAll(' ', '');
  return s;
}

/// Plaka kodu (01–81) — SVG path `id` bazen plaka olur.
const Map<String, String> plakaToIlKey = {
  '01': 'adana',
  '02': 'adiyaman',
  '03': 'afyonkarahisar',
  '04': 'agri',
  '05': 'amasya',
  '06': 'ankara',
  '07': 'antalya',
  '08': 'artvin',
  '09': 'aydin',
  '10': 'balikesir',
  '11': 'bilecik',
  '12': 'bingol',
  '13': 'bitlis',
  '14': 'bolu',
  '15': 'burdur',
  '16': 'bursa',
  '17': 'canakkale',
  '18': 'cankiri',
  '19': 'corum',
  '20': 'denizli',
  '21': 'diyarbakir',
  '22': 'edirne',
  '23': 'elazig',
  '24': 'erzincan',
  '25': 'erzurum',
  '26': 'eskisehir',
  '27': 'gaziantep',
  '28': 'giresun',
  '29': 'gumushane',
  '30': 'hakkari',
  '31': 'hatay',
  '32': 'isparta',
  '33': 'mersin',
  '34': 'istanbul',
  '35': 'izmir',
  '36': 'kars',
  '37': 'kastamonu',
  '38': 'kayseri',
  '39': 'kirklareli',
  '40': 'kirsehir',
  '41': 'kocaeli',
  '42': 'konya',
  '43': 'kutahya',
  '44': 'malatya',
  '45': 'manisa',
  '46': 'kahramanmaras',
  '47': 'mardin',
  '48': 'mugla',
  '49': 'mus',
  '50': 'nevsehir',
  '51': 'nigde',
  '52': 'ordu',
  '53': 'rize',
  '54': 'sakarya',
  '55': 'samsun',
  '56': 'siirt',
  '57': 'sinop',
  '58': 'sivas',
  '59': 'tekirdag',
  '60': 'tokat',
  '61': 'trabzon',
  '62': 'tunceli',
  '63': 'sanliurfa',
  '64': 'usak',
  '65': 'van',
  '66': 'yozgat',
  '67': 'zonguldak',
  '68': 'aksaray',
  '69': 'bayburt',
  '70': 'karaman',
  '71': 'kirikkale',
  '72': 'batman',
  '73': 'sirnak',
  '74': 'bartin',
  '75': 'ardahan',
  '76': 'igdir',
  '77': 'yalova',
  '78': 'karabuk',
  '79': 'kilis',
  '80': 'osmaniye',
  '81': 'duzce',
};

/// İl anahtarı → 2 haneli plaka (`01`–`81`).
String? plakaKoduForIlKey(String ilKey) {
  for (final e in plakaToIlKey.entries) {
    if (e.value == ilKey) {
      return e.key;
    }
  }
  return null;
}

const Map<String, String> kIlGosterimAdi = {
  'adana': 'Adana',
  'adiyaman': 'Adıyaman',
  'afyonkarahisar': 'Afyonkarahisar',
  'agri': 'Ağrı',
  'aksaray': 'Aksaray',
  'amasya': 'Amasya',
  'ankara': 'Ankara',
  'antalya': 'Antalya',
  'ardahan': 'Ardahan',
  'artvin': 'Artvin',
  'aydin': 'Aydın',
  'balikesir': 'Balıkesir',
  'bartin': 'Bartın',
  'batman': 'Batman',
  'bayburt': 'Bayburt',
  'bilecik': 'Bilecik',
  'bingol': 'Bingöl',
  'bitlis': 'Bitlis',
  'bolu': 'Bolu',
  'burdur': 'Burdur',
  'bursa': 'Bursa',
  'canakkale': 'Çanakkale',
  'cankiri': 'Çankırı',
  'corum': 'Çorum',
  'denizli': 'Denizli',
  'diyarbakir': 'Diyarbakır',
  'duzce': 'Düzce',
  'edirne': 'Edirne',
  'elazig': 'Elazığ',
  'erzincan': 'Erzincan',
  'erzurum': 'Erzurum',
  'eskisehir': 'Eskişehir',
  'gaziantep': 'Gaziantep',
  'giresun': 'Giresun',
  'gumushane': 'Gümüşhane',
  'hakkari': 'Hakkari',
  'hatay': 'Hatay',
  'igdir': 'Iğdır',
  'isparta': 'Isparta',
  'istanbul': 'İstanbul',
  'izmir': 'İzmir',
  'kahramanmaras': 'Kahramanmaraş',
  'karabuk': 'Karabük',
  'karaman': 'Karaman',
  'kars': 'Kars',
  'kastamonu': 'Kastamonu',
  'kayseri': 'Kayseri',
  'kirikkale': 'Kırıkkale',
  'kirklareli': 'Kırklareli',
  'kirsehir': 'Kırşehir',
  'kilis': 'Kilis',
  'kocaeli': 'Kocaeli',
  'konya': 'Konya',
  'kutahya': 'Kütahya',
  'malatya': 'Malatya',
  'manisa': 'Manisa',
  'mardin': 'Mardin',
  'mersin': 'Mersin',
  'mugla': 'Muğla',
  'mus': 'Muş',
  'nevsehir': 'Nevşehir',
  'nigde': 'Niğde',
  'ordu': 'Ordu',
  'osmaniye': 'Osmaniye',
  'rize': 'Rize',
  'sakarya': 'Sakarya',
  'samsun': 'Samsun',
  'sanliurfa': 'Şanlıurfa',
  'siirt': 'Siirt',
  'sinop': 'Sinop',
  'sirnak': 'Şırnak',
  'sivas': 'Sivas',
  'tekirdag': 'Tekirdağ',
  'tokat': 'Tokat',
  'trabzon': 'Trabzon',
  'tunceli': 'Tunceli',
  'usak': 'Uşak',
  'van': 'Van',
  'yalova': 'Yalova',
  'yozgat': 'Yozgat',
  'zonguldak': 'Zonguldak',
};

/// Simplemaps vb. SVG: `TR34` → `34` (json [plateCode] ile eşleşir).
String plateCodeFromTrSvgId(String svgId) {
  var s = svgId.trim();
  if (s.length >= 2 && s.toUpperCase().startsWith('TR')) {
    s = s.replaceFirst(RegExp(r'^TR', caseSensitive: false), '');
  }
  if (s.length == 1 && RegExp(r'^\d$').hasMatch(s)) {
    return '0$s';
  }
  return s;
}

/// `id`: SVG `path` id (plaka 01–81 veya normalize il adı).
String? emniyetTelefonHanesiId(String id) {
  var t = id.trim();
  if (t.isEmpty) return null;
  if (t.length >= 3 && t.toUpperCase().startsWith('TR')) {
    t = plateCodeFromTrSvgId(t);
  }
  if (t.length == 1 && RegExp(r'^\d$').hasMatch(t)) {
    return kIlHanesi[plakaToIlKey['0$t']];
  }
  if (t.length == 2 && RegExp(r'^\d{2}$').hasMatch(t)) {
    return kIlHanesi[plakaToIlKey[t]];
  }
  return kIlHanesi[normalizeIlKey(t)];
}

const Map<String, String> kIlHanesi = {
  'adana': '03223221515',
  'adiyaman': '04162161515',
  'afyonkarahisar': '02722131515',
  'agri': '04722151515',
  'aksaray': '03822121515',
  'amasya': '03582181515',
  'ankara': '03124125833',
  'antalya': '02422271515',
  'ardahan': '04782111515',
  'artvin': '04662121515',
  'aydin': '02562131515',
  'balikesir': '02662451515',
  'bartin': '03782271515',
  'batman': '04882151515',
  'bayburt': '04582111515',
  'bilecik': '02282121515',
  'bingol': '04262131515',
  'bitlis': '04342261515',
  'bolu': '03742701515',
  'burdur': '02482331515',
  'bursa': '02242721515',
  'canakkale': '02862171515',
  'cankiri': '03762131515',
  'corum': '03642241515',
  'denizli': '02582651515',
  'diyarbakir': '04122281515',
  'duzce': '03805241515',
  'edirne': '02842141515',
  'elazig': '04242331515',
  'erzincan': '04462241515',
  'erzurum': '04422351515',
  'eskisehir': '02222301515',
  'gaziantep': '03422301515',
  'giresun': '04542161515',
  'gumushane': '04562131515',
  'hakkari': '04382111515',
  'hatay': '03262141515',
  'igdir': '04762271515',
  'isparta': '02462181515',
  'istanbul': '02126350000',
  'izmir': '02324891515',
  'kahramanmaras': '03442351515',
  'karabuk': '03704241515',
  'karaman': '03382131515',
  'kars': '04742121515',
  'kastamonu': '03662141515',
  'kayseri': '03523201515',
  'kirikkale': '03182241515',
  'kirklareli': '02882141515',
  'kirsehir': '03862131515',
  'kilis': '03488131515',
  'kocaeli': '02623211515',
  'konya': '03323531515',
  'kutahya': '02742241515',
  'malatya': '04223231515',
  'manisa': '02362311515',
  'mardin': '04822121515',
  'mersin': '03242371515',
  'mugla': '02522141515',
  'mus': '04362121515',
  'nevsehir': '03842131515',
  'nigde': '03882321515',
  'ordu': '04522261515',
  'osmaniye': '03288131515',
  'rize': '04642141515',
  'sakarya': '02642761515',
  'samsun': '03624311515',
  'sanliurfa': '04143151515',
  'siirt': '04842231515',
  'sinop': '03682611515',
  'sirnak': '04862161515',
  'sivas': '03462241515',
  'tekirdag': '02822611515',
  'tokat': '03562141515',
  'trabzon': '04623261515',
  'tunceli': '04282131515',
  'usak': '02762271515',
  'van': '04322151515',
  'yalova': '02268131515',
  'yozgat': '03542121515',
  'zonguldak': '03722531515',
};

String? gosterimAdiForIlKey(String? ilKey) {
  if (ilKey == null) return null;
  return kIlGosterimAdi[ilKey] ?? ilKey;
}

/// [city_contacts] içindeki `cityName` ile bire bir eşleşir (Türkçe büyük/küçük harf, İ/Ğ dâhil).
String? ilKeyForGosterimAdi(String? cityName) {
  if (cityName == null) return null;
  final t = cityName.trim();
  if (t.isEmpty) return null;
  for (final e in kIlGosterimAdi.entries) {
    if (e.value == t) {
      return e.key;
    }
  }
  return null;
}

/// SVG `path` / grup `id` (plaka veya normalize isim) → iç anahtar.
String? ilKeyFromHitId(String raw) {
  var t = raw.trim();
  if (t.isEmpty) return null;
  if (t.length >= 3 && t.toUpperCase().startsWith('TR')) {
    t = plateCodeFromTrSvgId(t);
  }
  if (t.length == 1 && RegExp(r'^\d$').hasMatch(t)) {
    return plakaToIlKey['0$t'];
  }
  if (t.length == 2 && RegExp(r'^\d{2}$').hasMatch(t)) {
    return plakaToIlKey[t];
  }
  final k = normalizeIlKey(t);
  if (kIlHanesi.containsKey(k)) return k;
  return null;
}
