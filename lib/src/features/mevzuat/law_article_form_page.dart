import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/law_article.dart';
import 'law_management_controller.dart';

class LawArticleFormPage extends ConsumerStatefulWidget {
  final LawArticle? article;
  final String? initialLawCode;
  final String? initialLawName;

  const LawArticleFormPage({
    super.key,
    this.article,
    this.initialLawCode,
    this.initialLawName,
  });

  @override
  ConsumerState<LawArticleFormPage> createState() => _LawArticleFormPageState();
}

class _LawArticleFormPageState extends ConsumerState<LawArticleFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _lawCodeCtrl;
  late final TextEditingController _lawNameCtrl;
  late final TextEditingController _articleNumberCtrl;
  late final TextEditingController _officialTextCtrl;
  late final TextEditingController _plainSummaryCtrl;
  late final TextEditingController _fieldExampleCtrl;
  late final TextEditingController _commonMistakesCtrl;
  late final TextEditingController _sourceUrlCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.article;
    _lawCodeCtrl = TextEditingController(text: a?.lawCode ?? widget.initialLawCode ?? '');
    _lawNameCtrl = TextEditingController(text: a?.lawName ?? widget.initialLawName ?? '');
    _articleNumberCtrl = TextEditingController(text: a?.articleNumber.toString() ?? '');
    _officialTextCtrl = TextEditingController(text: a?.officialText ?? '');
    _plainSummaryCtrl = TextEditingController(text: a?.plainSummary ?? '');
    _fieldExampleCtrl = TextEditingController(text: a?.fieldExample ?? '');
    _commonMistakesCtrl = TextEditingController(text: a?.commonMistakes ?? '');
    _sourceUrlCtrl = TextEditingController(text: a?.sourceUrl ?? '');
  }

  @override
  void dispose() {
    _lawCodeCtrl.dispose();
    _lawNameCtrl.dispose();
    _articleNumberCtrl.dispose();
    _officialTextCtrl.dispose();
    _plainSummaryCtrl.dispose();
    _fieldExampleCtrl.dispose();
    _commonMistakesCtrl.dispose();
    _sourceUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final number = int.tryParse(_articleNumberCtrl.text.trim());
      if (number == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Madde numarası geçerli bir sayı olmalı.')),
        );
        setState(() => _isSaving = false);
        return;
      }
      final article = widget.article ?? LawArticle();
      article.lawCode = _lawCodeCtrl.text.trim();
      article.lawName = _lawNameCtrl.text.trim();
      article.articleNumber = number;
      article.officialText = _officialTextCtrl.text.trim();
      article.plainSummary = _plainSummaryCtrl.text.trim();
      article.fieldExample = _fieldExampleCtrl.text.trim().isEmpty ? null : _fieldExampleCtrl.text.trim();
      article.commonMistakes = _commonMistakesCtrl.text.trim().isEmpty ? null : _commonMistakesCtrl.text.trim();
      article.sourceUrl = _sourceUrlCtrl.text.trim().isEmpty ? null : _sourceUrlCtrl.text.trim();
      if (widget.article != null) {
        article.isFavorite = widget.article!.isFavorite;
        article.userNote = widget.article!.userNote;
        article.lastViewedAt = widget.article!.lastViewedAt;
        article.relatedArticleIds = List.from(widget.article!.relatedArticleIds);
      }
      await saveLawArticle(article);
      if (mounted) {
        ref.invalidate(lawsGroupedProvider);
        ref.invalidate(articlesByLawCodeProvider(article.lawCode));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kaydedildi.')),
        );
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.article != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Madde düzenle' : 'Yeni madde'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _lawCodeCtrl,
              decoration: const InputDecoration(
                labelText: 'Kanun kodu (örn. PVSK)',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Kanun kodu girin' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lawNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Kanun adı',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Kanun adı girin' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _articleNumberCtrl,
              decoration: const InputDecoration(
                labelText: 'Madde numarası',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.trim().isEmpty ?? true) return 'Madde numarası girin';
                if (int.tryParse(v!) == null) return 'Geçerli bir sayı girin';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _officialTextCtrl,
              decoration: const InputDecoration(
                labelText: 'Resmî metin',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Resmî metin girin' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _plainSummaryCtrl,
              decoration: const InputDecoration(
                labelText: 'Özet (sade dil)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Özet girin' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fieldExampleCtrl,
              decoration: const InputDecoration(
                labelText: 'Saha örneği (isteğe bağlı)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commonMistakesCtrl,
              decoration: const InputDecoration(
                labelText: 'Sık yapılan hatalar (isteğe bağlı)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sourceUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'Kaynak URL (isteğe bağlı)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Güncelle' : 'Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
