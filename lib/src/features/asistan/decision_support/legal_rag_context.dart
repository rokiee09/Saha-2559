import 'legal_knowledge_index.dart';
import 'legal_query_analyzer.dart';
import 'legal_search_service.dart';

/// Modele verilen tek kaynak parçası.
class LegalSourceChunk {
  const LegalSourceChunk({
    required this.refId,
    required this.citation,
    required this.excerpt,
    required this.riskLevel,
  });

  final String refId;
  final String citation;
  final String excerpt;
  final LegalRiskLevel riskLevel;
}

/// RAG bağlamı — yalnızca yerel arama sonuçları.
class LegalRagContext {
  const LegalRagContext({
    required this.query,
    required this.analysis,
    required this.sources,
    required this.detectedTopics,
    required this.unresolvedSlotLabels,
  });

  final String query;
  final LegalQueryAnalysis analysis;
  final List<LegalSourceChunk> sources;
  final List<String> detectedTopics;
  final List<String> unresolvedSlotLabels;

  static const maxSources = 8;
  static const maxExcerptChars = 1400;

  factory LegalRagContext.fromSearch({
    required String query,
    required LegalQueryAnalysis analysis,
    required List<LegalSearchHit> hits,
  }) {
    final sources = <LegalSourceChunk>[];
    for (final hit in hits.take(maxSources)) {
      final r = hit.record;
      final text = '${r.summary}\n${r.fullText}'.trim();
      final excerpt = text.length > maxExcerptChars
          ? '${text.substring(0, maxExcerptChars).trimRight()}…'
          : text;
      sources.add(
        LegalSourceChunk(
          refId: r.id,
          citation: '${r.sourceName} · ${r.articleNo} — ${r.title}',
          excerpt: excerpt,
          riskLevel: r.riskLevel,
        ),
      );
    }

    return LegalRagContext(
      query: query,
      analysis: analysis,
      sources: sources,
      detectedTopics: analysis.topics,
      unresolvedSlotLabels:
          analysis.unresolvedSlots.map((s) => s.label).toList(),
    );
  }

  String toPromptBlock() {
    final buf = StringBuffer();
    buf.writeln('KULLANICI SORUSU:');
    buf.writeln(query);
    buf.writeln();
    buf.writeln('OLAY ANALİZİ (sistem çıkarımı):');
    buf.writeln('- Konular: ${detectedTopics.join(', ')}');
    if (analysis.processTypes.isNotEmpty) {
      buf.writeln('- İşlem türü: ${analysis.processTypes.join(', ')}');
    }
    if (analysis.jurisdictionIssues.isNotEmpty) {
      buf.writeln(
        '- Yetki: ${analysis.jurisdictionIssues.join(', ')}',
      );
    }
    if (unresolvedSlotLabels.isNotEmpty) {
      buf.writeln(
        '- Netleştirilmesi gereken: ${unresolvedSlotLabels.join(', ')}',
      );
    }
    buf.writeln();
    buf.writeln('YEREL KAYNAKLAR (yalnızca bunlara dayanın):');
    for (var i = 0; i < sources.length; i++) {
      final s = sources[i];
      buf.writeln('[KAYNAK-${i + 1}] id=${s.refId}');
      buf.writeln('Atıf: ${s.citation}');
      buf.writeln('Risk: ${s.riskLevel.label}');
      buf.writeln(s.excerpt);
      buf.writeln('---');
    }
    return buf.toString();
  }
}
