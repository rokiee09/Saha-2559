import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/theme/police_colors.dart';
import '../asistan_provider.dart';
import '../decision_support/legal_llm_config.dart';

/// Mevzuat asistanı — kaynaklı AI özet (RAG) ayarları.
class AsistanLlmSettingsPage extends ConsumerStatefulWidget {
  const AsistanLlmSettingsPage({super.key});

  @override
  ConsumerState<AsistanLlmSettingsPage> createState() =>
      _AsistanLlmSettingsPageState();
}

class _AsistanLlmSettingsPageState extends ConsumerState<AsistanLlmSettingsPage> {
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  bool _enabled = false;
  bool _obscureKey = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final config = await LegalLlmConfigStorage.load();
    if (!mounted) return;
    setState(() {
      _enabled = config.enabled;
      _apiKeyController.text = config.apiKey;
      _baseUrlController.text = config.baseUrl;
      _modelController.text = config.model;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final config = LegalLlmConfig(
      enabled: _enabled,
      apiKey: _apiKeyController.text.trim(),
      baseUrl: _baseUrlController.text.trim().isEmpty
          ? LegalLlmConfig.kDefaultLlmBaseUrl
          : _baseUrlController.text.trim(),
      model: _modelController.text.trim().isEmpty
          ? LegalLlmConfig.kDefaultLlmModel
          : _modelController.text.trim(),
    );
    await LegalLlmConfigStorage.save(config);
    ref.invalidate(legalLlmConfigProvider);
    ref.invalidate(legalDecisionEngineProvider);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Asistan AI ayarları kaydedildi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistan AI özeti (RAG)')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Kapalıyken yanıtlar yalnızca telefondaki mevzuat indeksinden '
                      'üretilir. Açıkken önce aynı yerel kaynaklar bulunur, ardından '
                      'seçtiğiniz modele yalnızca bu kaynaklar gönderilir; model '
                      'kaynak dışına çıkmaması için yönlendirilir. Soru metni API '
                      'sağlayıcısına gider — gizli operasyonel bilgi yazmayın.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.45,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Kaynaklı AI özet'),
                  subtitle: Text(
                    _enabled
                        ? 'Açık — güçlü eşleşmede LLM özeti denenir'
                        : 'Kapalı — yalnızca yerel özet',
                  ),
                  value: _enabled,
                  onChanged: (v) => setState(() => _enabled = v),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureKey,
                  decoration: InputDecoration(
                    labelText: 'API anahtarı',
                    hintText: 'sk-... veya sağlayıcı anahtarınız',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureKey
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureKey = !_obscureKey),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _baseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'API adresi (OpenAI uyumlu)',
                    hintText: 'https://api.openai.com/v1',
                    helperText:
                        'Yerel Ollama: http://10.0.2.2:11434/v1 (emülatör)',
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    hintText: 'gpt-4o-mini',
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Kaydet'),
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
