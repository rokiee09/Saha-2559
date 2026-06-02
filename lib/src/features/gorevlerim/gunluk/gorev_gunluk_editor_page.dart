import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/theme/police_colors.dart';
import 'gorev_gunluk_models.dart';
import 'gorev_gunluk_store.dart';

class _EditImage {
  _EditImage({required this.path, required this.persisted});
  final String path;
  final bool persisted;
}

class GorevGunlukEditorPage extends StatefulWidget {
  const GorevGunlukEditorPage({super.key, this.existing});

  final GorevGunlukKayit? existing;

  @override
  State<GorevGunlukEditorPage> createState() => _GorevGunlukEditorPageState();
}

class _GorevGunlukEditorPageState extends State<GorevGunlukEditorPage> {
  final _picker = ImagePicker();
  late final TextEditingController _gorevCtrl;
  late final TextEditingController _sureCtrl;
  late final TextEditingController _notCtrl;
  late final TextEditingController _ilCtrl;
  late final TextEditingController _ilceCtrl;
  late final TextEditingController _saatCtrl;
  late DateTime _tarih;
  late final List<_EditImage> _images;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final now = DateTime.now();
    _gorevCtrl = TextEditingController(text: e?.gorevAdi ?? '');
    _sureCtrl = TextEditingController(
      text: e != null && e.sureSaat > 0
          ? (e.sureSaat == e.sureSaat.roundToDouble()
              ? e.sureSaat.round().toString()
              : e.sureSaat.toString())
          : '',
    );
    _notCtrl = TextEditingController(text: e?.not ?? '');
    _ilCtrl = TextEditingController(text: e?.il ?? '');
    _ilceCtrl = TextEditingController(text: e?.ilce ?? '');
    _saatCtrl = TextEditingController(
      text: e?.saat ??
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    );
    _tarih = e != null
        ? DateTime(e.tarih.year, e.tarih.month, e.tarih.day)
        : DateTime(now.year, now.month, now.day);
    _images = [
      for (final p in e?.fotoPaths ?? const <String>[])
        _EditImage(path: p, persisted: true),
    ];
  }

  @override
  void dispose() {
    _gorevCtrl.dispose();
    _sureCtrl.dispose();
    _notCtrl.dispose();
    _ilCtrl.dispose();
    _ilceCtrl.dispose();
    _saatCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFoto(ImageSource source) async {
    try {
      final x = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (x == null) return;
      setState(() => _images.add(_EditImage(path: x.path, persisted: false)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf seçilemedi.')),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tarih,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) setState(() => _tarih = picked);
  }

  Future<void> _save() async {
    final gorev = _gorevCtrl.text.trim();
    final not = _notCtrl.text.trim();
    final saat = _saatCtrl.text.trim();
    final sure = double.tryParse(_sureCtrl.text.trim().replaceAll(',', '.'));
    if (gorev.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Görev adı zorunludur.')),
      );
      return;
    }
    if (saat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saat zorunludur.')),
      );
      return;
    }
    if (sure == null || sure <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir süre (saat) girin.')),
      );
      return;
    }
    if (not.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not zorunludur.')),
      );
      return;
    }

    setState(() => _saving = true);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final paths = <String>[];
    for (final img in _images) {
      if (img.persisted) {
        paths.add(img.path);
      } else {
        paths.add(await gorevGunlukSaveImage(img.path));
      }
    }
    final id = widget.existing?.id ?? gorevGunlukGenerateId();
    final created = widget.existing?.createdAtMs ?? nowMs;
    final entry = GorevGunlukKayit(
      id: id,
      tarihMs: DateTime(_tarih.year, _tarih.month, _tarih.day)
          .millisecondsSinceEpoch,
      saat: saat,
      gorevAdi: gorev,
      sureSaat: sure,
      not: not,
      il: _ilCtrl.text.trim(),
      ilce: _ilceCtrl.text.trim(),
      fotoPaths: paths,
      createdAtMs: created,
      updatedAtMs: nowMs,
    );
    await gorevGunlukUpsert(entry);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
        hintStyle: TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.55)),
        filled: true,
        fillColor: PoliceColors.surfaceDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: Text(widget.existing == null ? 'Görev ekle' : 'Görev düzenle'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              'Kaydet',
              style: TextStyle(
                color: _saving
                    ? PoliceColors.textMuted
                    : PoliceColors.primaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tarih', style: TextStyle(color: PoliceColors.titleOnDark)),
            subtitle: Text(
              '${_tarih.day.toString().padLeft(2, '0')}.'
              '${_tarih.month.toString().padLeft(2, '0')}.'
              '${_tarih.year}',
              style: const TextStyle(color: PoliceColors.primaryBlue, fontSize: 16),
            ),
            trailing: const Icon(Icons.calendar_today_rounded,
                color: PoliceColors.primaryBlue),
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _saatCtrl,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Saat *', hint: 'ss:dd'),
            keyboardType: TextInputType.datetime,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _gorevCtrl,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec(
              'Görev adı *',
              hint: 'Vali Koruma, Mahkeme, Nokta…',
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sureCtrl,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Süre (saat) *', hint: '8'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notCtrl,
            minLines: 3,
            maxLines: 6,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Not *'),
          ),
          const SizedBox(height: 16),
          Text(
            'İsteğe bağlı',
            style: TextStyle(
              color: PoliceColors.gold.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ilCtrl,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('İl'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ilceCtrl,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('İlçe'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _pickFoto(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: const Text('Kamera'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _pickFoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Galeri'),
              ),
            ],
          ),
          if (_images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final img = _images[i];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(img.path),
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => setState(() => _images.removeAt(i)),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
