import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// LLM / RAG yapılandırması (isteğe bağlı — kapalıyken yalnızca yerel indeks).
class LegalLlmConfig {
  const LegalLlmConfig({
    this.enabled = false,
    this.apiKey = '',
    this.baseUrl = kDefaultLlmBaseUrl,
    this.model = kDefaultLlmModel,
  });

  final bool enabled;
  final String apiKey;
  final String baseUrl;
  final String model;

  static const kDefaultLlmBaseUrl = 'https://api.openai.com/v1';
  static const kDefaultLlmModel = 'gpt-4o-mini';

  bool get isReady =>
      enabled && apiKey.trim().isNotEmpty && baseUrl.trim().isNotEmpty;

  String get chatCompletionsUrl {
    final base = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    return '$base/chat/completions';
  }

  LegalLlmConfig copyWith({
    bool? enabled,
    String? apiKey,
    String? baseUrl,
    String? model,
  }) {
    return LegalLlmConfig(
      enabled: enabled ?? this.enabled,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
    );
  }
}

/// API anahtarı güvenli depoda.
class LegalLlmConfigStorage {
  LegalLlmConfigStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _enabledKey = 'legal_llm_enabled';
  static const _apiKeyKey = 'legal_llm_api_key';
  static const _baseUrlKey = 'legal_llm_base_url';
  static const _modelKey = 'legal_llm_model';

  static Future<LegalLlmConfig> load() async {
    final enabled = (await _storage.read(key: _enabledKey)) == '1';
    final apiKey = await _storage.read(key: _apiKeyKey) ?? '';
    final baseUrl =
        await _storage.read(key: _baseUrlKey) ?? LegalLlmConfig.kDefaultLlmBaseUrl;
    final model =
        await _storage.read(key: _modelKey) ?? LegalLlmConfig.kDefaultLlmModel;
    return LegalLlmConfig(
      enabled: enabled,
      apiKey: apiKey,
      baseUrl: baseUrl,
      model: model,
    );
  }

  static Future<void> save(LegalLlmConfig config) async {
    await _storage.write(
      key: _enabledKey,
      value: config.enabled ? '1' : '0',
    );
    final key = config.apiKey.trim();
    if (key.isEmpty) {
      await _storage.delete(key: _apiKeyKey);
    } else {
      await _storage.write(key: _apiKeyKey, value: key);
    }
    await _storage.write(key: _baseUrlKey, value: config.baseUrl.trim());
    await _storage.write(key: _modelKey, value: config.model.trim());
  }
}
