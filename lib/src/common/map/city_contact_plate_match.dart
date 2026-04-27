import '../../data/models/city_contact.dart';
import 'il_telefonlari.dart';

/// [plateCode] — json `plateCode` / SVG `TR` sonrası (`34`, `06`) ile Isar/listedeki [CityContact] eşlemesi.
CityContact? findCityContactByPlateCode(
  Iterable<CityContact> cities,
  String plateCode,
) {
  final norm = plateCode.trim();
  if (norm.isEmpty) {
    return null;
  }
  for (final c in cities) {
    final k = ilKeyForGosterimAdi(c.cityName);
    if (k == null) {
      continue;
    }
    final p = plakaKoduForIlKey(k);
    if (p == norm) {
      return c;
    }
  }
  return null;
}
