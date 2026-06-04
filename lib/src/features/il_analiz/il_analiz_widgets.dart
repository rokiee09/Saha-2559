import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/theme/police_colors.dart';
import 'il_analiz_display.dart';
import 'il_analiz_models.dart';

Color _tazminatRenk(int derece) {
  switch (derece) {
    case 1:
      return const Color(0xFFE53935);
    case 2:
      return const Color(0xFFFB8C00);
    case 3:
      return const Color(0xFF2D7EFF);
    case 4:
      return const Color(0xFF43A047);
    default:
      return PoliceColors.gold;
  }
}

class IlSkorBar extends StatelessWidget {
  const IlSkorBar({
    super.key,
    required this.label,
    this.value,
    this.color,
  });

  final String label;
  final int? value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? PoliceColors.primaryBlue;
    final v = value?.clamp(0, 100);
    final display = v != null ? '$v' : kIlAnalizBosDash;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.95),
                    fontSize: 12.5,
                  ),
                ),
              ),
              Text(
                display,
                style: TextStyle(
                  color: v != null
                      ? PoliceColors.titleOnDark
                      : PoliceColors.textMuted.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: v != null ? v / 100 : 0,
              minHeight: 6,
              backgroundColor: PoliceColors.surfaceDarkElevated,
              color: v != null ? c : PoliceColors.mevzuatListBorder.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class IlHeroCard extends StatelessWidget {
  const IlHeroCard({super.key, required this.profil});

  final IlAnalizProfil profil;

  @override
  Widget build(BuildContext context) {
    final p = profil.puanlar;
    final gp = profil.polis.gorevPuani;
    final tz = profil.polis.tazminatDerece;
    final ek = profil.polis.ekTazminatTl;
    final ekMetin = formatIlTl(ek);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PoliceColors.navy,
            PoliceColors.surfaceDarkElevated,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PoliceColors.primaryBlue.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: PoliceColors.primaryBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  profil.plaka,
                  style: TextStyle(
                    color: PoliceColors.primaryBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profil.ad,
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (ilHeroAltBaslik(profil).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        ilHeroAltBaslik(profil),
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (gp != null) ...[
                    Text(
                      formatIlGorevPuani(gp),
                      style: const TextStyle(
                        color: PoliceColors.primaryBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Görev puanı',
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                  if (tz != null) ...[
                    if (gp != null) const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _tazminatRenk(tz).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ekMetin.isNotEmpty
                            ? '$tz. derece · $ekMetin'
                            : '$tz. derece',
                        style: TextStyle(
                          color: _tazminatRenk(tz),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          IlSkorBar(
            label: 'Polis dostu yaşam',
            value: p.polisYasam,
            color: PoliceColors.primaryBlue,
          ),
          IlSkorBar(
            label: 'Aile uygunluk',
            value: p.aile,
            color: PoliceColors.saglikAccent,
          ),
          IlSkorBar(
            label: 'Bekar personel',
            value: p.bekar,
            color: PoliceColors.emeklilikAccent,
          ),
          IlSkorBar(
            label: 'Emeklilik uygunluk',
            value: p.emeklilik,
            color: PoliceColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}

/// Sabit şablon bölüm kartı — tüm satırlar gösterilir.
Widget ilBolumKartiSablon({
  required String title,
  required IconData icon,
  required Color accent,
  required List<IlMetricRow> satirlar,
  String? kaynak,
}) {
  return IlSectionCard(
    title: title,
    icon: icon,
    accent: accent,
    kaynak: kaynak,
    children: satirlar,
  );
}

IlMetricRow ilMetrikZorunlu(IconData icon, String label, String value) {
  final v = value.trim();
  return IlMetricRow(
    icon: icon,
    label: label,
    value: v.isEmpty ? kIlAnalizBosDash : v,
  );
}

/// Dolu satırlardan bölüm kartı; hepsi boşsa gösterilmez.
Widget? ilBolumKarti({
  required String title,
  required IconData icon,
  required Color accent,
  required List<Widget?> satirlar,
  String? kaynak,
}) {
  final rows = satirlar.whereType<Widget>().toList();
  if (rows.isEmpty) return null;
  return IlSectionCard(
    title: title,
    icon: icon,
    accent: accent,
    kaynak: kaynak,
    children: rows,
  );
}

IlMetricRow? ilMetrik(IconData icon, String label, String value) {
  final v = value.trim();
  if (v.isEmpty) return null;
  return IlMetricRow(icon: icon, label: label, value: v);
}

class IlSectionCard extends StatelessWidget {
  const IlSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.children,
    this.kaynak,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<Widget> children;
  final String? kaynak;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PoliceColors.mevzuatListBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Column(children: children),
          ),
          if (ilMetinDolu(kaynak))
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(
                'Kaynak: $kaynak',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.65),
                  fontSize: 10.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class IlMetricRow extends StatelessWidget {
  const IlMetricRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: PoliceColors.textMuted.withValues(alpha: 0.85)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.95),
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: value == kIlAnalizBosDash
                  ? PoliceColors.textMuted.withValues(alpha: 0.65)
                  : PoliceColors.titleOnDark,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class IlAiOzetCard extends StatelessWidget {
  const IlAiOzetCard({super.key, required this.metin});

  final String metin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceColors.primaryBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            PhosphorIconsRegular.sparkle,
            color: PoliceColors.primaryBlue.withValues(alpha: 0.9),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Özet değerlendirme',
                  style: TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  metin,
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.95),
                    height: 1.45,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IlceMiniCard extends StatelessWidget {
  const IlceMiniCard({super.key, required this.ilce, this.onTap});

  final IlceAnaliz ilce;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: PoliceColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ilce.ad,
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (ilce.gorevYil != null)
                    Text(
                      '${ilce.gorevYil} yıl',
                      style: TextStyle(
                        color: PoliceColors.gold.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              if (ilce.yasam != null ||
                  ilce.aile != null ||
                  ilce.isYuku != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (ilce.yasam != null) _chip('Yaşam', ilce.yasam!),
                    if (ilce.aile != null) _chip('Aile', ilce.aile!),
                    if (ilce.isYuku != null)
                      _chip('İş yükü', ilce.isYuku!, invert: true),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, int v, {bool invert = false}) {
    final color = invert
        ? (v >= 70 ? PoliceColors.emeklilikSliceRed : PoliceColors.primaryBlue)
        : (v >= 70 ? PoliceColors.primaryBlue : PoliceColors.textMuted);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label $v',
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}
