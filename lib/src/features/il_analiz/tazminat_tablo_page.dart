import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/theme/police_colors.dart';
import 'il_analiz_display.dart';
import 'tazminat_dereceleri_data.dart';

/// Ek ödeme (tazminat) derece cetveli — dört sütun özet.
class TazminatTabloPage extends ConsumerWidget {
  const TazminatTabloPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tazminatDereceleriProvider);
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Tazminat tablosu'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Yüklenemedi: $e')),
        data: (set) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text(
                'İl bazında ek ödeme dereceleri. Detay için İl Analizi\'nden il seçin.',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: set.dereceler.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final d = set.dereceler[i];
                    return _DereceColumn(derece: d);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DereceColumn extends StatelessWidget {
  const _DereceColumn({required this.derece});

  final TazminatDerece derece;

  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.sizeOf(context).width * 0.42).clamp(140.0, 200.0);
    return SizedBox(
      width: w,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PoliceColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: derece.renk.withValues(alpha: 0.45),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: derece.renk.withValues(alpha: 0.2),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(13)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    derece.etiket,
                    style: TextStyle(
                      color: derece.renk,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatIlTl(derece.ekOdemeTl),
                    style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Ek ödeme',
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                itemCount: derece.ilIdler.length,
                itemBuilder: (context, i) {
                  final id = derece.ilIdler[i];
                  final ad = _ilAdFromId(id);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIconsRegular.mapPin,
                          size: 14,
                          color: PoliceColors.textMuted.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            ad,
                            style: const TextStyle(
                              color: PoliceColors.titleOnDark,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _ilAdFromId(String id) {
  if (id.isEmpty) return id;
  const ozel = {
    'agri': 'Ağrı',
    'aydin': 'Aydın',
    'diyarbakir': 'Diyarbakır',
    'elazig': 'Elazığ',
    'gumushane': 'Gümüşhane',
    'hakkari': 'Hakkâri',
    'igdir': 'Iğdır',
    'istanbul': 'İstanbul',
    'izmir': 'İzmir',
    'kahramanmaras': 'Kahramanmaraş',
    'mugla': 'Muğla',
    'mus': 'Muş',
    'sanliurfa': 'Şanlıurfa',
    'sirnak': 'Şırnak',
  };
  if (ozel.containsKey(id)) return ozel[id]!;
  return id[0].toUpperCase() + id.substring(1);
}
