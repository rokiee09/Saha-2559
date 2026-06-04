import '../decision_support/legal_knowledge_index.dart';
import '../decision_support/legal_query_analyzer.dart';
import '../decision_support/legal_search_service.dart' as ds;
import 'assistant_legal_index.dart';
import 'assistant_query_classifier.dart';

export '../decision_support/legal_search_service.dart'
    show LegalSearchHit, kLegalStrongMatchMinScore, kLegalWeakMatchMinScore;

/// Geriye dönük sarmalayıcı — yeni motor [ds.LegalSearchService].
class AssistantLegalSearchService {
  AssistantLegalSearchService({
    required List<LegalIndexRecord> index,
  }) : _inner = ds.LegalSearchService(
          index: index.map(LegalKnowledgeRecord.fromIndexRecord).toList(),
        ),
        _analyzer = LegalQueryAnalyzer();

  final ds.LegalSearchService _inner;
  final LegalQueryAnalyzer _analyzer;

  LegalQueryClassification classify(String query) =>
      _analyzer.analyze(query).classification;

  List<LegalSearchHit> search(String rawQuery, {int maxResults = 5}) {
    final analysis = _analyzer.analyze(rawQuery);
    return _inner.search(analysis, maxResults: maxResults);
  }

  bool hasStrongMatch(List<LegalSearchHit> hits) => _inner.hasStrongMatch(hits);
}
