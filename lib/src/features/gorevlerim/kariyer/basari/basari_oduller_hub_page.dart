import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../common/routing/transitions.dart';
import '../../../../common/theme/police_colors.dart';
import '../../../../common/widgets/police_module_icon.dart';
import '../kariyer_file_store.dart';
import '../taltif/taltif_editor_page.dart';
import '../taltif/taltif_models.dart';
import '../taltif/taltif_store.dart';
import 'basari_list_page.dart';
import 'basari_models.dart';
import 'basari_store.dart';

/// Başarı belgeleri, üstün başarı ve taltif kayıtları hub'ı.
class BasariOdullerHubPage extends ConsumerWidget {
  const BasariOdullerHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basariAsync = ref.watch(basariBelgelerProvider);
    final taltifAsync = ref.watch(taltifKayitlariProvider);

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Başarı ve Ödüllerim'),
      ),
      body: basariAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
        ),
        error: (_, __) => const Center(child: Text('Kayıtlar okunamadı.')),
        data: (belgeler) {
          final h = hesaplaBasari(belgeler);
          final taltifList = taltifAsync.valueOrNull ?? const <TaltifKayit>[];
          final tOzet = hesaplaTaltif(taltifList);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              _BasariOzetKart(hesap: h),
              if (h.ustunEsikUlasildi) ...[
                const SizedBox(height: 10),
                _BilgilendirmeKart(
                  metin:
                      'Üstün Başarı Belgesi için gerekli başarı belgesi sayısına ulaştınız.',
                ),
              ],
              const SizedBox(height: 10),
              _TaltifOzetKart(ozet: tOzet),
              const SizedBox(height: 18),
              const Text(
                'Kayıt türleri',
                style: TextStyle(
                  color: PoliceColors.gold,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              _ModulKart(
                style: PoliceModules.basari,
                title: 'Başarı Belgeleri',
                subtitle: '${h.basariSayisi} kayıt',
                onTap: () => Navigator.of(context).push(
                  fadeRoute(
                    const BasariBelgeListPage(tur: BasariBelgeTuru.basari),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _ModulKart(
                style: PoliceModules.ustunBasari,
                title: 'Üstün Başarı Belgeleri',
                subtitle: '${h.ustunSayisi} kayıt',
                onTap: () => Navigator.of(context).push(
                  fadeRoute(
                    const BasariBelgeListPage(
                      tur: BasariBelgeTuru.ustunBasari,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _ModulKart(
                style: PoliceModules.taltif,
                title: 'Taltiflerim',
                subtitle: tOzet.toplamSayi == 0
                    ? 'Henüz taltif kaydı yok'
                    : '${tOzet.toplamSayi} kayıt · ${formatTaltifTutari(tOzet.toplamTutar)} TL',
                onTap: () => Navigator.of(context)
                    .push(fadeRoute(const TaltifPage())),
              ),
              const SizedBox(height: 14),
              Text(
                'Belgeler yalnızca bu cihazda saklanır; sunucuya gönderilmez. '
                'Resmî özlük kaydı yerine geçmez.',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.75),
                  fontSize: 11.5,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BasariOzetKart extends StatelessWidget {
  const _BasariOzetKart({required this.hesap});

  final BasariHesap hesap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PoliceColors.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          _row('Toplam Başarı Belgesi', '${hesap.basariSayisi}'),
          _row('Toplam Üstün Başarı Belgesi', '${hesap.ustunSayisi}'),
          const Divider(height: 20),
          Text(
            hesap.sonrakiUstunIcinKalan == 0
                ? 'Sonraki üstün başarı için: eşik tamamlandı'
                : 'Sonraki üstün başarı için: ${hesap.sonrakiUstunIcinKalan} başarı belgesi kaldı',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PoliceColors.gold.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '3 başarı belgesi = 1 üstün başarı belgesi hakkı (bilgilendirme)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.8),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                k,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.9),
                ),
              ),
            ),
            Text(
              v,
              style: const TextStyle(
                color: PoliceColors.titleOnDark,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
}

class _TaltifOzetKart extends StatelessWidget {
  const _TaltifOzetKart({required this.ozet});

  final TaltifOzet ozet;

  @override
  Widget build(BuildContext context) {
    final sonTarih = ozet.sonTarihMs > 0
        ? DateTime.fromMillisecondsSinceEpoch(ozet.sonTarihMs)
        : null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PoliceModules.taltif.color.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Taltif özeti',
            style: TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          _row('Toplam taltif sayısı', '${ozet.toplamSayi}'),
          _row(
            'Toplam taltif tutarı',
            ozet.toplamTutar > 0
                ? '${formatTaltifTutari(ozet.toplamTutar)} TL'
                : '—',
          ),
          _row(
            'Son taltif tarihi',
            sonTarih != null
                ? '${sonTarih.day}.${sonTarih.month}.${sonTarih.year}'
                : '—',
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                k,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.88),
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              v,
              style: const TextStyle(
                color: PoliceColors.titleOnDark,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      );
}

class _BilgilendirmeKart extends StatelessWidget {
  const _BilgilendirmeKart({required this.metin});

  final String metin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceModules.ustunBasari.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceModules.ustunBasari.color.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhosphorIcon(
            PhosphorIconsRegular.star,
            color: PoliceModules.ustunBasari.color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              metin,
              style: TextStyle(
                color: PoliceColors.titleOnDark.withValues(alpha: 0.94),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModulKart extends StatelessWidget {
  const _ModulKart({
    required this.style,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final PoliceModuleStyle style;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PoliceColors.surfaceDark,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: style.color.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              PoliceModuleIconBadge(
                style: style,
                size: 22,
                padding: 8,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.88),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              PhosphorIcon(
                PhosphorIconsRegular.caretRight,
                color: PoliceColors.textMuted.withValues(alpha: 0.8),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaltifPage extends ConsumerWidget {
  const TaltifPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(taltifKayitlariProvider);

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Taltiflerim'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        backgroundColor: PoliceColors.primaryBlue,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Taltif ekle'),
      ),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
        ),
        error: (_, __) => const Center(child: Text('Kayıtlar okunamadı.')),
        data: (list) {
          final ozet = hesaplaTaltif(list);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
            children: [
              _TaltifOzetKart(ozet: ozet),
              const SizedBox(height: 14),
              if (list.isEmpty)
                Text(
                  'Henüz taltif kaydı yok.',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                for (final k in list) _tile(context, ref, k),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(BuildContext context, WidgetRef ref, TaltifKayit k) {
    final tarih = DateTime.fromMillisecondsSinceEpoch(k.tarihMs);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _openEditor(context, ref, existing: k),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: PoliceModules.taltif.color.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (k.fotoPath.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(k.fotoPath),
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  PoliceModuleIconBadge(
                    style: PoliceModules.taltif,
                    size: 20,
                    padding: 8,
                    borderRadius: 10,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        k.tutar > 0
                            ? '${formatTaltifTutari(k.tutar)} TL'
                            : 'Taltif',
                        style: const TextStyle(
                          color: PoliceColors.titleOnDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        k.aciklama.isNotEmpty ? k.aciklama : '—',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.88),
                          fontSize: 12.5,
                        ),
                      ),
                      Text(
                        '${tarih.day}.${tarih.month}.${tarih.year}'
                        '${k.verenMakam.isNotEmpty ? ' · ${k.verenMakam}' : ''}',
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.75),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: () async {
                    HapticFeedback.selectionClick();
                    if (k.fotoPath.isNotEmpty) {
                      await kariyerDeleteFile(k.fotoPath);
                    }
                    if (k.pdfPath.isNotEmpty) await kariyerDeleteFile(k.pdfPath);
                    await taltifDelete(ref, k);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    TaltifKayit? existing,
  }) async {
    final result = await Navigator.of(context).push<TaltifKayit>(
      MaterialPageRoute(builder: (_) => TaltifEditorPage(existing: existing)),
    );
    if (result != null) await taltifUpsert(ref, result);
  }
}
