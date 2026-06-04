import '../araclar/gorev_puanlari/gorev_puanlari_data.dart';
import 'il_analiz_models.dart';

/// Boş değer gösterimi — satır gizlenir.
const String kIlAnalizBosGosterim = '';

/// Sabit şablonda boş alan gösterimi.
const String kIlAnalizBosDash = '—';

bool ilMetinDolu(String? s) => s != null && s.trim().isNotEmpty;

bool ilSayiDolu(int? n) => n != null;

bool ilBoolGosterilebilir(bool? v) => v != null;

String formatIlMetin(String? s) =>
    ilMetinDolu(s) ? s!.trim() : kIlAnalizBosGosterim;

String formatIlNufus(int? n) {
  if (n == null) return kIlAnalizBosGosterim;
  final s = n.toString();
  if (s.length <= 3) return s;
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

String formatIlTl(int? v) {
  if (v == null || v <= 0) return kIlAnalizBosGosterim;
  return '${formatIlNufus(v)} TL';
}

String formatIlSayi(int? n) => n != null ? '$n' : kIlAnalizBosGosterim;

/// Görev puanı — cetveldeki 1.978 biçimi (milli saklama).
String formatIlGorevPuani(int? milli) {
  if (milli == null) return kIlAnalizBosGosterim;
  return formatGorevPuani(milli / 1000.0);
}

String formatIlMetinVeyaDash(String? s) {
  final v = formatIlMetin(s);
  return v.isEmpty ? kIlAnalizBosDash : v;
}

String formatIlSayiVeyaDash(int? n) =>
    n != null ? '$n' : kIlAnalizBosDash;

String formatIlTlVeyaDash(int? v) {
  final t = formatIlTl(v);
  return t.isEmpty ? kIlAnalizBosDash : t;
}

String formatIlGorevPuaniVeyaDash(int? milli) {
  final g = formatIlGorevPuani(milli);
  return g.isEmpty ? kIlAnalizBosDash : g;
}

String formatIlTazminatDereceVeyaDash(int? derece) {
  final d = formatIlTazminatDerece(derece);
  return d.isEmpty ? kIlAnalizBosDash : d;
}

String formatIlYasamIndeksiSiraVeyaDash(int? sira, {int? yil}) {
  final y = formatIlYasamIndeksiSira(sira, yil: yil);
  return y.isEmpty ? kIlAnalizBosDash : y;
}

String formatIlEvetHayirVeyaDash(bool? v) {
  if (v == null) return kIlAnalizBosDash;
  return v ? 'Evet' : 'Hayır';
}

String formatIlBoolVeyaDash(bool? v, {String evet = 'Var', String hayir = 'Yok'}) {
  if (v == null) return kIlAnalizBosDash;
  return v ? evet : hayir;
}

String formatIlYilVeyaDash(int? y) =>
    y != null ? '$y yıl' : kIlAnalizBosDash;

String formatIlBool(bool? v, {String evet = 'Var', String hayir = 'Yok'}) {
  if (v == null) return kIlAnalizBosGosterim;
  return v ? evet : hayir;
}

String formatIlEvetHayir(bool? v) {
  if (v == null) return kIlAnalizBosGosterim;
  return v ? 'Evet' : 'Hayır';
}

String formatIlYil(int? y) =>
    y != null ? '$y yıl' : kIlAnalizBosGosterim;

String formatIlTazminatDerece(int? derece) {
  if (derece == null) return kIlAnalizBosGosterim;
  return '$derece. derece';
}

String formatIlYasamIndeksiSira(int? sira, {int? yil}) {
  if (sira == null) return kIlAnalizBosGosterim;
  final y = yil != null ? ' ($yil)' : '';
  return '$sira/81$y';
}

String formatIlNufusVeyaDash(int? n) {
  final v = formatIlNufus(n);
  return v.isEmpty ? kIlAnalizBosDash : v;
}

/// TÜİK sırasından 0–100 görsel skor (1. sıra ≈ 100) — yalnızca profil çubukları için.
int yasamSkorFromSira(int sira) {
  final v = ((82 - sira) / 81 * 100).round();
  return v.clamp(1, 100);
}

/// Liste kartı skoru — yalnızca en az bir puan varsa (editör profili 0–100).
int? ilGenelSkor(IlAnalizPuanlar p) {
  final vals = [
    p.polisYasam,
    p.aile,
    p.bekar,
  ].whereType<int>().toList();
  if (vals.isEmpty) return null;
  return (vals.reduce((a, b) => a + b) / vals.length).round();
}

/// İl listesi alt satırı — bölge, görev puanı, tazminat (yalnızca dolu alanlar).
String ilListePolisOzeti(IlAnalizProfil p) {
  final parts = <String>[];
  if (ilMetinDolu(p.bolge)) parts.add(p.bolge!);
  if (p.polis.gorevPuani != null) {
    parts.add('GP ${formatIlGorevPuani(p.polis.gorevPuani)}');
  }
  if (p.polis.tazminatDerece != null) {
    parts.add(formatIlTazminatDerece(p.polis.tazminatDerece));
  }
  if (p.polis.ekTazminatTl != null && p.polis.ekTazminatTl! > 0) {
    parts.add(formatIlTl(p.polis.ekTazminatTl));
  }
  if (p.genel.yasamIndeksiSira != null) {
    parts.add('Yaşam ${p.genel.yasamIndeksiSira}/81');
  }
  return parts.join(' · ');
}

/// Hero alt başlık: yalnızca dolu parçalar.
String ilHeroAltBaslik(IlAnalizProfil p) {
  final parts = <String>[];
  if (ilMetinDolu(p.bolge)) parts.add(p.bolge!);
  if (p.buyuksehir == true) {
    parts.add('Büyükşehir');
  } else if (p.buyuksehir == false) {
    parts.add('İl');
  }
  return parts.isEmpty ? kIlAnalizBosGosterim : parts.join(' · ');
}
