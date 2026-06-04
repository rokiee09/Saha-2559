import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../common/text/tr_text.dart';
import '../../../../common/theme/police_colors.dart';
import '../idari_para_ceza_data.dart';

class IdariParaCezaCard extends StatelessWidget {
  const IdariParaCezaCard({
    super.key,
    required this.kayit,
    this.favori = false,
    this.onFavoriteToggle,
    this.compact = false,
    this.onOpenModule,
  });

  final IdariParaCezaKayit kayit;
  final bool favori;
  final VoidCallback? onFavoriteToggle;
  final bool compact;
  final VoidCallback? onOpenModule;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PoliceColors.surfaceDark,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: PoliceColors.accentMix(0.28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayKabahatAdi(kayit.kabahatAdi),
                        style: const TextStyle(
                          color: PoliceColors.titleOnDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_titleKanun(kayit.kanun)} · ${kayit.madde}',
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.92),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCD34D).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFCD34D).withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        kayit.cezaMetni,
                        style: const TextStyle(
                          color: Color(0xFFFCD34D),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (onFavoriteToggle != null) ...[
                      const SizedBox(height: 4),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: favori ? 'Favoriden çıkar' : 'Favorilere ekle',
                        onPressed: onFavoriteToggle,
                        icon: PhosphorIcon(
                          favori
                              ? PhosphorIconsFill.star
                              : PhosphorIconsRegular.star,
                          color: favori
                              ? const Color(0xFFFCD34D)
                              : PoliceColors.textMuted,
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (!compact) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: PhosphorIconsRegular.gavel,
                label: 'Karar veren',
                value: kayit.kararVerenMakam,
              ),
              _InfoRow(
                icon: PhosphorIconsRegular.scales,
                label: 'İtiraz mercii',
                value: kayit.itirazMercii,
              ),
              _InfoRow(
                icon: PhosphorIconsRegular.clock,
                label: 'İtiraz / ödeme',
                value:
                    '${kayit.itirazSuresi} · Ödeme: ${kayit.odemeSuresi}',
              ),
              if (kayit.belge.isNotEmpty)
                _InfoRow(
                  icon: PhosphorIconsRegular.fileText,
                  label: 'Belge',
                  value: kayit.belge,
                ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                '${kayit.kararVerenMakam} · ${kayit.itirazMercii}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.88),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
            if (onOpenModule != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onOpenModule,
                  icon: const PhosphorIcon(
                    PhosphorIconsRegular.coins,
                    size: 16,
                    color: Color(0xFFFCD34D),
                  ),
                  label: const Text(
                    'Tüm cezalar',
                    style: TextStyle(
                      color: Color(0xFFFCD34D),
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _titleKanun(String kanun) {
    if (kanun.isEmpty) return kanun;
    return kanun
        .split(' ')
        .map((w) => w.isEmpty ? w : trLower(w)[0].toUpperCase() + trLower(w).substring(1))
        .join(' ');
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhosphorIcon(
            icon,
            size: 15,
            color: PoliceColors.textMuted.withValues(alpha: 0.75),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: PoliceColors.titleOnDark.withValues(alpha: 0.92),
                  fontSize: 12.5,
                  height: 1.35,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
