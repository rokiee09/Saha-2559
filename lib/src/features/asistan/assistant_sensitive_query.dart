import '../../common/text/tr_text.dart';

/// Operasyonel / hassas nitelikteki sorgular — cevap üretilmez.
class AssistantSensitiveQuery {
  AssistantSensitiveQuery._();

  static const patterns = [
    'baskin',
    'operasyonel taktik',
    'gizli yontem',
    'gizli takip',
    'istihbarat toplama',
    'sorgu yontemi',
    'teknik takip',
    'infaz takip',
    'casusluk',
    'mahkemesiz takip',
    'taktik',
    'operasyon plan',
  ];

  static const message =
      'Bu konu operasyonel veya hassas nitelikte olabilir. Uygulama yalnızca '
      'mevzuat ve bilgilendirme amaçlı yerel kaynak eşlemesi yapar; taktik veya '
      'operasyonel yönlendirme vermez. İlgili mevzuat için Mevzuat sekmesini kullanın.';

  static bool matches(String raw) {
    final q = trFold(raw.trim());
    if (q.length < 2) return false;
    for (final p in patterns) {
      if (q.contains(p)) return true;
    }
    return false;
  }
}
