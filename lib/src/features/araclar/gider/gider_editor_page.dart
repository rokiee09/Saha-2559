import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../common/theme/police_colors.dart';
import 'gider_models.dart';
import 'gider_store.dart';

class _EditImage {
  _EditImage({required this.path, required this.persisted});
  final String path;

  /// true: uygulama klasöründe kayıtlı; false: yeni seçilen geçici dosya.
  final bool persisted;
}

class GiderEditorPage extends StatefulWidget {
  const GiderEditorPage({super.key, this.existing});

  final GiderKayit? existing;

  @override
  State<GiderEditorPage> createState() => _GiderEditorPageState();
}

class _GiderEditorPageState extends State<GiderEditorPage> {
  final _picker = ImagePicker();
  late final TextEditingController _baslikCtrl;
  late final TextEditingController _tutarCtrl;
  late final TextEditingController _kategoriCtrl;
  late final TextEditingController _notCtrl;
  late DateTime _tarih;
  late final List<_EditImage> _images;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _baslikCtrl = TextEditingController(text: e?.baslik ?? '');
    _tutarCtrl = TextEditingController(
      text: (e != null && e.tutar > 0)
          ? e.tutar.toStringAsFixed(2).replaceAll('.', ',')
          : '',
    );
    _kategoriCtrl = TextEditingController(text: e?.kategori ?? '');
    _notCtrl = TextEditingController(text: e?.not ?? '');
    _tarih = e != null
        ? DateTime.fromMillisecondsSinceEpoch(e.tarihMs)
        : DateTime.now();
    _images = [
      for (final p in e?.fisPaths ?? const <String>[])
        _EditImage(path: p, persisted: true),
    ];
  }

  @override
  void dispose() {
    _baslikCtrl.dispose();
    _tutarCtrl.dispose();
    _kategoriCtrl.dispose();
    _notCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (x == null) return;
      setState(() {
        _images.add(_EditImage(path: x.path, persisted: false));
      });
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Görüntü alınamadı: $err')),
      );
    }
  }

  void _addFisMenu() {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: PoliceColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const PhosphorIcon(PhosphorIconsRegular.camera,
                  color: PoliceColors.primaryBlue),
              title: const Text('Kamera ile fiş çek',
                  style: TextStyle(color: PoliceColors.titleOnDark)),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const PhosphorIcon(PhosphorIconsRegular.image,
                  color: PoliceColors.primaryBlue),
              title: const Text('Galeriden seç',
                  style: TextStyle(color: PoliceColors.titleOnDark)),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _viewImage(String path) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FisViewerPage(path: path),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final baslik = _baslikCtrl.text.trim();
    if (baslik.isEmpty && _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlık girin veya fiş ekleyin.')),
      );
      return;
    }
    setState(() => _saving = true);

    final tutar = _parseTutar(_tutarCtrl.text);
    final now = DateTime.now().millisecondsSinceEpoch;

    // Yeni seçilen görüntüleri kalıcı klasöre kopyala.
    final finalPaths = <String>[];
    for (final img in _images) {
      if (img.persisted) {
        finalPaths.add(img.path);
      } else {
        try {
          finalPaths.add(await giderSaveImage(img.path));
        } catch (_) {
          // Kopyalanamayan görüntüyü atla.
        }
      }
    }

    // Kayıttan çıkarılan eski fişlerin dosyalarını sil.
    final old = widget.existing?.fisPaths ?? const <String>[];
    for (final p in old) {
      if (!finalPaths.contains(p)) {
        await giderDeleteImageFile(p);
      }
    }

    final entry = widget.existing != null
        ? widget.existing!.copyWith(
            baslik: baslik.isEmpty ? 'Gider' : baslik,
            tutar: tutar,
            tarihMs: _tarih.millisecondsSinceEpoch,
            updatedAtMs: now,
            kategori: _kategoriCtrl.text.trim(),
            not: _notCtrl.text.trim(),
            fisPaths: finalPaths,
          )
        : GiderKayit(
            id: giderGenerateId(),
            baslik: baslik.isEmpty ? 'Gider' : baslik,
            tutar: tutar,
            tarihMs: _tarih.millisecondsSinceEpoch,
            createdAtMs: now,
            updatedAtMs: now,
            kategori: _kategoriCtrl.text.trim(),
            not: _notCtrl.text.trim(),
            fisPaths: finalPaths,
          );

    await giderUpsert(entry);
    await HapticFeedback.lightImpact();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  static double _parseTutar(String raw) {
    final cleaned = raw.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tarih,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _tarih = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: Text(
            widget.existing == null ? 'O-1 gider · Yeni' : 'Gideri düzenle'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text(
              'Kaydet',
              style: TextStyle(
                color: PoliceColors.primaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _field(
            controller: _baslikCtrl,
            label: 'Açıklama',
            hint: 'Örn. Görev yolu yakıt',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _field(
                  controller: _tutarCtrl,
                  label: 'Tutar (TL)',
                  hint: '0,00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: _decoration('Tarih'),
                    child: Text(
                      _fmtDate(_tarih),
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _field(
            controller: _kategoriCtrl,
            label: 'Kategori (isteğe bağlı)',
            hint: 'Yakıt / yemek / konaklama…',
          ),
          const SizedBox(height: 12),
          _field(
            controller: _notCtrl,
            label: 'Not (isteğe bağlı)',
            hint: 'Serbest açıklama…',
            minLines: 2,
            maxLines: 5,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Fişler',
                  style: TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _addFisMenu,
                icon: const Icon(Icons.add_a_photo_rounded,
                    color: PoliceColors.primaryBlue, size: 20),
                label: const Text(
                  'Fiş ekle',
                  style: TextStyle(
                    color: PoliceColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_images.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 26),
              decoration: BoxDecoration(
                color: PoliceColors.surfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  const PhosphorIcon(
                    PhosphorIconsRegular.receipt,
                    color: PoliceColors.textMuted,
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kamera ile fiş çek veya galeriden ekle.',
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.9),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                for (var i = 0; i < _images.length; i++) _thumb(_images[i], i),
              ],
            ),
          const SizedBox(height: 16),
          Text(
            'Bu gider kayıtları ve fiş görüntüleri yalnızca bu cihazda saklanır; '
            'internete gönderilmez. Resmî belge yerine geçmez.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.8),
              fontSize: 11.5,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb(_EditImage img, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => _viewImage(img.path),
            child: Image.file(
              File(img.path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: PoliceColors.surfaceDark,
                child: const Icon(Icons.broken_image_rounded,
                    color: PoliceColors.textMuted),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _images.removeAt(index));
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    int minLines = 1,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: PoliceColors.titleOnDark, fontSize: 15),
      decoration: _decoration(label, hint: hint),
    );
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
      hintText: hint,
      hintStyle:
          TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.5)),
      filled: true,
      fillColor: PoliceColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }
}

class _FisViewerPage extends StatelessWidget {
  const _FisViewerPage({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Fiş'),
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 5,
          child: Image.file(
            File(path),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text(
              'Görüntü açılamadı.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }
}
