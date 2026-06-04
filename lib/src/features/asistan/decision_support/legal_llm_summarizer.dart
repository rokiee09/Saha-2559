import 'dart:convert';

import 'package:http/http.dart' as http;

import 'legal_llm_config.dart';
import 'legal_rag_context.dart';

/// LLM özet çıktısı (JSON parse).
class LegalLlmSummaryResult {
  const LegalLlmSummaryResult({
    required this.shortAnswer,
    required this.evaluation,
    required this.missingInfoNote,
    required this.certainty,
  });

  final String shortAnswer;
  final String evaluation;
  final String missingInfoNote;
  final String certainty;
}

/// OpenAI uyumlu chat API — kaynak dışına çıkmama talimatı ile.
class LegalLlmSummarizer {
  LegalLlmSummarizer({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _systemPrompt = '''
Sen SAHA 2559 mevzuat muhakeme asistanısın. Hukuki tavsiye veya kesin hüküm vermezsin.
Yalnızca kullanıcıya verilen YEREL KAYNAK metinlerine dayanarak Türkçe ön değerlendirme yazarsın.

Kurallar:
- Kaynaklarda olmayan madde, kanun veya uygulama uydurma.
- Operasyonel taktik, gizli yöntem, baskın, sorgu tekniği önerme.
- "Kesinlikle şöyledir" yerine "ilgili mevzuata göre ön değerlendirme" dili kullan.
- Eksik bilgi varsa missingInfoNote alanında netleştirici sorular sor.
- Yanıtı YALNIZCA aşağıdaki JSON olarak ver (başka metin yok):
{
  "shortAnswer": "2-4 cümle kısa cevap",
  "evaluation": "Kaynaklara atıflı gerekçe ve sahadaki dikkat (madde adlarıyla)",
  "missingInfoNote": "Eksik bilgi veya dikkat hususu",
  "certainty": "low|medium|high"
}
''';

  Future<LegalLlmSummaryResult?> summarize({
    required LegalRagContext context,
    required LegalLlmConfig config,
  }) async {
    if (!config.isReady || context.sources.isEmpty) return null;

    final body = jsonEncode({
      'model': config.model,
      'temperature': 0.2,
      'response_format': {'type': 'json_object'},
      'messages': [
        {'role': 'system', 'content': _systemPrompt},
        {
          'role': 'user',
          'content': context.toPromptBlock(),
        },
      ],
    });

    final response = await _client
        .post(
          Uri.parse(config.chatCompletionsUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${config.apiKey.trim()}',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LegalLlmException(
        'API ${response.statusCode}: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw const LegalLlmException('Boş model yanıtı');
    }
    final content = (choices.first as Map<String, dynamic>)['message']
        ?['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw const LegalLlmException('İçerik yok');
    }

    return _parseSummaryJson(content);
  }

  LegalLlmSummaryResult? _parseSummaryJson(String raw) {
    var text = raw.trim();
    if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      text = text.replaceFirst(RegExp(r'\s*```$'), '');
    }
    final map = jsonDecode(text) as Map<String, dynamic>;
    final short = (map['shortAnswer'] as String? ?? '').trim();
    if (short.isEmpty) return null;
    return LegalLlmSummaryResult(
      shortAnswer: short,
      evaluation: (map['evaluation'] as String? ?? '').trim(),
      missingInfoNote: (map['missingInfoNote'] as String? ?? '').trim(),
      certainty: (map['certainty'] as String? ?? 'medium').trim().toLowerCase(),
    );
  }

  void close() => _client.close();
}

class LegalLlmException implements Exception {
  const LegalLlmException(this.message);
  final String message;

  @override
  String toString() => message;
}
