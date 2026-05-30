import 'package:flutter/material.dart';

import '../../../common/text/tr_text.dart';
import '../../../common/theme/police_colors.dart';
import 'disiplin_rehberi_data.dart';

/// Disiplin rehberi: fiil → olası ceza/dayanak + savunma süreci + itiraz yolu.
/// Bilgilendirme amaçlıdır.
class DisiplinRehberiPage extends StatefulWidget {
  const DisiplinRehberiPage({super.key});

  @override
  State<DisiplinRehberiPage> createState() => _DisiplinRehberiPageState();
}

class _DisiplinRehberiPageState extends State<DisiplinRehberiPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DisiplinFiil> get _filtered {
    final q = trFold(_query.trim());
    if (q.isEmpty) return kDisiplinFiilleri;
    return kDisiplinFiilleri.where((f) {
      if (trFold(f.baslik).contains(q)) return true;
      if (trFold(f.ceza.label).contains(q)) return true;
      if (trFold(f.dayanak).contains(q)) return true;
      return f.anahtarlar.any((k) => trFold(k).contains(q));
    }).toList();
  }

  Color _cezaColor(DisiplinCezaTuru t) => switch (t) {
        DisiplinCezaTuru.uyarma => const Color(0xFF4CAF50),
        DisiplinCezaTuru.kinama => const Color(0xFF8BC34A),
        DisiplinCezaTuru.ayliktanKesme => const Color(0xFFFFB300),
        DisiplinCezaTuru.kisaDurdurma => const Color(0xFFFF8A4C),
        DisiplinCezaTuru.uzunDurdurma => const Color(0xFFEF6C00),
        DisiplinCezaTuru.meslektenCikarma => const Color(0xFFE53935),
      };

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Disiplin Rehberi'),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: InputDecoration(
              hintText: 'Fiil ara (ör. göreve gelmeme, hakaret, telsiz)',
              hintStyle: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.6),
              ),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: PoliceColors.textMuted),
              filled: true,
              fillColor: PoliceColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 14),
          const _ProcessCard(
            title: 'Savunma süreci',
            icon: Icons.gavel_rounded,
            steps: kDisiplinSavunmaAdimlari,
          ),
          const SizedBox(height: 10),
          const _ProcessCard(
            title: 'İtiraz yolu',
            icon: Icons.undo_rounded,
            steps: kDisiplinItirazAdimlari,
          ),
          const SizedBox(height: 16),
          Text(
            _query.trim().isEmpty
                ? 'Disiplinsizlik örnekleri (${items.length})'
                : '${items.length} sonuç',
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Eşleşen fiil bulunamadı.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.9),
                ),
              ),
            )
          else
            for (final f in items)
              _FiilCard(fiil: f, color: _cezaColor(f.ceza)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
            ),
            child: Text(
              'Bu rehber 7068 ve 657 atıflarından bilgilendirme amaçlı bir derlemedir. '
              'Fiil–ceza eşlemesi somut olaya, ağırlığa ve güncel mevzuata göre değişir; '
              'kesin hüküm için yürürlükteki metin ve kurum onayı esastır.',
              style: TextStyle(
                color: Colors.orange.shade100,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessCard extends StatelessWidget {
  const _ProcessCard({
    required this.title,
    required this.icon,
    required this.steps,
  });

  final String title;
  final IconData icon;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: PoliceColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: PoliceColors.primaryBlue.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      steps[i],
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.95),
                        fontSize: 12.8,
                        height: 1.4,
                      ),
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

class _FiilCard extends StatelessWidget {
  const _FiilCard({required this.fiil, required this.color});

  final DisiplinFiil fiil;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final puan = fiil.ceza.puan;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ColoredBox(
            color: PoliceColors.surfaceDark,
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 14),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              iconColor: PoliceColors.textMuted,
              collapsedIconColor: PoliceColors.textMuted,
              leading: Container(
                width: 6,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              title: Text(
                fiil.baslik,
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${fiil.ceza.label} · ${fiil.dayanak}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    fiil.ceza.aciklama,
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.95),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
                if (fiil.detay.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      fiil.detay,
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.8),
                        fontSize: 12.5,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _InfoPill(
                      label: fiil.ceza.label,
                      color: color,
                    ),
                    if (puan != null)
                      _InfoPill(
                        label: 'Ceza puanı: $puan',
                        color: PoliceColors.primaryBlue,
                      ),
                    _InfoPill(
                      label: fiil.dayanak,
                      color: PoliceColors.primaryBlue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
