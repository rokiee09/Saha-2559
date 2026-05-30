import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../common/theme/police_colors.dart';
import 'saha_categories.dart';
import 'saha_note.dart';
import 'saha_store.dart';

class SahaEditorPage extends ConsumerStatefulWidget {
  const SahaEditorPage({
    super.key,
    required this.categoryId,
    this.existing,
    this.initialTitle,
    this.initialBody,
  });

  final String categoryId;
  final SahaNote? existing;

  /// Yeni kayıt (existing == null) için ön-doldurulacak başlık/içerik.
  final String? initialTitle;
  final String? initialBody;

  @override
  ConsumerState<SahaEditorPage> createState() => _SahaEditorPageState();
}

class _EditImage {
  _EditImage({required this.path, required this.persisted});
  final String path;
  final bool persisted;
}

class _SahaEditorPageState extends ConsumerState<SahaEditorPage> {
  final _picker = ImagePicker();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late final Set<String> _tags;
  late final List<_EditImage> _images;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(
      text: widget.existing?.title ?? widget.initialTitle ?? '',
    );
    _bodyCtrl = TextEditingController(
      text: widget.existing?.body ?? widget.initialBody ?? '',
    );
    _tags = {...?widget.existing?.tags};
    _images = [
      for (final p in widget.existing?.imagePaths ?? const <String>[])
        _EditImage(path: p, persisted: true),
    ];
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (x == null) return;
      setState(() => _images.add(_EditImage(path: x.path, persisted: false)));
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Görüntü alınamadı: $err')),
      );
    }
  }

  void _addImageMenu() {
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
              title: const Text('Kamera ile çek',
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
        builder: (_) => _SahaImageViewer(path: path),
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty && body.isEmpty && _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlık, içerik veya görüntü ekleyin.')),
      );
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final tags = _tags.toList();

    // Yeni eklenen görüntüleri kalıcı klasöre kopyala.
    final finalImages = <String>[];
    for (final img in _images) {
      if (img.persisted) {
        finalImages.add(img.path);
      } else {
        try {
          finalImages.add(await sahaSaveImage(img.path));
        } catch (_) {
          // Kopyalanamayanı atla.
        }
      }
    }
    // Çıkarılan eski görüntülerin dosyalarını sil.
    for (final p in widget.existing?.imagePaths ?? const <String>[]) {
      if (!finalImages.contains(p)) {
        await sahaDeleteImageFile(p);
      }
    }

    final note = widget.existing != null
        ? widget.existing!.copyWith(
            title: title.isEmpty ? widget.existing!.title : title,
            body: body,
            updatedAtMs: now,
            tags: tags,
            imagePaths: finalImages,
          )
        : SahaNote(
            id: sahaGenerateNoteId(),
            categoryId: widget.categoryId,
            title: title.isEmpty ? 'Not' : title,
            body: body,
            createdAtMs: now,
            updatedAtMs: now,
            tags: tags,
            imagePaths: finalImages,
          );
    await HapticFeedback.lightImpact();
    await sahaUpsertNote(ref, note);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _confirmDelete() async {
    final id = widget.existing?.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PoliceColors.surfaceDark,
        title: const Text(
          'Silinsin mi?',
          style: TextStyle(color: PoliceColors.titleOnDark),
        ),
        content: const Text(
          'Bu kayıt cihazdan kalıcı olarak silinir.',
          style: TextStyle(color: PoliceColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: PoliceColors.primaryBlue,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await sahaDeleteNote(ref, id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final def = SahaCategoryDef.byId(widget.categoryId);
    final catTitle = def?.title ?? 'Kayıt';

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.mevzuatTitleGrey,
        title: Text(widget.existing == null ? '$catTitle · Yeni' : 'Düzenle'),
        actions: [
          if (widget.existing != null)
            IconButton(
              tooltip: 'Sil',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _confirmDelete,
            ),
          TextButton(
            onPressed: _save,
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
          bottom: BorderSide(
            color: PoliceColors.accentMix(0.34),
            width: 1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              labelText: 'Başlık',
              labelStyle: TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
              hintText: 'Kısa başlık…',
              hintStyle: TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.55)),
              filled: true,
              fillColor: PoliceColors.surfaceDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _bodyCtrl,
            minLines: 10,
            maxLines: 22,
            style: const TextStyle(
              color: PoliceColors.mevzuatBodyText,
              height: 1.45,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              alignLabelWithHint: true,
              labelText: 'İçerik',
              labelStyle: TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
              hintText: widget.categoryId == 'notlar'
                  ? 'Plaka, kişi/TC, olay yeri, gözlem ve durum notları…'
                  : 'Serbest metin…',
              hintStyle: TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.55)),
              filled: true,
              fillColor: PoliceColors.surfaceDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Etiketler',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final tag in SahaTag.all)
                FilterChip(
                  label: Text(tag.label),
                  selected: _tags.contains(tag.id),
                  showCheckmark: true,
                  backgroundColor: PoliceColors.surfaceDark,
                  selectedColor:
                      PoliceColors.primaryBlue.withValues(alpha: 0.28),
                  checkmarkColor: PoliceColors.titleOnDark,
                  labelStyle: TextStyle(
                    color: _tags.contains(tag.id)
                        ? PoliceColors.titleOnDark
                        : PoliceColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
                  ),
                  onSelected: (sel) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (sel) {
                        _tags.add(tag.id);
                      } else {
                        _tags.remove(tag.id);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Görüntüler',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _addImageMenu,
                icon: const Icon(Icons.add_a_photo_rounded,
                    color: PoliceColors.primaryBlue, size: 20),
                label: const Text(
                  'Görüntü ekle',
                  style: TextStyle(
                    color: PoliceColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (_images.isNotEmpty)
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
            'Bu kayıtlar ve görüntüler yalnızca bu cihazda saklanır; internete '
            'gönderilmez ve dışa aktarım özelliği yoktur.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.85),
              fontSize: 12,
              height: 1.35,
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
}

class _SahaImageViewer extends StatelessWidget {
  const _SahaImageViewer({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Görüntü'),
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
