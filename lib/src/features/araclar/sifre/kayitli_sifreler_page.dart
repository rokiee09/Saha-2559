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
                      'Henüz kayıtlı şifre yok.\n\nŞifre üret ekranında bir şifre '
                      'üretip "Kaydet" ile bir sisteme/bankaya bağlayabilirsin. '
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
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
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        decoration: BoxDecoration(
          color: PoliceColors.surfaceDark,
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
    );
  }
}
