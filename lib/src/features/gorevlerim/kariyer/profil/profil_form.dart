import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/theme/police_colors.dart';
import '../../../../common/widgets/rutbe_level_icon.dart';
import '../kariyer_constants.dart';
import '../kariyer_profil.dart';
import '../kariyer_profil_provider.dart';
import '../widgets/gazi_tesekkur_kart.dart';

/// Personel profil formu — Profilim sekmesi ve Kariyerim'de ortak.
class ProfilForm extends ConsumerStatefulWidget {
  const ProfilForm({super.key, this.compact = false});

  /// true: yalnızca form; false: rozet + tam form.
  final bool compact;

  @override
  ConsumerState<ProfilForm> createState() => _ProfilFormState();
}

class _ProfilFormState extends ConsumerState<ProfilForm> {
  final _adCtrl = TextEditingController();
  final _sicilCtrl = TextEditingController();
  final _birimCtrl = TextEditingController();
  final _ilCtrl = TextEditingController();
  String _rutbeId = '';
  String _egitimId = '';
  DateTime? _baslama;
  bool _gazi = false;
  bool _bound = false;
  bool _saving = false;

  @override
  void dispose() {
    _adCtrl.dispose();
    _sicilCtrl.dispose();
    _birimCtrl.dispose();
    _ilCtrl.dispose();
    super.dispose();
  }

  void _bind(KariyerProfil p) {
    if (_bound) return;
    _adCtrl.text = p.adSoyad;
    _sicilCtrl.text = p.sicil;
    _birimCtrl.text = p.birim;
    _ilCtrl.text = p.il;
    _rutbeId = p.rutbeId;
    _egitimId = p.egitimId;
    _gazi = p.gazi;
    if (p.gorevBaslamaMs > 0) {
      _baslama = DateTime.fromMillisecondsSinceEpoch(p.gorevBaslamaMs);
    }
    _bound = true;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _baslama ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) setState(() => _baslama = picked);
  }

  Future<void> _save() async {
    if (_adCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad soyad girin.')),
      );
      return;
    }
    setState(() => _saving = true);
    final profil = KariyerProfil(
      adSoyad: _adCtrl.text.trim(),
      sicil: _sicilCtrl.text.trim(),
      rutbeId: _rutbeId,
      birim: _birimCtrl.text.trim(),
      il: _ilCtrl.text.trim(),
      gorevBaslamaMs: _baslama?.millisecondsSinceEpoch ?? 0,
      egitimId: _egitimId,
      gazi: _gazi,
    );
    await kariyerSaveProfil(ref, profil);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil kaydedildi.')),
    );
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
            TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
        hintStyle:
            TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.5)),
        filled: true,
        fillColor: PoliceColors.backgroundDark.withValues(alpha: 0.6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: PoliceColors.outlineMuted.withValues(alpha: 0.45),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final profilAsync = ref.watch(kariyerProfilProvider);

    return profilAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
        ),
      ),
      error: (_, __) => const Text('Profil yüklenemedi.'),
      data: (p) {
        _bind(p);
        final rutbe = KariyerRutbe.byId(_rutbeId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.compact && rutbe != null) ...[
              Center(
                child: RutbeRankIcon(
                  levelIndex: rutbe.levelIndex,
                  size: 64,
                ),
              ),
              const SizedBox(height: 14),
            ],
            TextField(
              controller: _adCtrl,
              style: const TextStyle(color: PoliceColors.titleOnDark),
              decoration: _dec('Ad Soyad *'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sicilCtrl,
              style: const TextStyle(color: PoliceColors.titleOnDark),
              decoration: _dec('Sicil No (isteğe bağlı)'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              key: ValueKey('rutbe_$_rutbeId'),
              initialValue: _rutbeId.isEmpty ? null : _rutbeId,
              dropdownColor: PoliceColors.surfaceDark,
              style: const TextStyle(color: PoliceColors.titleOnDark),
              decoration: _dec('Rütbe'),
              items: [
                for (final r in KariyerRutbe.all)
                  DropdownMenuItem(
                    value: r.id,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RutbeRankIcon(levelIndex: r.levelIndex, size: 24),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            r.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _rutbeId = v ?? ''),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _birimCtrl,
              style: const TextStyle(color: PoliceColors.titleOnDark),
              decoration: _dec('Birim', hint: 'Koruma Şube, Narkotik…'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ilCtrl,
              style: const TextStyle(color: PoliceColors.titleOnDark),
              decoration: _dec('İl'),
            ),
            const SizedBox(height: 10),
            Material(
              color: PoliceColors.backgroundDark.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: PoliceColors.outlineMuted.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Göreve başlama tarihi',
                              style: TextStyle(
                                color:
                                    PoliceColors.textMuted.withValues(alpha: 0.9),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _baslama == null
                                  ? 'Tarih seçin'
                                  : '${_baslama!.day.toString().padLeft(2, '0')}.'
                                      '${_baslama!.month.toString().padLeft(2, '0')}.'
                                      '${_baslama!.year}',
                              style: const TextStyle(
                                color: PoliceColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.calendar_today_rounded,
                          color: PoliceColors.primaryBlue, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              key: ValueKey('egitim_$_egitimId'),
              initialValue: _egitimId.isEmpty ? null : _egitimId,
              dropdownColor: PoliceColors.surfaceDark,
              style: const TextStyle(color: PoliceColors.titleOnDark),
              decoration: _dec('Eğitim durumu'),
              items: [
                for (final e in EgitimDurumu.values)
                  DropdownMenuItem(value: e.id, child: Text(e.label)),
              ],
              onChanged: (v) => setState(() => _egitimId = v ?? ''),
            ),
            const SizedBox(height: 14),
            const Text(
              'Gazilik durumu',
              style: TextStyle(
                color: PoliceColors.titleOnDark,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Hayır')),
                ButtonSegment(value: true, label: Text('Evet')),
              ],
              selected: {_gazi},
              onSelectionChanged: (s) => setState(() => _gazi = s.first),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return PoliceColors.titleOnDark;
                  }
                  return PoliceColors.textMuted;
                }),
              ),
            ),
            if (_gazi) ...[
              const SizedBox(height: 10),
              Text(
                GaziTesekkurKart.mesaj,
                style: TextStyle(
                  color: PoliceColors.gold.withValues(alpha: 0.9),
                  fontSize: 12,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_saving ? 'Kaydediliyor…' : 'Profili kaydet'),
              style: FilledButton.styleFrom(
                backgroundColor: PoliceColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        );
      },
    );
  }
}
