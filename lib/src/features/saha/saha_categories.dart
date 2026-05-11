import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Yerel not kutuları — hukuki kayıt veya resmi belge değildir; yalnızca hatırlatma.
class SahaCategoryDef {
  const SahaCategoryDef({
    required this.id,
    required this.title,
    required this.icon,
  });

  final String id;
  final String title;
  final IconData icon;

  static const List<SahaCategoryDef> all = [
    SahaCategoryDef(id: 'harcama', title: 'Harcamalarım', icon: PhosphorIconsRegular.wallet),
    SahaCategoryDef(id: 'izin', title: 'İzin takip', icon: PhosphorIconsRegular.calendarBlank),
    SahaCategoryDef(id: 'rehber', title: 'Rehber', icon: PhosphorIconsRegular.addressBook),
    SahaCategoryDef(id: 'tutanak', title: 'Tutanaklarım', icon: PhosphorIconsRegular.clipboardText),
    SahaCategoryDef(id: 'arac', title: 'Araç notları', icon: PhosphorIconsRegular.car),
    SahaCategoryDef(id: 'gozlem', title: 'Gözlem notları', icon: PhosphorIconsRegular.eye),
    SahaCategoryDef(id: 'arama_karari', title: 'Arama kararı', icon: PhosphorIconsRegular.shield),
    SahaCategoryDef(id: 'telsiz', title: 'Telsiz kodları', icon: PhosphorIconsRegular.broadcast),
    SahaCategoryDef(id: 'kamera', title: 'Kamera notları', icon: PhosphorIconsRegular.camera),
    SahaCategoryDef(id: 'cay', title: 'Çay ocağı', icon: PhosphorIconsRegular.coffee),
  ];

  static SahaCategoryDef? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}
