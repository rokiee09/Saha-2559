import '../../../common/text/tr_text.dart';
import '../legal/assistant_query_classifier.dart';
import 'legal_knowledge_index.dart';
import 'legal_query_analyzer.dart';
import 'legal_synonym_dictionary.dart';

const kLegalStrongMatchMinScore = 55.0;
const kLegalWeakMatchMinScore = 28.0;

class LegalSearchHit {
  const LegalSearchHit({
    required this.record,
    required this.score,
    required this.matchedFields,
  });

  final LegalKnowledgeRecord record;
  final double score;
  final List<String> matchedFields;
}

class LegalSearchService {
  LegalSearchService({
    required List<LegalKnowledgeRecord> index,
    LegalSynonymDictionary? synonyms,
  })  : _index = index,
        _synonyms = synonyms ?? const LegalSynonymDictionary();

  final List<LegalKnowledgeRecord> _index;
  final LegalSynonymDictionary _synonyms;

  List<LegalSearchHit> search(
    LegalQueryAnalysis analysis, {
    int maxResults = 8,
  }) {
    if (!analysis.isInScope) return const [];

    final folded = analysis.foldedQuery;
    if (folded.length < 2) return const [];

    final synonymTerms = _synonyms
        .synonymTermsFor(folded)
        .map(trFold)
        .toSet();
    final queryTerms = {
      ...analysis.expandedTerms.map(trFold),
      folded,
    };

    final hits = <LegalSearchHit>[];
    for (final record in _index) {
      final matched = <String>[];
      final score = _scoreRecord(
        record: record,
        analysis: analysis,
        foldedQuery: folded,
        queryTerms: queryTerms,
        synonymTerms: synonymTerms,
        matchedFields: matched,
      );
      if (score >= kLegalWeakMatchMinScore) {
        hits.add(LegalSearchHit(
          record: record,
          score: score,
          matchedFields: matched,
        ));
      }
    }

    hits.sort((a, b) => b.score.compareTo(a.score));
    return hits.take(maxResults).toList();
  }

  bool hasStrongMatch(List<LegalSearchHit> hits) {
    if (hits.isEmpty) return false;
    return hits.first.score >= kLegalStrongMatchMinScore;
  }

  double _scoreRecord({
    required LegalKnowledgeRecord record,
    required LegalQueryAnalysis analysis,
    required String foldedQuery,
    required Set<String> queryTerms,
    required Set<String> synonymTerms,
    required List<String> matchedFields,
  }) {
    var score = 0.0;
    final titleF = trFold(record.title);
    final sourceF = trFold(record.sourceName);

    for (final ex in record.exampleQuestions) {
      final ef = trFold(ex);
      if (ef.length >= 8 &&
          (foldedQuery.length >= 8 &&
              _overlapRatio(foldedQuery, ef) > 0.35)) {
        score += 70;
        matchedFields.add('exampleQuestion');
        break;
      }
    }

    for (final topic in record.topics) {
      if (analysis.topics.contains(topic)) {
        score += 45;
        matchedFields.add('topic:$topic');
        break;
      }
    }

    for (final sub in record.subtopics) {
      if (analysis.subtopics.contains(sub)) {
        score += 30;
        matchedFields.add('subtopic:$sub');
        break;
      }
    }

    if (titleF.isNotEmpty &&
        (foldedQuery.contains(titleF) ||
            _anyTermContains(queryTerms, titleF))) {
      score += 55;
      matchedFields.add('title');
    }

    for (final kw in record.keywords) {
      final kf = trFold(kw);
      if (kf.length < 3) continue;
      if (foldedQuery.contains(kf) || _anyTermContains(queryTerms, kf)) {
        score += 42;
        matchedFields.add('keyword');
        break;
      }
    }

    for (final tag in record.tags) {
      final tf = trFold(tag);
      if (analysis.topics.contains(tf) ||
          analysis.foldedQuery.contains(tf) ||
          _categoryTagMatch(analysis.classification.primary, tf)) {
        score += 35;
        matchedFields.add('tag');
        break;
      }
    }

    final fullF = trFold(record.fullText);
    if (fullF.length > 20 && foldedQuery.length >= 5 && fullF.contains(foldedQuery)) {
      score += 22;
      matchedFields.add('fullText');
    }

    for (final syn in record.synonyms) {
      final sf = trFold(syn);
      if (synonymTerms.contains(sf) || foldedQuery.contains(sf)) {
        score += 25;
        matchedFields.add('synonym');
        break;
      }
    }

    if (record.isPriority) score += 20;
    if (record.id.startsWith('scenario_')) score += 15;

    return score;
  }

  double _overlapRatio(String a, String b) {
    final ta = a.split(RegExp(r'\s+')).where((t) => t.length >= 4).toSet();
    final tb = b.split(RegExp(r'\s+')).where((t) => t.length >= 4).toSet();
    if (ta.isEmpty || tb.isEmpty) return 0;
    final inter = ta.intersection(tb).length;
    return inter / ta.length.clamp(1, 999);
  }

  bool _anyTermContains(Set<String> terms, String target) {
    for (final t in terms) {
      if (t.length >= 3 && (target.contains(t) || t.contains(target))) {
        return true;
      }
    }
    return false;
  }

  bool _categoryTagMatch(LegalQueryCategory category, String tagBlob) {
    final map = {
      LegalQueryCategory.izinler: ['izin', 'dmk'],
      LegalQueryCategory.saglikRefakatRapor: ['saglik', 'refakat', 'rapor'],
      LegalQueryCategory.disiplin: ['disiplin', '7068'],
      LegalQueryCategory.icraMaasKesinti: ['icra', 'maas'],
      LegalQueryCategory.atisEgitimGorevIzni: ['atis', 'egitim'],
      LegalQueryCategory.pvsk: ['pvsk', 'kimlik', 'arama'],
      LegalQueryCategory.cmk: ['cmk', 'yediemin', 'emanet', 'infaz'],
      LegalQueryCategory.idariParaCezalari: ['idari_para', 'kabahat'],
      LegalQueryCategory.personelHaklari: ['basari', 'personel'],
      LegalQueryCategory.tutanakEvrak: ['tutanak'],
    };
    final keys = map[category] ?? const <String>[];
    return keys.any((k) => tagBlob.contains(k));
  }
}
