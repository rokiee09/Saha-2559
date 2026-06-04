import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/theme/police_colors.dart';
import '../kariyer_file_store.dart';
import 'taltif_models.dart';
import 'taltif_store.dart';

class TaltifEditorPage extends StatefulWidget {
  const TaltifEditorPage({super.key, this.existing});

  final TaltifKayit? existing;

  @override
  State<TaltifEditorPage> createState() => _TaltifEditorPageState();
}

class _TaltifEditorPageState extends State<TaltifEditorPage> {
  final _picker = ImagePicker();
  late DateTime _tarih;
  late final TextEditingController _tutarCtrl;
  late final TextEditingController _makamCtrl;
  late final TextEditingController _aciklamaCtrl;
  late final TextEditingController _notCtrl;
  String? _fotoPath;
  String? _pdfPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _tarih = e != null
        ? DateTime.fromMillisecondsSinceEpoch(e.tarihMs)
        : DateTime.now();
    _tutarCtrl = TextEditingController(
      text: e != null && e.tutar > 0 ? '${e.tutar}' : '',
    );
    _makamCtrl = TextEditingController(text: e?.verenMakam ?? '');
    _aciklamaCtrl = TextEditingController(text: e?.aciklama ?? '');
    _notCtrl = TextEditingController(text: e?.not ?? '');
    _fotoPath = e?.fotoPath.isNotEmpty == true ? e!.fotoPath : null;
    _pdfPath = e?.pdfPath.isNotEmpty == true ? e!.pdfPath : null;
  }

  @override
  void dispose() {
    _tutarCtrl.dispose();
    _makamCtrl.dispose();
    _aciklamaCtrl.dispose();
    _notCtrl.dispose();
    super.dispose();
  }

  int _parseTutar() {
    final raw = _tutarCtrl.text.replaceAll('.', '').replaceAll(',', '.').trim();
    return (double.tryParse(raw) ?? 0).round();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _tarih,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    if (d != null) setState(() => _tarih = d);
  }

  Future<void> _pickFoto() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (x != null) setState(() => _fotoPath = x.path);
  }

  Future<void> _pickPdf() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (r != null && r.files.single.path != null) {
      setState(() => _pdfPath = r.files.single.path);
    }
  }

  InputDecoration _dec(String l) => InputDecoration(
        labelText: l,
        labelStyle:
            TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
        filled: true,
        fillColor: PoliceColors.surfaceDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: Text(widget.existing == null ? 'Taltif ekle' : 'Taltif düzenle'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Taltif tarihi',
                style: TextStyle(color: PoliceColors.titleOnDark)),
            subtitle: Text(
              '${_tarih.day.toString().padLeft(2, '0')}.'
              '${_tarih.month.toString().padLeft(2, '0')}.'
              '${_tarih.year}',
              style: const TextStyle(color: PoliceColors.primaryBlue),
            ),
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tutarCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Taltif tutarı (TL)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _makamCtrl,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Veren makam'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _aciklamaCtrl,
            minLines: 2,
            maxLines: 5,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Açıklama / konu'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notCtrl,
            minLines: 2,
            maxLines: 4,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Not'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickFoto,
                icon: const Icon(Icons.image_outlined, size: 18),
                label: const Text('Belge görseli'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _pickPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('PDF'),
              ),
            ],
          ),
          if (_fotoPath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_fotoPath!),
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ],
          if (_pdfPath != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'PDF: ${_pdfPath!.split(Platform.pathSeparator).last}',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.9),
                ),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    var foto = widget.existing?.fotoPath ?? '';
                    var pdf = widget.existing?.pdfPath ?? '';
                    if (_fotoPath != null &&
                        _fotoPath != widget.existing?.fotoPath) {
                      foto = await kariyerCopyFile(
                        sub: 'taltif',
                        sourcePath: _fotoPath!,
                        prefix: 'foto',
                      );
                    }
                    if (_pdfPath != null &&
                        _pdfPath != widget.existing?.pdfPath) {
                      pdf = await kariyerCopyFile(
                        sub: 'taltif',
                        sourcePath: _pdfPath!,
                        prefix: 'pdf',
                      );
                    }
                    final kayit = TaltifKayit(
                      id: widget.existing?.id ?? taltifGenerateId(),
                      tarihMs: DateTime(
                        _tarih.year,
                        _tarih.month,
                        _tarih.day,
                      ).millisecondsSinceEpoch,
                      tutar: _parseTutar(),
                      verenMakam: _makamCtrl.text.trim(),
                      aciklama: _aciklamaCtrl.text.trim(),
                      not: _notCtrl.text.trim(),
                      fotoPath: foto,
                      pdfPath: pdf,
                      createdAtMs: widget.existing?.createdAtMs ??
                          DateTime.now().millisecondsSinceEpoch,
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop(kayit);
                  },
            style: FilledButton.styleFrom(
              backgroundColor: PoliceColors.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
