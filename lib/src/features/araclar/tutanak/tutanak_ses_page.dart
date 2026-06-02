import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../common/routing/transitions.dart';
import '../../../common/theme/police_colors.dart';
import 'tutanak_form_page.dart';
import 'tutanak_templates.dart';

/// Mikrofonla tutanak metni oluşturma — ses tanıma cihazda çalışır.
class TutanakSesPage extends StatefulWidget {
  const TutanakSesPage({super.key});

  @override
  State<TutanakSesPage> createState() => _TutanakSesPageState();
}

class _TutanakSesPageState extends State<TutanakSesPage> {
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _text = TextEditingController();
  bool _ready = false;
  bool _listening = false;
  String? _templateId;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final ok = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          if (mounted) setState(() => _listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (mounted) setState(() => _ready = ok);
  }

  @override
  void dispose() {
    _speech.stop();
    _text.dispose();
    super.dispose();
  }

  Future<void> _toggleListen() async {
    if (!_ready) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ses tanıma bu cihazda kullanılamıyor.')),
      );
      return;
    }
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _listening = true);
    await _speech.listen(
      listenOptions: SpeechListenOptions(localeId: 'tr_TR'),
      onResult: (r) {
        setState(() {
          if (r.finalResult) {
            final prev = _text.text.trim();
            final chunk = r.recognizedWords.trim();
            if (chunk.isEmpty) return;
            _text.text = prev.isEmpty ? chunk : '$prev\n$chunk';
            _text.selection = TextSelection.collapsed(offset: _text.text.length);
          }
        });
      },
    );
  }

  void _openTemplateForm() {
    final id = _templateId ?? TutanakTemplate.all.first.id;
    final template = TutanakTemplate.byId(id)!;
    final values = <String, String>{};
    for (final f in template.fields) {
      values[f.key] = '';
    }
    if (template.fields.any((f) => f.key == 'tarih')) {
      final now = DateTime.now();
      values['tarih'] =
          '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
      values['saat'] =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    }
    String? voiceKey;
    for (final f in template.fields) {
      if (f.voiceFriendly || f.multiline) {
        voiceKey = f.key;
        break;
      }
    }
    if (voiceKey != null) {
      values[voiceKey] = _text.text.trim();
    }
    Navigator.of(context).push(
      fadeRoute(TutanakFormPage(
        templateId: id,
        initialValues: values,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Sesle Tutanak'),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PoliceColors.primaryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: PoliceColors.primaryBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'Mikrofona konuş; metin otomatik yazılır. Örn: "15 Mayıs günü '
              'saat 22.30 sıralarında..." Sonra şablonla birleştirip PDF al.',
              style: TextStyle(
                color: PoliceColors.titleOnDark.withValues(alpha: 0.9),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Material(
              color: _listening
                  ? Colors.red.withValues(alpha: 0.85)
                  : PoliceColors.primaryBlue,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _toggleListen,
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: Icon(
                    _listening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _listening ? 'Dinleniyor…' : 'Konuşmak için dokun',
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _text,
            minLines: 8,
            maxLines: 16,
            style: const TextStyle(color: PoliceColors.titleOnDark, fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Sesle yazılan metin',
              labelStyle:
                  TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
              filled: true,
              fillColor: PoliceColors.surfaceDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _templateId ?? TutanakTemplate.all.first.id,
            dropdownColor: PoliceColors.surfaceDark,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: InputDecoration(
              labelText: 'Hedef şablon',
              labelStyle:
                  TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
              filled: true,
              fillColor: PoliceColors.surfaceDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: [
              for (final t in TutanakTemplate.all)
                DropdownMenuItem(value: t.id, child: Text(t.title)),
            ],
            onChanged: (v) => setState(() => _templateId = v),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _text.text.trim().isEmpty ? null : _openTemplateForm,
            icon: const PhosphorIcon(PhosphorIconsRegular.arrowRight, size: 20),
            label: const Text('Şablona aktar'),
            style: FilledButton.styleFrom(
              backgroundColor: PoliceColors.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
