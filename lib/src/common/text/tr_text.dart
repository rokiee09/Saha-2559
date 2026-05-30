// Türkçe metin karşılaştırma yardımcıları.
//
// Dart'ın `String.toLowerCase()` çağrısı Türkçe-duyarlı değildir:
// `'İ'.toLowerCase()` → "i̇" (i + birleşik nokta, 2 kod birimi) ve
// `'I'.toLowerCase()` → "i" üretir. Bu yüzden büyük/küçük harf dönüşümünden
// ÖNCE Türkçe büyük harfleri (İ, I) elle eşliyoruz. Aksi halde arama
// "İ" içeren metinlerde (ör. "İFADE", "İZİN") eşleşmeyi kaçırır.

/// Türkçe-duyarlı küçük harfe çevirme.
String trLower(String input) {
  return input.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();
}

const Map<String, String> _foldMap = {
  'ç': 'c',
  'ğ': 'g',
  'ı': 'i',
  'ö': 'o',
  'ş': 's',
  'ü': 'u',
  'â': 'a',
  'î': 'i',
  'û': 'u',
};

/// Aksanları/Türkçe karakterleri ASCII'ye indirger (ç→c, ş→s, ı→i …) ve
/// küçük harfe çevirir. Böylece "şırnak" ↔ "sirnak" gibi yazımlar eşleşir.
String trFold(String input) {
  final lower = trLower(input);
  final sb = StringBuffer();
  for (final ch in lower.split('')) {
    sb.write(_foldMap[ch] ?? ch);
  }
  return sb.toString();
}
