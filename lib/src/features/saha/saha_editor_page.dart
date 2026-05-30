import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _SahaEditorPageState extends ConsumerState<SahaEditorPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late final Set<String> _tags;

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
    if (title.isEmpty && body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlık veya içerik girin.')),
      );
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final tags = _tags.toList();
    final note = widget.existing != null
        ? widget.existing!.copyWith(
            title: title.isEmpty ? widget.existing!.title : title,
            body: body,
            updatedAtMs: now,
            tags: tags,
          )
        : SahaNote(
            id: sahaGenerateNoteId(),
            categoryId: widget.categoryId,
            title: title.isEmpty ? 'Not' : title,
            body: body,
            createdAtMs: now,
            updatedAtMs: now,
            tags: tags,
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
              hintText: 'Serbest metin…',
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
          const SizedBox(height: 16),
          Text(
            'Bu kayıtlar internete gönderilmez; yedek için dışa aktarım özelliği yoktur.',
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
}
