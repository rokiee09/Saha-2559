import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/theme/police_colors.dart';
import '../kariyer_file_store.dart';
import 'basari_models.dart';
import 'basari_store.dart';

class BasariEditorPage extends StatefulWidget {
  const BasariEditorPage({
    super.key,
    this.existing,
    required this.tur,
  });

  final BasariBelge? existing;
  final BasariBelgeTuru tur;

  @override
  State<BasariEditorPage> createState() => _BasariEditorPageState();
}

class _BasariEditorPageState extends State<BasariEditorPage> {
  final _picker = ImagePicker();
  late DateTime _tarih;
  late final TextEditingController _makamCtrl;
  late final TextEditingController _evrakCtrl;
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
    _makamCtrl = TextEditingController(text: e?.verenMakam ?? '');
    _evrakCtrl = TextEditingController(text: e?.evrakNo ?? '');
    _aciklamaCtrl = TextEditingController(text: e?.aciklama ?? '');
    _notCtrl = TextEditingController(text: e?.not ?? '');
    _fotoPath = e?.fotoPath.isNotEmpty == true ? e!.fotoPath : null;
    _pdfPath = e?.pdfPath.isNotEmpty == true ? e!.pdfPath : null;
  }

  @override
  void dispose() {
    _makamCtrl.dispose();
    _evrakCtrl.dispose();
    _aciklamaCtrl.dispose();
    _notCtrl.dispose();
    super.dispose();
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
    final turLabel = widget.tur.label;
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: Text(widget.existing == null ? '$turLabel ekle' : '$turLabel düzenle'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Belge tarihi',
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
            controller: _makamCtrl,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Veren makam'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _evrakCtrl,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Belge sayısı / evrak no'),
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
                        sub: 'basari',
                        sourcePath: _fotoPath!,
                        prefix: 'foto',
                      );
                    }
                    if (_pdfPath != null &&
                        _pdfPath != widget.existing?.pdfPath) {
                      pdf = await kariyerCopyFile(
                        sub: 'basari',
                        sourcePath: _pdfPath!,
                        prefix: 'pdf',
                      );
                    }
                    final belge = BasariBelge(
                      id: widget.existing?.id ?? basariGenerateId(),
                      tur: widget.tur,
                      tarihMs: DateTime(
                        _tarih.year,
                        _tarih.month,
                        _tarih.day,
                      ).millisecondsSinceEpoch,
                      verenMakam: _makamCtrl.text.trim(),
                      evrakNo: _evrakCtrl.text.trim(),
                      aciklama: _aciklamaCtrl.text.trim(),
                      not: _notCtrl.text.trim(),
                      fotoPath: foto,
                      pdfPath: pdf,
                      createdAtMs: widget.existing?.createdAtMs ??
                          DateTime.now().millisecondsSinceEpoch,
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop(belge);
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
