import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../common/theme/police_colors.dart';
import 'vardiya_setup_config.dart';
import 'vardiya_setup_store.dart';
import 'vardiya_shift_content.dart';
import 'vardiya_shift_placeholder_page.dart';
import 'vardiya_ui_widgets.dart';

String _fmtDateTr(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '$dd.$mm.${d.year}';
}

/// Referans uygulamadaki gibi: durum seçimi + (gerekiyorsa) tarih/grup/patern.
class VardiyaSetupPage extends StatefulWidget {
  const VardiyaSetupPage({super.key, required this.shiftId});

  final String shiftId;

  @override
  State<VardiyaSetupPage> createState() => _VardiyaSetupPageState();
}

class _VardiyaSetupPageState extends State<VardiyaSetupPage> {
  late VardiyaSetupConfig _config;
  VardiyaSetupState _state = const VardiyaSetupState();
  String? _selectedOptionId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _config = VardiyaSetupConfig.forShift(widget.shiftId)!;
    _load();
  }

  Future<void> _load() async {
    final saved = await VardiyaSetupStore.load(widget.shiftId);
    if (!mounted) return;
    setState(() {
      _state = saved;
      _selectedOptionId = saved.optionId ??
          (_config.options.isNotEmpty ? _config.options.first.id : null);
      _loading = false;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _state.anchorDate ?? now;
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: PoliceColors.primaryBlue,
              surface: PoliceColors.surfaceDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (d == null || !mounted) return;
    setState(() {
      _state = VardiyaSetupState(
        anchorMs: DateTime(d.year, d.month, d.day).millisecondsSinceEpoch,
        cycleIndex: _state.cycleIndex,
        startNight: _state.startNight,
        group: _state.group,
        tableDays: _state.tableDays,
        cakmaPatternId: _state.cakmaPatternId,
        optionId: _selectedOptionId,
      );
    });
  }

  VardiyaSetupOption? get _selectedOption {
    if (_selectedOptionId == null) return null;
    for (final o in _config.options) {
      if (o.id == _selectedOptionId) return o;
    }
    return null;
  }

  bool get _canSubmit {
    if (_selectedOption == null) return false;
    if (_config.showDatePicker && _state.anchorMs == null) {
      // Tarih seçilmemişse bugünü kullan
      return true;
    }
    return true;
  }

  Future<void> _submit() async {
    final option = _selectedOption;
    if (option == null) return;

    HapticFeedback.mediumImpact();

    final anchor = _state.anchorDate ??
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );

    final startNight = _config.showDayNightPicker
        ? (option.id.contains('night') || option.id == 'night')
        : _state.startNight;

    final next = VardiyaSetupState(
      anchorMs: anchor.millisecondsSinceEpoch,
      cycleIndex: option.cycleIndex,
      startNight: startNight,
      group: _state.group,
      tableDays: _state.tableDays,
      cakmaPatternId: _state.cakmaPatternId,
      optionId: option.id,
    );

    await VardiyaSetupStore.save(widget.shiftId, next);

    if (!mounted) return;
    await Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => VardiyaShiftPlaceholderPage(shiftId: widget.shiftId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tur = _config.tur;
    final accent = tur?.topColor ?? PoliceColors.primaryBlue;
    final description = vardiyaDescriptionFor(widget.shiftId);

    return Scaffold(
      backgroundColor: VardiyaUi.pageBackground,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        elevation: 0,
        title: Text('Vardiya · ${tur?.title ?? widget.shiftId}'),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34)),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VardiyaSectionCard(
                    title: 'Nasıl çalışır?',
                    child: Text(
                      description,
                      style: TextStyle(
                        color: PoliceColors.mevzuatBodyText.withValues(alpha: 0.92),
                        height: 1.48,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_config.showDatePicker) ...[
                    VardiyaSectionCard(
                      title: 'Tarih seçin',
                      subtitle: 'Referans günü — genelde bugün veya döngüye girdiğiniz gün.',
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_month_rounded),
                              label: Text(
                                _state.anchorDate != null
                                    ? _fmtDateTr(_state.anchorDate!)
                                    : 'Bugün (${_fmtDateTr(DateTime.now())})',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: PoliceColors.titleOnDark,
                                side: BorderSide(
                                  color: accent.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_config.showGroupPicker) ...[
                    VardiyaSectionCard(
                      title: 'Hangi gruptasınız?',
                      subtitle: '4 grup arasında döngü kayması uygulanır (örnek model).',
                      child: Row(
                        children: [
                          for (var g = 1; g <= 4; g++)
                            VardiyaChipChoice(
                              label: '$g. Grup',
                              selected: _state.group == g,
                              accentColor: accent,
                              onTap: () => setState(() {
                                _state = VardiyaSetupState(
                                  anchorMs: _state.anchorMs,
                                  cycleIndex: _state.cycleIndex,
                                  startNight: _state.startNight,
                                  group: g,
                                  tableDays: _state.tableDays,
                                  cakmaPatternId: _state.cakmaPatternId,
                                  optionId: _selectedOptionId,
                                );
                              }),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_config.showCakmaPatternPicker) ...[
                    VardiyaSectionCard(
                      title: 'Vardiya paternini seçin',
                      subtitle: 'Blok uzunlukları biriminize göre değişebilir.',
                      child: Column(
                        children: [
                          for (final p in VardiyaSetupConfig.cakmaPatterns)
                            VardiyaRadioOption(
                              title: p.label,
                              selected: _state.cakmaPatternId == p.id,
                              accentColor: accent,
                              onTap: () => setState(() {
                                _state = VardiyaSetupState(
                                  anchorMs: _state.anchorMs,
                                  cycleIndex: _state.cycleIndex,
                                  startNight: _state.startNight,
                                  group: _state.group,
                                  tableDays: _state.tableDays,
                                  cakmaPatternId: p.id,
                                  optionId: _selectedOptionId,
                                );
                              }),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_config.showTableDaysPicker) ...[
                    VardiyaSectionCard(
                      title: 'Kaç günlük tablo?',
                      child: Row(
                        children: [
                          for (final d in VardiyaSetupConfig.tableDayChoices)
                            VardiyaChipChoice(
                              label: '$d Gün',
                              selected: _state.tableDays == d,
                              accentColor: PoliceColors.gold,
                              onTap: () => setState(() {
                                _state = VardiyaSetupState(
                                  anchorMs: _state.anchorMs,
                                  cycleIndex: _state.cycleIndex,
                                  startNight: _state.startNight,
                                  group: _state.group,
                                  tableDays: d,
                                  cakmaPatternId: _state.cakmaPatternId,
                                  optionId: _selectedOptionId,
                                );
                              }),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  VardiyaSectionCard(
                    title: _config.questionTitle,
                    subtitle: _config.questionHint,
                    child: Column(
                      children: [
                        for (final o in _config.options)
                          VardiyaRadioOption(
                            title: o.title,
                            subtitle: o.subtitle,
                            icon: o.icon,
                            emoji: o.emoji,
                            selected: _selectedOptionId == o.id,
                            accentColor: accent,
                            onTap: () => setState(() => _selectedOptionId = o.id),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  VardiyaPrimaryButton(
                    label: _config.submitLabel,
                    enabled: _canSubmit,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 14),
                  const VardiyaInfoBanner(
                    text: 'Bu ekran bilgilendirme amaçlıdır; kesin görev saati ve sıra '
                        'yalnızca kurum çizelgesi ile belirlenir. Veri sunucuya gönderilmez.',
                  ),
                ],
              ),
            ),
    );
  }
}
