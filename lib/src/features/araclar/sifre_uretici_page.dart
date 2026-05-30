import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import 'sifre/kayitli_sifreler_page.dart';
import 'sifre/sifre_store.dart';

typedef _LenPreset = ({String label, int min, int max});

/// Güçlü, cihazda üretilen rastgele şifre. Üretim bellekte gerçekleşir;
/// istenirse şifre bir sisteme/bankaya bağlanıp yalnızca cihazda saklanabilir.
class SifreUreticiPage extends StatefulWidget {
  const SifreUreticiPage({super.key});

  @override
  State<SifreUreticiPage> createState() => _SifreUreticiPageState();
}

class _SifreUreticiPageState extends State<SifreUreticiPage> {
  static const _lower = 'abcdefghijkmnopqrstuvwxyz';
  static const _upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const _digits = '23456789';
  static const _symbols = '!@#\$%&*?-_=+';

  /// Karakter uzunluğu aralıkları (sistemlerin sınırına göre).
  static const List<_LenPreset> _lenPresets = [
    (label: '0-4', min: 1, max: 4),
    (label: '4-8', min: 4, max: 8),
    (label: '9-12', min: 9, max: 12),
    (label: '13-16', min: 13, max: 16),
    (label: '17-32', min: 17, max: 32),
    (label: 'Serbest', min: 6, max: 32),
  ];

  final Random _rng = Random.secure();

  int _lenPresetIndex = 5; // Serbest
  double _length = 16;
  bool _useUpper = true;
  bool _useLower = true;
  bool _useDigits = true;
  bool _useSymbols = true;
  String _password = '';

  _LenPreset get _preset => _lenPresets[_lenPresetIndex];

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _applyPreset(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _lenPresetIndex = index;
      final p = _lenPresets[index];
      _length = _length.clamp(p.min.toDouble(), p.max.toDouble());
    });
    _generate();
  }

  void _applyCombo({
    required bool upper,
    required bool lower,
    required bool digits,
    required bool symbols,
  }) {
    HapticFeedback.selectionClick();
    setState(() {
      _useUpper = upper;
      _useLower = lower;
      _useDigits = digits;
      _useSymbols = symbols;
    });
    _generate();
  }

  bool _comboIs(bool u, bool l, bool d, bool s) =>
      _useUpper == u && _useLower == l && _useDigits == d && _useSymbols == s;

  void _generate() {
    final pools = <String>[
      if (_useLower) _lower,
      if (_useUpper) _upper,
      if (_useDigits) _digits,
      if (_useSymbols) _symbols,
    ];
    if (pools.isEmpty) {
      setState(() => _password = '');
      return;
    }
    final all = pools.join();
    final len = _length.round();
    final chars = <String>[];

    for (final p in pools) {
      chars.add(p[_rng.nextInt(p.length)]);
    }
    while (chars.length < len) {
      chars.add(all[_rng.nextInt(all.length)]);
    }
    chars.shuffle(_rng);
    setState(() => _password = chars.take(len).join());
  }

  ({String label, Color color}) _strength() {
    var pools = 0;
    if (_useLower) pools++;
    if (_useUpper) pools++;
    if (_useDigits) pools++;
    if (_useSymbols) pools++;
    final len = _length.round();
    final score = len + pools * 4;
    if (pools == 0) return (label: '—', color: PoliceColors.textMuted);
    if (score >= 28 && pools >= 3) {
      return (label: 'Çok güçlü', color: const Color(0xFF34D399));
    }
    if (score >= 22) return (label: 'Güçlü', color: PoliceColors.primaryBlue);
    if (score >= 16) return (label: 'Orta', color: PoliceColors.gold);
    return (label: 'Zayıf', color: Colors.redAccent);
  }

  Future<void> _openSaved() async {
    await Navigator.of(context).push(fadeRoute(const KayitliSifrelerPage()));
  }

  Future<void> _saveCurrent() async {
    if (_password.isEmpty) return;
    final result = await showModalBottomSheet<_SaveChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PoliceColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SaveSheet(password: _password),
    );
    if (result == null) return;
    final label = result.hedefId == SifreHedef.digerId
        ? result.customName.trim()
        : SifreHedef.labelOf(result.hedefId);
    if (label.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir ad gir.')),
      );
      return;
    }
    await sifreUpsert(
      KayitliSifre(
        id: sifreGenerateId(),
        hedefId: result.hedefId,
        hedefLabel: label,
        sifre: _password,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
        not: result.note.trim(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label için şifre cihaza kaydedildi'),
        action: SnackBarAction(label: 'Kayıtlar', onPressed: _openSaved),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strength = _strength();
    final hasPassword = _password.isNotEmpty;
    final p = _preset;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Şifre üretici',
          style: TextStyle(
            color: PoliceColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Kayıtlı şifreler',
            onPressed: _openSaved,
            icon: const Icon(Icons.lock_outline_rounded,
                color: PoliceColors.primaryBlue),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: PoliceColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  hasPassword ? _password : 'En az bir karakter türü seç',
                  style: TextStyle(
                    color: hasPassword
                        ? PoliceColors.titleOnDark
                        : PoliceColors.textMuted,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: strength.color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        strength.label,
                        style: TextStyle(
                          color: strength.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Kopyala',
                      onPressed: hasPassword
                          ? () {
                              Clipboard.setData(
                                ClipboardData(text: _password),
                              );
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Şifre panoya kopyalandı'),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(
                        Icons.copy_rounded,
                        color: PoliceColors.primaryBlue,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Yenile',
                      onPressed: _generate,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: PoliceColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                if (hasPassword) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: _saveCurrent,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            PoliceColors.primaryBlue.withValues(alpha: 0.18),
                        foregroundColor: PoliceColors.primaryBlue,
                      ),
                      icon: const Icon(Icons.save_alt_rounded, size: 18),
                      label: const Text(
                        'Kaydet (sisteme/bankaya bağla)',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Uzunluk aralığı ön ayarları
          const _GroupTitle('Karakter sınırı'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (var i = 0; i < _lenPresets.length; i++)
                ChoiceChip(
                  label: Text(_lenPresets[i].label),
                  selected: _lenPresetIndex == i,
                  showCheckmark: false,
                  backgroundColor: PoliceColors.surfaceDark,
                  selectedColor:
                      PoliceColors.primaryBlue.withValues(alpha: 0.28),
                  labelStyle: TextStyle(
                    color: _lenPresetIndex == i
                        ? PoliceColors.titleOnDark
                        : PoliceColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                  side: BorderSide(
                    color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
                  ),
                  onSelected: (_) => _applyPreset(i),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Uzunluk',
                style: TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${_length.round()}  (${p.min}-${p.max})',
                style: const TextStyle(
                  color: PoliceColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Slider(
            value: _length.clamp(p.min.toDouble(), p.max.toDouble()),
            min: p.min.toDouble(),
            max: p.max.toDouble(),
            divisions: (p.max - p.min) > 0 ? (p.max - p.min) : null,
            activeColor: PoliceColors.primaryBlue,
            label: '${_length.round()}',
            onChanged: (v) {
              setState(() => _length = v);
              _generate();
            },
          ),
          const SizedBox(height: 8),

          // Kombinasyon ön ayarları
          const _GroupTitle('Kombinasyon'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _comboChip('Tümü (harf+rakam+sembol)', true, true, true, true),
              _comboChip('Harf + rakam', true, true, true, false),
              _comboChip('Büyük + küçük harf', true, true, false, false),
              _comboChip('Sadece rakam (PIN)', false, false, true, false),
            ],
          ),
          const SizedBox(height: 10),
          _OptionSwitch(
            label: 'Büyük harf (A-Z)',
            value: _useUpper,
            onChanged: (v) {
              setState(() => _useUpper = v);
              _generate();
            },
          ),
          _OptionSwitch(
            label: 'Küçük harf (a-z)',
            value: _useLower,
            onChanged: (v) {
              setState(() => _useLower = v);
              _generate();
            },
          ),
          _OptionSwitch(
            label: 'Rakam (0-9)',
            value: _useDigits,
            onChanged: (v) {
              setState(() => _useDigits = v);
              _generate();
            },
          ),
          _OptionSwitch(
            label: 'Sembol (!@#…)',
            value: _useSymbols,
            onChanged: (v) {
              setState(() => _useSymbols = v);
              _generate();
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _generate,
            style: FilledButton.styleFrom(
              backgroundColor: PoliceColors.primaryBlue,
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.autorenew_rounded),
            label: const Text(
              'Yeni şifre üret',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Karışıklık yaratan benzer karakterler (0/O, 1/l/I) bilinçli olarak '
            'çıkarılmıştır. Kaydedilen şifreler yalnızca bu cihazda saklanır '
            '(güçlü şifreleme değildir); cihazını ekran kilidiyle koru.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.8),
              fontSize: 11.5,
              height: 1.45,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _comboChip(String label, bool u, bool l, bool d, bool s) {
    final selected = _comboIs(u, l, d, s);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      backgroundColor: PoliceColors.surfaceDark,
      selectedColor: PoliceColors.primaryBlue.withValues(alpha: 0.28),
      labelStyle: TextStyle(
        color: selected ? PoliceColors.titleOnDark : PoliceColors.textMuted,
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
      ),
      side: BorderSide(
        color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
      ),
      onSelected: (_) =>
          _applyCombo(upper: u, lower: l, digits: d, symbols: s),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: PoliceColors.titleOnDark,
        fontWeight: FontWeight.w800,
        fontSize: 14.5,
      ),
    );
  }
}

class _OptionSwitch extends StatelessWidget {
  const _OptionSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeColor: PoliceColors.primaryBlue,
      title: Text(
        label,
        style: const TextStyle(
          color: PoliceColors.titleOnDark,
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SaveChoice {
  const _SaveChoice({
    required this.hedefId,
    required this.customName,
    required this.note,
  });

  final String hedefId;
  final String customName;
  final String note;
}

class _SaveSheet extends StatefulWidget {
  const _SaveSheet({required this.password});

  final String password;

  @override
  State<_SaveSheet> createState() => _SaveSheetState();
}

class _SaveSheetState extends State<_SaveSheet> {
  String _hedefId = SifreHedef.sistemler.first.id;
  final _customCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _customCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Widget _chips(String title, List<SifreHedef> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: PoliceColors.textMuted.withValues(alpha: 0.95),
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final h in list)
              ChoiceChip(
                label: Text(h.label),
                selected: _hedefId == h.id,
                showCheckmark: false,
                backgroundColor: PoliceColors.backgroundDark,
                selectedColor: PoliceColors.primaryBlue.withValues(alpha: 0.3),
                labelStyle: TextStyle(
                  color: _hedefId == h.id
                      ? PoliceColors.titleOnDark
                      : PoliceColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
                side: BorderSide(
                  color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
                ),
                onSelected: (_) => setState(() => _hedefId = h.id),
              ),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDiger = _hedefId == SifreHedef.digerId;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: PoliceColors.textMuted.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Şifre nerede kullanılacak?',
              style: TextStyle(
                color: PoliceColors.titleOnDark,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 14),
            _chips('Kurumsal sistemler', SifreHedef.sistemler),
            _chips('Bankalar', SifreHedef.bankalar),
            _chips('Diğer', const [SifreHedef.diger]),
            if (isDiger) ...[
              TextField(
                controller: _customCtrl,
                autofocus: true,
                style: const TextStyle(color: PoliceColors.titleOnDark),
                decoration: InputDecoration(
                  labelText: 'Sistem / hesap adı',
                  labelStyle: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.9),
                  ),
                  filled: true,
                  fillColor: PoliceColors.backgroundDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _noteCtrl,
              style: const TextStyle(color: PoliceColors.titleOnDark),
              decoration: InputDecoration(
                labelText: 'Not (isteğe bağlı)',
                labelStyle: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.9),
                ),
                hintText: 'Örn. kullanıcı adı / açıklama',
                hintStyle: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: PoliceColors.backgroundDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: PoliceColors.primaryBlue,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop(
                    _SaveChoice(
                      hedefId: _hedefId,
                      customName: _customCtrl.text,
                      note: _noteCtrl.text,
                    ),
                  );
                },
                icon: const Icon(Icons.save_alt_rounded),
                label: const Text(
                  'Cihaza kaydet',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
