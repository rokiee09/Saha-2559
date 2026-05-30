import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../common/theme/police_colors.dart';
import '../../saha/saha_editor_page.dart';
import 'tutanak_templates.dart';

class TutanakFormPage extends StatefulWidget {
  const TutanakFormPage({super.key, required this.templateId});

  final String templateId;

  @override
  State<TutanakFormPage> createState() => _TutanakFormPageState();
}

class _TutanakFormPageState extends State<TutanakFormPage> {
  late final TutanakTemplate _template;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _template = TutanakTemplate.byId(widget.templateId) ??
        TutanakTemplate.all.first;
    final now = DateTime.now();
    final tarih = '${_d2(now.day)}.${_d2(now.month)}.${now.year}';
    final saat = '${_d2(now.hour)}:${_d2(now.minute)}';
    for (final f in _template.fields) {
      final initial = f.key == 'tarih'
          ? tarih
          : f.key == 'saat'
              ? saat
              : '';
      final c = TextEditingController(text: initial);
      c.addListener(_onChanged);
      _controllers[f.key] = c;
    }
  }

  static String _d2(int v) => v.toString().padLeft(2, '0');

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String> get _values =>
      {for (final e in _controllers.entries) e.key: e.value.text};

  String get _draft => _template.build(_values);

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _draft));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Taslak panoya kopyalandı.')),
    );
  }

  Future<void> _saveToSaha() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => SahaEditorPage(
          categoryId: 'tutanak',
          initialTitle: _template.title,
          initialBody: _draft,
        ),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tutanaklarım defterine kaydedildi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: Text(_template.title),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          for (final f in _template.fields) ...[
            TextField(
              controller: _controllers[f.key],
              minLines: f.multiline ? 3 : 1,
              maxLines: f.multiline ? 8 : 1,
              style: const TextStyle(
                color: PoliceColors.titleOnDark,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                labelText: f.label,
                labelStyle:
                    TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
                hintText: f.hint.isEmpty ? null : f.hint,
                hintStyle: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.55),
                ),
                filled: true,
                fillColor: PoliceColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'Taslak önizleme',
                style: TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _copy,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Kopyala'),
                style: TextButton.styleFrom(
                  foregroundColor: PoliceColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PoliceColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
              ),
            ),
            child: SelectableText(
              _draft,
              style: const TextStyle(
                color: PoliceColors.mevzuatBodyText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saveToSaha,
            icon: const Icon(Icons.save_alt_rounded),
            label: const Text('Saha defterine kaydet'),
            style: FilledButton.styleFrom(
              backgroundColor: PoliceColors.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bu taslak bilgilendirme amaçlıdır; resmî tutanak formatı, '
            'mevzuat ve birim talimatlarına göre düzenlenmelidir. '
            'Veri internete gönderilmez.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.85),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
