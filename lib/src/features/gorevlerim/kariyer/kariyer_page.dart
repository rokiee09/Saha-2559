import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../common/theme/police_colors.dart';
import 'kariyer_provider.dart';

/// Kariyer paneli: branş/sicil/başlama yılı + başarı belgesi, eğitim ve şark
/// görev kayıtları. Tamamen cihazda, kişisel takip amaçlı.
class KariyerPage extends ConsumerWidget {
  const KariyerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilAsync = ref.watch(kariyerProfilProvider);
    final kayitlarAsync = ref.watch(kariyerKayitlarProvider);

    final profil = profilAsync.valueOrNull ?? const KariyerProfil();
    final kayitlar = kayitlarAsync.valueOrNull ?? const <KariyerKayit>[];

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Kariyerim'),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: PoliceColors.primaryBlue,
        foregroundColor: PoliceColors.titleOnDark,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Kayıt ekle'),
        onPressed: () => _addRecord(context, ref),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
        children: [
          _SummaryRow(profil: profil, kayitlar: kayitlar),
          const SizedBox(height: 16),
          _ProfileCard(profil: profil, onEdit: () => _editProfile(context, ref, profil)),
          const SizedBox(height: 18),
          _Section(
            title: 'Başarı Belgelerim',
            icon: PhosphorIconsRegular.medal,
            tur: KariyerKayitTuru.basari,
            kayitlar: kayitlar,
            ref: ref,
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Eğitimlerim',
            icon: PhosphorIconsRegular.graduationCap,
            tur: KariyerKayitTuru.egitim,
            kayitlar: kayitlar,
            ref: ref,
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Şark / Zorunlu Görevlerim',
            icon: PhosphorIconsRegular.mapPinLine,
            tur: KariyerKayitTuru.sark,
            kayitlar: kayitlar,
            ref: ref,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PoliceColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PoliceColors.gold.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const PhosphorIcon(PhosphorIconsRegular.info,
                    color: PoliceColors.gold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Görev yeri puanları Araçlar veya Tayinim bölümünden '
                    'incelenebilir. Tayin puanı tahmini, doğrulanmış kriter ve '
                    'ağırlık tablosu eklendiğinde bu kayıtlardan otomatik '
                    'hesaplanacak.',
                    style: TextStyle(
                      color: PoliceColors.titleOnDark.withValues(alpha: 0.9),
                      fontSize: 12.5,
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

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
    KariyerProfil profil,
  ) async {
    final bransCtrl = TextEditingController(text: profil.brans);
    final sicilCtrl = TextEditingController(text: profil.sicil);
    final yilCtrl = TextEditingController(
      text: profil.baslamaYili > 0 ? '${profil.baslamaYili}' : '',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PoliceColors.surfaceDark,
        title: const Text('Profil',
            style: TextStyle(color: PoliceColors.titleOnDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogField(controller: bransCtrl, label: 'Branş'),
            const SizedBox(height: 10),
            _DialogField(controller: sicilCtrl, label: 'Sicil no'),
            const SizedBox(height: 10),
            _DialogField(
              controller: yilCtrl,
              label: 'Göreve başlama yılı',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: PoliceColors.primaryBlue),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await kariyerSaveProfil(
      ref,
      KariyerProfil(
        brans: bransCtrl.text.trim(),
        sicil: sicilCtrl.text.trim(),
        baslamaYili: int.tryParse(yilCtrl.text.trim()) ?? 0,
      ),
    );
  }

  Future<void> _addRecord(BuildContext context, WidgetRef ref) async {
    var tur = KariyerKayitTuru.basari;
    final baslikCtrl = TextEditingController();
    final yilCtrl = TextEditingController();
    final notCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: PoliceColors.surfaceDark,
          title: const Text('Yeni kayıt',
              style: TextStyle(color: PoliceColors.titleOnDark)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<KariyerKayitTuru>(
                value: tur,
                dropdownColor: PoliceColors.surfaceDark,
                style: const TextStyle(color: PoliceColors.titleOnDark),
                decoration: const InputDecoration(labelText: 'Tür'),
                items: [
                  for (final t in KariyerKayitTuru.values)
                    DropdownMenuItem(value: t, child: Text(t.label)),
                ],
                onChanged: (v) => setLocal(() => tur = v ?? tur),
              ),
              const SizedBox(height: 10),
              _DialogField(controller: baslikCtrl, label: 'Başlık'),
              const SizedBox(height: 10),
              _DialogField(
                controller: yilCtrl,
                label: 'Yıl',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _DialogField(controller: notCtrl, label: 'Not (isteğe bağlı)'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: PoliceColors.primaryBlue),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final baslik = baslikCtrl.text.trim();
    if (baslik.isEmpty) return;
    await kariyerAddKayit(
      ref,
      KariyerKayit(
        id: kariyerGenerateId(),
        tur: tur,
        baslik: baslik,
        yil: int.tryParse(yilCtrl.text.trim()) ?? 0,
        not: notCtrl.text.trim(),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.profil, required this.kayitlar});

  final KariyerProfil profil;
  final List<KariyerKayit> kayitlar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '${profil.hizmetYili}',
            label: 'Hizmet yılı',
            icon: PhosphorIconsRegular.clock,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '${kariyerSayisi(kayitlar, KariyerKayitTuru.basari)}',
            label: 'Başarı belgesi',
            icon: PhosphorIconsRegular.medal,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '${kariyerSayisi(kayitlar, KariyerKayitTuru.sark)}',
            label: 'Şark görevi',
            icon: PhosphorIconsRegular.mapPinLine,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        children: [
          PhosphorIcon(icon, color: PoliceColors.primaryBlue, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profil, required this.onEdit});

  final KariyerProfil profil;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final hasData = profil.brans.isNotEmpty ||
        profil.sicil.isNotEmpty ||
        profil.baslamaYili > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Profil',
                style: TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: Text(hasData ? 'Düzenle' : 'Ekle'),
                style: TextButton.styleFrom(
                  foregroundColor: PoliceColors.primaryBlue,
                ),
              ),
            ],
          ),
          if (hasData) ...[
            _kv('Branş', profil.brans),
            _kv('Sicil', profil.sicil),
            _kv(
              'Göreve başlama',
              profil.baslamaYili > 0 ? '${profil.baslamaYili}' : '',
            ),
          ] else
            Text(
              'Branş, sicil ve göreve başlama yılını ekleyerek başla.',
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.9),
                fontSize: 13,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    if (v.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              k,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                color: PoliceColors.titleOnDark,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.tur,
    required this.kayitlar,
    required this.ref,
  });

  final String title;
  final IconData icon;
  final KariyerKayitTuru tur;
  final List<KariyerKayit> kayitlar;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final items = kayitlar.where((e) => e.tur == tur).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PhosphorIcon(icon, color: PoliceColors.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: PoliceColors.titleOnDark,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Text(
              '${items.length}',
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Henüz kayıt yok.',
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.7),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          for (final k in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                decoration: BoxDecoration(
                  color: PoliceColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            k.baslik,
                            style: const TextStyle(
                              color: PoliceColors.titleOnDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          if (k.yil > 0 || k.not.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              [
                                if (k.yil > 0) '${k.yil}',
                                if (k.not.isNotEmpty) k.not,
                              ].join(' · '),
                              style: TextStyle(
                                color:
                                    PoliceColors.textMuted.withValues(alpha: 0.9),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Sil',
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: PoliceColors.textMuted, size: 20),
                      onPressed: () async {
                        HapticFeedback.selectionClick();
                        await kariyerDeleteKayit(ref, k.id);
                      },
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: PoliceColors.titleOnDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
      ),
    );
  }
}
