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
        id: 'notlar', title: 'Notlar', icon: PhosphorIconsRegular.notebook),
    SahaCategoryDef(
        id: 'o1_gider',
        title: 'O-1 Giderleri',
        icon: PhosphorIconsRegular.receipt),
    SahaCategoryDef(
        id: 'izin',
        title: 'İzinlerim',
        icon: PhosphorIconsRegular.calendarCheck),
    SahaCategoryDef(
        id: 'tutanak',
        title: 'Tutanaklarım',
        icon: PhosphorIconsRegular.fileText),
    SahaCategoryDef(
        id: 'arama_karari',
        title: 'Arama Kararları',
        icon: PhosphorIconsRegular.scales),
    SahaCategoryDef(
        id: 'gorev_gunlugu',
        title: 'Görev Günlüğüm',
        icon: PhosphorIconsRegular.clipboardText),
    SahaCategoryDef(
        id: 'atis_takip',
        title: 'Atış Takibim',
        icon: PhosphorIconsRegular.target),
  ];

  static SahaCategoryDef? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}
