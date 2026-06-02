import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../common/theme/police_colors.dart';
import '../../saha/saha_editor_page.dart';
import 'tutanak_checker.dart';
import 'tutanak_favorites.dart';
import 'tutanak_pdf.dart';
import 'tutanak_templates.dart';

class TutanakFormPage extends StatefulWidget {
  const TutanakFormPage({
    super.key,
    required this.templateId,
    this.initialValues,
  });

  final String templateId;
  final Map<String, String>? initialValues;

  @override
  State<TutanakFormPage> createState() => _TutanakFormPageState();
}

class _TutanakFormPageState extends State<TutanakFormPage> {
  late final TutanakTemplate _template;
  final Map<String, TextEditingController> _controllers = {};
  final SpeechToText _speech = SpeechToText();
  bool _speechReady = false;
  String? _listeningField;

  @override
  void initState() {
    super.initState();
    _template = TutanakTemplate.byId(widget.templateId) ??
        TutanakTemplate.all.first;
    final now = DateTime.now();
    final tarih = '${_d2(now.day)}.${_d2(now.month)}.${now.year}';
    final saat = '${_d2(now.hour)}:${_d2(now.minute)}';
    for (final f in _template.fields) {
      final preset = widget.initialValues?[f.key];
      final initial = preset ??
          (f.key == 'tarih'
              ? tarih
              : f.key == 'saat'
                  ? saat
                  : '');
      final c = TextEditingController(text: initial);
      c.addListener(_onChanged);
      _controllers[f.key] = c;
    }
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final ok = await _speech.initialize();
    if (mounted) setState(() => _speechReady = ok);
  }

  static String _d2(int v) => v.toString().padLeft(2, '0');

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _speech.stop();
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

  Future<void> _exportPdf() async {
    await TutanakPdf.export(title: _template.title, body: _draft);
    await TutanakFavoritesStore.recordUse(_template.id);
  }

  Future<void> _runCheck() async {
    final issues = TutanakChecker.check(values: _values, draft: _draft);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: PoliceColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tutanak kontrolü',
                style: TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                issues.isEmpty
                    ? 'Belirgin eksiklik görünmüyor. Yine de metni okuyup imza '
                        'alanlarını kontrol edin.'
                    : 'Aşağıdaki hususları gözden geçirin:',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              if (issues.isEmpty)
                const PhosphorIcon(
                  PhosphorIconsFill.sealCheck,
                  color: Color(0xFF4ADE80),
                  size: 36,
                )
              else
                for (final i in issues)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          i.severity == TutanakCheckSeverity.warning
                              ? Icons.warning_amber_rounded
                              : Icons.info_outline_rounded,
                          color: i.severity == TutanakCheckSeverity.warning
                              ? const Color(0xFFFBBF24)
                              : PoliceColors.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            i.message,
                            style: const TextStyle(
                              color: PoliceColors.titleOnDark,
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _dictateToField(String fieldKey) async {
    if (!_speechReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ses tanıma kullanılamıyor.')),
      );
      return;
    }
    if (_listeningField == fieldKey) {
      await _speech.stop();
      setState(() => _listeningField = null);
      return;
    }
    await _speech.stop();
    setState(() => _listeningField = fieldKey);
    final controller = _controllers[fieldKey]!;
    await _speech.listen(
      listenOptions: SpeechListenOptions(localeId: 'tr_TR'),
      onResult: (r) {
        if (!r.finalResult) return;
        final chunk = r.recognizedWords.trim();
        if (chunk.isEmpty) return;
        final prev = controller.text.trim();
        controller.text = prev.isEmpty ? chunk : '$prev $chunk';
        controller.selection =
            TextSelection.collapsed(offset: controller.text.length);
        setState(() => _listeningField = null);
      },
    );
  }

  Future<void> _saveToSaha() async {
    await TutanakFavoritesStore.recordUse(_template.id);
    if (!mounted) return;
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
        const SnackBar(content: Text('Tutanak Merkezi defterine kaydedildi.')),
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
        actions: [
          IconButton(
            tooltip: 'Kontrol et',
            onPressed: _runCheck,
            icon: const PhosphorIcon(PhosphorIconsRegular.shieldCheck),
          ),
        ],
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
                labelStyle: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.9),
                ),
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
                suffixIcon: f.multiline || f.voiceFriendly
                    ? IconButton(
                        tooltip: 'Sesle yaz',
                        onPressed: () => _dictateToField(f.key),
                        icon: Icon(
                          _listeningField == f.key
                              ? Icons.stop_circle_outlined
                              : Icons.mic_none_rounded,
                          color: _listeningField == f.key
                              ? Colors.redAccent
                              : PoliceColors.primaryBlue,
                        ),
                      )
                    : null,
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
            onPressed: _exportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
            label: const Text('PDF paylaş'),
            style: FilledButton.styleFrom(
              backgroundColor: PoliceColors.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _saveToSaha,
            icon: const Icon(Icons.save_alt_rounded),
            label: const Text('Deftere kaydet'),
            style: OutlinedButton.styleFrom(
              foregroundColor: PoliceColors.titleOnDark,
              side: BorderSide(
                color: PoliceColors.outlineMuted.withValues(alpha: 0.6),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bu taslak bilgilendirme amaçlıdır; resmî tutanak formatı, '
            'mevzuat ve birim talimatlarına göre düzenlenmelidir.',
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
