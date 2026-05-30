import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../common/theme/police_colors.dart';
import 'sifre_store.dart';

/// Cihazda kayıtlı şifrelerin listesi (göster/kopyala/sil).
class KayitliSifrelerPage extends StatefulWidget {
  const KayitliSifrelerPage({super.key});

  @override
  State<KayitliSifrelerPage> createState() => _KayitliSifrelerPageState();
}

class _KayitliSifrelerPageState extends State<KayitliSifrelerPage> {
  List<KayitliSifre> _items = [];
  bool _loading = true;
  final Set<String> _revealed = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await sifreLoadAll();
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _openSheet({KayitliSifre? existing}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PoliceColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SifreSheet(existing: existing),
    );
    if (saved == true) await _load();
  }

  Future<void> _delete(KayitliSifre e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PoliceColors.surfaceDark,
        title: const Text('Silinsin mi?',
            style: TextStyle(color: PoliceColors.titleOnDark)),
        content: Text(
          '${e.hedefLabel} kaydı cihazdan kalıcı olarak silinecek.',
          style: const TextStyle(color: PoliceColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await sifreDelete(e.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Kayıtlı şifreler'),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(),
        backgroundColor: PoliceColors.primaryBlue,
        foregroundColor: PoliceColors.titleOnDark,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Şifre ekle'),
      ),
      body: _loading
          ? const Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  color: PoliceColors.primaryBlue,
                  strokeWidth: 2,
                ),
              ),
            )
          : _items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      'Henüz kayıtlı şifre yok.\n\nSağ alttan "Şifre ekle" ile '
                      'kendi şifreni (Türkçe karakter dahil) girebilir ya da '
                      'şifre üret ekranındaki "Kaydet" ile bağlayabilirsin. '
                      'Kayıtlar yalnızca bu cihazda saklanır.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.95),
                        height: 1.5,
                      ),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Şifreler bu cihazda saklanır (güçlü şifreleme değildir). '
                        'Cihazını ekran kilidi ile koru; ortak cihazda kaydetme.',
                        style: TextStyle(
                          color: Colors.orange.shade100,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                    for (final e in _items) _tile(e),
                  ],
                ),
    );
  }

  Widget _tile(KayitliSifre e) {
    final revealed = _revealed.contains(e.id);
    final hedef = SifreHedef.all.firstWhere(
      (h) => h.id == e.hedefId,
      orElse: () => SifreHedef.diger,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openSheet(existing: e),
          child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: PoliceColors.primaryBlue.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: PhosphorIcon(
                hedef.banka
                    ? PhosphorIconsRegular.bank
                    : PhosphorIconsRegular.shieldStar,
                color: PoliceColors.primaryBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.hedefLabel,
                    style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    revealed ? e.sifre : '••••••••••',
                    style: const TextStyle(
                      color: PoliceColors.textMuted,
                      fontFamily: 'monospace',
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (e.not.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      e.not,
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.75),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: revealed ? 'Gizle' : 'Göster',
              visualDensity: VisualDensity.compact,
              icon: Icon(
                revealed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: PoliceColors.textMuted,
                size: 20,
              ),
              onPressed: () => setState(() {
                if (revealed) {
                  _revealed.remove(e.id);
                } else {
                  _revealed.add(e.id);
                }
              }),
            ),
            IconButton(
              tooltip: 'Kopyala',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy_rounded,
                  color: PoliceColors.primaryBlue, size: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: e.sifre));
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Şifre panoya kopyalandı')),
                );
              },
            ),
            IconButton(
              tooltip: 'Sil',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.delete_outline_rounded,
                  color: PoliceColors.textMuted, size: 20),
              onPressed: () => _delete(e),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}

/// Manuel şifre ekleme/düzenleme alt sayfası. Şifre alanı Türkçe karakter dahil
/// her türlü girişe izin verir.
class _SifreSheet extends StatefulWidget {
  const _SifreSheet({this.existing});

  final KayitliSifre? existing;

  @override
  State<_SifreSheet> createState() => _SifreSheetState();
}

class _SifreSheetState extends State<_SifreSheet> {
  late String _hedefId;
  late final TextEditingController _customCtrl;
  late final TextEditingController _sifreCtrl;
  late final TextEditingController _noteCtrl;
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _hedefId = e?.hedefId ?? SifreHedef.sistemler.first.id;
    // Bilinmeyen hedef (eski kayıt) "Diğer" olarak ele alınır.
    final known = SifreHedef.all.any((h) => h.id == _hedefId);
    final isDigerLabel = _hedefId == SifreHedef.digerId;
    _customCtrl = TextEditingController(
      text: (!known || isDigerLabel) ? (e?.hedefLabel ?? '') : '',
    );
    if (!known) _hedefId = SifreHedef.digerId;
    _sifreCtrl = TextEditingController(text: e?.sifre ?? '');
    _noteCtrl = TextEditingController(text: e?.not ?? '');
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    _sifreCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final sifre = _sifreCtrl.text;
    if (sifre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen şifreyi gir.')),
      );
      return;
    }
    final label = _hedefId == SifreHedef.digerId
        ? _customCtrl.text.trim()
        : SifreHedef.labelOf(_hedefId);
    if (label.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir ad gir.')),
      );
      return;
    }
    final existing = widget.existing;
    await sifreUpsert(
      KayitliSifre(
        id: existing?.id ?? sifreGenerateId(),
        hedefId: _hedefId,
        hedefLabel: label,
        sifre: sifre,
        createdAtMs: existing?.createdAtMs ??
            DateTime.now().millisecondsSinceEpoch,
        not: _noteCtrl.text.trim(),
      ),
    );
    await HapticFeedback.lightImpact();
    if (!mounted) return;
    Navigator.of(context).pop(true);
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

  InputDecoration _decoration(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
      hintText: hint,
      hintStyle: TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.5)),
      filled: true,
      fillColor: PoliceColors.backgroundDark,
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
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
            Text(
              widget.existing == null ? 'Şifre ekle' : 'Şifreyi düzenle',
              style: const TextStyle(
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
                style: const TextStyle(color: PoliceColors.titleOnDark),
                decoration: _decoration('Sistem / hesap adı'),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _sifreCtrl,
              autofocus: widget.existing == null,
              obscureText: _obscure,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.visiblePassword,
              style: const TextStyle(
                color: PoliceColors.titleOnDark,
                fontFamily: 'monospace',
              ),
              decoration: _decoration(
                'Şifre (Türkçe karakter serbest)',
                hint: 'Örn. Şifrem.2024çğü',
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: PoliceColors.textMuted,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              style: const TextStyle(color: PoliceColors.titleOnDark),
              decoration: _decoration(
                'Not (isteğe bağlı)',
                hint: 'Örn. kullanıcı adı / açıklama',
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
                onPressed: _save,
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
