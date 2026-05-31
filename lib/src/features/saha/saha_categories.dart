import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

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
    SahaCategoryDef(
        id: 'notlar', title: 'Notlar', icon: PhosphorIconsRegular.notePencil),
    SahaCategoryDef(
        id: 'o1_gider',
        title: 'O-1 giderleri',
        icon: PhosphorIconsRegular.receipt),
    SahaCategoryDef(
        id: 'izin',
        title: 'İzin takip',
        icon: PhosphorIconsRegular.calendarBlank),
    SahaCategoryDef(
        id: 'tutanak',
        title: 'Tutanaklarım',
        icon: PhosphorIconsRegular.clipboardText),
    SahaCategoryDef(
        id: 'arama_karari',
        title: 'Arama kararı',
        icon: PhosphorIconsRegular.shield),
    SahaCategoryDef(
        id: 'telsiz',
        title: 'Telsiz kodları',
        icon: PhosphorIconsRegular.broadcast),
  ];

  static SahaCategoryDef? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}
