import '../../../common/text/tr_text.dart';
import 'assistant_legal_index.dart';
import 'assistant_query_classifier.dart';
import 'assistant_synonym_dictionary.dart';

/// Puan eşikleri — güçlü eşleşme için minimum skor.
const kLegalStrongMatchMinScore = 55.0;
const kLegalWeakMatchMinScore = 28.0;

class LegalSearchHit {
  const LegalSearchHit({
    required this.record,
    required this.score,
    required this.matchedFields,
  });

  final LegalIndexRecord record;
  final double score;
  final List<String> matchedFields;
}

class AssistantLegalSearchService {
  AssistantLegalSearchService({
    required List<LegalIndexRecord> index,
    AssistantSynonymDictionary? synonyms,
    AssistantQueryClassifier? classifier,
  })  : _index = index,
        _synonyms = synonyms ?? const AssistantSynonymDictionary(),
        _classifier = classifier ?? AssistantQueryClassifier();

  final List<LegalIndexRecord> _index;
  final AssistantSynonymDictionary _synonyms;
  final AssistantQueryClassifier _classifier;

  LegalQueryClassification classify(String query) =>
      _classifier.classify(query);

  List<LegalSearchHit> search(String rawQuery, {int maxResults = 5}) {
    final classification = _classifier.classify(rawQuery);
    if (!classification.isInLegalScope) return const [];

    final folded = classification.foldedQuery;
    if (folded.length < 2) return const [];

    final synonymTerms = _synonyms
        .synonymTermsFor(folded)
        .map(trFold)
        .toSet();
    final queryTerms = {
      ...classification.expandedTerms.map(trFold),
      folded,
    };

    final hits = <LegalSearchHit>[];
    for (final record in _index) {
      final score = _scoreRecord(
        record: record,
        foldedQuery: folded,
        queryTerms: queryTerms,
        synonymTerms: synonymTerms,
        category: classification.primary,
      );
      if (score >= kLegalWeakMatchMinScore) {
        hits.add(LegalSearchHit(
          record: record,
          score: score,
          matchedFields: const [],
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
    required LegalIndexRecord record,
    required String foldedQuery,
    required Set<String> queryTerms,
    required Set<String> synonymTerms,
    required LegalQueryCategory category,
  }) {
    var score = 0.0;
    final titleF = trFold(record.title);
    final sourceF = trFold(record.sourceName);
    final articleF = trFold(record.articleNo);

    if (titleF.isNotEmpty &&
        (foldedQuery.contains(titleF) || _anyTermContains(queryTerms, titleF))) {
      score += 60;
    }

    for (final kw in record.keywords) {
      final kf = trFold(kw);
      if (kf.length < 3) continue;
      if (foldedQuery.contains(kf) || _anyTermContains(queryTerms, kf)) {
        score += 40;
        break;
      }
    }

    for (final tag in record.tags) {
      final tf = trFold(tag);
      if (tf.length < 3) continue;
      if (foldedQuery.contains(tf) || _categoryTagMatch(category, tf)) {
        score += 35;
        break;
      }
    }

    final fullF = trFold(record.fullText);
    if (fullF.length > 20 &&
        (foldedQuery.length >= 4 && fullF.contains(foldedQuery))) {
      score += 20;
    } else {
      for (final t in queryTerms) {
        if (t.length >= 4 && fullF.contains(t)) {
          score += 20;
          break;
        }
      }
    }

    for (final syn in record.synonyms) {
      final sf = trFold(syn);
      if (sf.length < 3) continue;
      if (synonymTerms.contains(sf) ||
          foldedQuery.contains(sf) ||
          _anyTermContains(queryTerms, sf)) {
        score += 25;
        break;
      }
    }

    for (final st in synonymTerms) {
      if (st.length >= 4 &&
          (titleF.contains(st) || fullF.contains(st) || sourceF.contains(st))) {
        score += 25;
        break;
      }
    }

    if (sourceF.isNotEmpty &&
        (foldedQuery.contains(sourceF) ||
            _anyTermContains(queryTerms, sourceF) ||
            (articleF.isNotEmpty && foldedQuery.contains(articleF)))) {
      score += 30;
    }

    if (record.isPriority) score += 18;
    if (record.isAppGuide) score += 16;

    if (_categoryTagMatch(category, trFold(record.tags.join(' ')))) {
      score += 12;
    }

    return score;
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
      LegalQueryCategory.pvsk: ['pvsk', '2559', 'kimlik', 'arama'],
      LegalQueryCategory.cmk: ['cmk', '5271'],
      LegalQueryCategory.tck: ['tck', '5237'],
      LegalQueryCategory.idariParaCezalari: [
        'idari_para_ceza',
        'kabahat',
      ],
      LegalQueryCategory.personelHaklari: ['personel', 'basari', 'dmk'],
    };
    final keys = map[category] ?? const <String>[];
    return keys.any((k) => tagBlob.contains(k));
  }
}
