import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../common/theme/police_colors.dart';
import '../icerik/icerik_uyari.dart';
import 'dilekce_templates.dart';

class DilekceFormPage extends StatefulWidget {
  const DilekceFormPage({super.key, required this.templateId});

  final String templateId;

  @override
  State<DilekceFormPage> createState() => _DilekceFormPageState();
}

class _DilekceFormPageState extends State<DilekceFormPage> {
  late final DilekceTemplate _template;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _template = DilekceTemplate.byId(widget.templateId) ?? DilekceTemplate.all.first;
    for (final f in _template.fields) {
      final c = TextEditingController();
      c.addListener(() => setState(() {}));
      _controllers[f.key] = c;
    }
  }

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
      const SnackBar(content: Text('Dilekçe taslağı panoya kopyalandı')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: Text(_template.title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            _template.description,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          for (final f in _template.fields) ...[
            TextField(
              controller: _controllers[f.key],
              maxLines: f.multiline ? 4 : 1,
              style: const TextStyle(color: PoliceColors.titleOnDark),
              decoration: InputDecoration(
                labelText: f.label,
                hintText: f.hint.isEmpty ? null : f.hint,
                labelStyle: TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: PoliceColors.primaryBlue.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          Text(
            'Önizleme',
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PoliceColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PoliceColors.primaryBlue.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              _draft,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.95),
                fontSize: 13,
                height: 1.45,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _copy,
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Panoya kopyala'),
            style: FilledButton.styleFrom(
              backgroundColor: PoliceColors.primaryBlue,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            kIcerikTaslakUyari,
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
}
