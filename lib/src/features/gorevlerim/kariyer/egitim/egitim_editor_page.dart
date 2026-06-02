import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/theme/police_colors.dart';
import '../kariyer_file_store.dart';
import 'egitim_models.dart';
import 'egitim_store.dart';

class EgitimEditorPage extends StatefulWidget {
  const EgitimEditorPage({super.key, this.existing});

  final EgitimKayit? existing;

  @override
  State<EgitimEditorPage> createState() => _EgitimEditorPageState();
}

class _EgitimEditorPageState extends State<EgitimEditorPage> {
  final _picker = ImagePicker();
  late final TextEditingController _adCtrl;
  late final TextEditingController _kurumCtrl;
  late final TextEditingController _sureCtrl;
  late final TextEditingController _aciklamaCtrl;
  late DateTime _tarih;
  bool _sertifika = true;
  String? _belgePath;
  String? _sertifikaPath;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _adCtrl = TextEditingController(text: e?.ad ?? '');
    _kurumCtrl = TextEditingController(text: e?.kurum ?? '');
    _sureCtrl = TextEditingController(text: e?.sure ?? '');
    _aciklamaCtrl = TextEditingController(text: e?.aciklama ?? '');
    _tarih = e != null
        ? DateTime.fromMillisecondsSinceEpoch(e.tarihMs)
        : DateTime.now();
    _sertifika = e?.sertifika ?? true;
    _belgePath = e?.belgePath.isNotEmpty == true ? e!.belgePath : null;
    _sertifikaPath =
        e?.sertifikaPath.isNotEmpty == true ? e!.sertifikaPath : null;
  }

  @override
  void dispose() {
    _adCtrl.dispose();
    _kurumCtrl.dispose();
    _sureCtrl.dispose();
    _aciklamaCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String l) => InputDecoration(
        labelText: l,
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
        title: Text(widget.existing == null ? 'Kayıt ekle' : 'Düzenle'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _adCtrl,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Eğitim / sertifika adı *'),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Sertifika kaydı',
                style: TextStyle(color: PoliceColors.titleOnDark)),
            subtitle: const Text('Kapalıysa eğitim sayılır',
                style: TextStyle(color: PoliceColors.textMuted, fontSize: 12)),
            value: _sertifika,
            onChanged: (v) => setState(() => _sertifika = v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _kurumCtrl,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Kurum'),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tarih',
                style: TextStyle(color: PoliceColors.titleOnDark)),
            subtitle: Text(
              '${_tarih.day}.${_tarih.month}.${_tarih.year}',
              style: const TextStyle(color: PoliceColors.primaryBlue),
            ),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _tarih,
                firstDate: DateTime(1990),
                lastDate: DateTime.now(),
              );
              if (d != null) setState(() => _tarih = d);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sureCtrl,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Süre (ör. 5 gün, 40 saat)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _aciklamaCtrl,
            minLines: 2,
            maxLines: 4,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Açıklama'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final x = await _picker.pickImage(source: ImageSource.gallery);
                  if (x != null) setState(() => _sertifikaPath = x.path);
                },
                icon: const Icon(Icons.badge_outlined, size: 18),
                label: const Text('Sertifika görseli'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final r = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );
                  if (r?.files.single.path != null) {
                    setState(() => _belgePath = r!.files.single.path);
                  }
                },
                icon: const Icon(Icons.attach_file_rounded, size: 18),
                label: const Text('Belge dosyası'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () async {
              if (_adCtrl.text.trim().isEmpty) return;
              var belge = widget.existing?.belgePath ?? '';
              var sert = widget.existing?.sertifikaPath ?? '';
              if (_belgePath != null && _belgePath != widget.existing?.belgePath) {
                belge = await kariyerCopyFile(
                  sub: 'egitim',
                  sourcePath: _belgePath!,
                  prefix: 'doc',
                );
              }
              if (_sertifikaPath != null &&
                  _sertifikaPath != widget.existing?.sertifikaPath) {
                sert = await kariyerCopyFile(
                  sub: 'egitim',
                  sourcePath: _sertifikaPath!,
                  prefix: 'cert',
                );
              }
              if (!context.mounted) return;
              Navigator.of(context).pop(EgitimKayit(
                id: widget.existing?.id ?? egitimGenerateId(),
                ad: _adCtrl.text.trim(),
                kurum: _kurumCtrl.text.trim(),
                tarihMs: DateTime(_tarih.year, _tarih.month, _tarih.day)
                    .millisecondsSinceEpoch,
                sure: _sureCtrl.text.trim(),
                aciklama: _aciklamaCtrl.text.trim(),
                belgePath: belge,
                sertifikaPath: sert,
                sertifika: _sertifika,
                createdAtMs: widget.existing?.createdAtMs ??
                    DateTime.now().millisecondsSinceEpoch,
              ));
            },
            style: FilledButton.styleFrom(
              backgroundColor: PoliceColors.primaryBlue,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
