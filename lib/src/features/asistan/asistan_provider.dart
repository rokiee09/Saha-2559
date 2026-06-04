import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/text/tr_text.dart';
import '../mevzuat/mevzuat_provider.dart';
import '../araclar/idari_para_ceza/idari_para_ceza_data.dart';
import '../araclar/mutalaa/mutalaa_ozel_data.dart';
import 'legal/assistant_content_index.dart';
import 'asistan_domain.dart';
import 'assistant_sensitive_query.dart';
import 'decision_support/legal_decision_engine.dart';
import 'decision_support/legal_knowledge_index.dart';
import 'decision_support/legal_llm_config.dart';
import 'legal/assistant_answer_builder.dart';
import 'legal/assistant_legal_index.dart';
import 'legal/assistant_legal_search_service.dart';
import 'legal/assistant_query_classifier.dart';

/// Mevzuat kaynaklı soru-cevap asistanı.

class AsistanIndexItem {
  final MevzuatEntry entry;
  final MevzuatSection section;

  const AsistanIndexItem({required this.entry, required this.section});
}

class AsistanHit {
  final MevzuatEntry entry;
  final MevzuatSection section;
  final double score;

  const AsistanHit({
    required this.entry,
    required this.section,
    required this.score,
  });

  String get sourceLabel {
    final code = entry.code?.trim();
    final article = section.article.trim();
    final base = (code != null && code.isNotEmpty)
        ? '$code ${entry.catalogTag}'
        : entry.name;
    if (article.isEmpty) return base;
    final articleLabel =
        article.toLowerCase().contains('madde') ? article : 'Madde $article';
    return '$base · $articleLabel';
  }

  String snippet([int max = 220]) {
    final t = section.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (t.length <= max) return t;
    return '${t.substring(0, max).trimRight()}…';
  }
}

String asistanNormalize(String input) => trLower(input);

String asistanFold(String input) => trFold(input);

class AsistanRef {
  final String entryId;
  final String? sectionId;
  final String label;

  const AsistanRef({
    required this.entryId,
    this.sectionId,
    required this.label,
  });

  factory AsistanRef.fromJson(Map<String, dynamic> json) {
    return AsistanRef(
      entryId: json['entryId'] as String? ?? '',
      sectionId: json['sectionId'] as String?,
      label: json['label'] as String? ?? '',
    );
  }
}

class AsistanScenario {
  const AsistanScenario({
    required this.id,
    required this.domain,
    required this.title,
    required this.situation,
    required this.triggers,
    required this.expand,
    required this.summary,
    required this.appContext,
    required this.source,
    required this.refs,
  });

  final String id;
  final AsistanDomain domain;
  final String title;
  final String situation;
  final List<String> triggers;
  final List<String> expand;
  final String summary;
  final String appContext;
  final String source;
  final List<AsistanRef> refs;

  String get label => title;

  factory AsistanScenario.fromJson(Map<String, dynamic> json) {
    List<String> strList(dynamic v) =>
        (v as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [];

    final legacyAnswer = json['answer'] as String? ?? '';
    var summary = (json['summary'] as String? ?? '').trim();
    if (summary.isEmpty && legacyAnswer.isNotEmpty) {
      summary = legacyAnswer.length > 280
          ? '${legacyAnswer.substring(0, 277).trimRight()}…'
          : legacyAnswer;
    }
    if (!summary.startsWith(asistanLegalPrefix)) {
      summary = '$asistanLegalPrefix, $summary';
    }

    var appContext = (json['appContext'] as String? ?? '').trim();
    if (appContext.isEmpty) {
      appContext =
          'Saha uygulamasında Mevzuat bölümünden ilgili metni açıp görev kaydınızla karşılaştırın.';
    }

    var source = (json['source'] as String? ?? '').trim();
    if (source.isEmpty) {
      final refs = (json['refs'] as List<dynamic>?) ?? const [];
      if (refs.isNotEmpty) {
        final first = refs.first;
        if (first is Map<String, dynamic>) {
          source = first['label'] as String? ?? '';
        }
      }
    }

    return AsistanScenario(
      id: json['id'] as String? ?? '',
      domain: AsistanDomain.fromId(json['domain'] as String?) ??
          AsistanDomain.mevzuat,
      title: json['title'] as String? ?? json['label'] as String? ?? '',
      situation: json['situation'] as String? ?? '',
      triggers: strList(json['triggers']),
      expand: strList(json['expand']),
      summary: summary,
      appContext: appContext,
      source: source,
      refs: (json['refs'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(AsistanRef.fromJson)
              .toList() ??
          const [],
    );
  }
}

typedef AsistanConcept = AsistanScenario;

const _scenariosPath = 'assets/asistan/scenarios.json';
const _conceptsPath = 'assets/asistan/concepts.json';

Future<List<AsistanScenario>> _loadScenariosFromAsset(String path) async {
  final str = await rootBundle.loadString(path);
  final json = jsonDecode(str) as Map<String, dynamic>;
  final list = (json['scenarios'] as List<dynamic>?) ??
      (json['concepts'] as List<dynamic>?) ??
      const [];
  return list
      .whereType<Map<String, dynamic>>()
      .map(AsistanScenario.fromJson)
      .where((c) => c.triggers.isNotEmpty)
      .toList();
}

final asistanScenariosProvider =
    FutureProvider<List<AsistanScenario>>((ref) async {
  try {
    return await _loadScenariosFromAsset(_scenariosPath);
  } catch (_) {
    try {
      return await _loadScenariosFromAsset(_conceptsPath);
    } catch (_) {
      return const <AsistanScenario>[];
    }
  }
});

final asistanConceptsProvider = asistanScenariosProvider;

AsistanScenario? asistanMatchScenario(
  String rawQuery,
  List<AsistanScenario> scenarios,
) {
  final q = asistanFold(rawQuery).replaceAll(RegExp(r'\s+'), ' ').trim();
  if (q.isEmpty) return null;
  AsistanScenario? best;
  var bestScore = 0;
  for (final c in scenarios) {
    for (final t in c.triggers) {
      final nt = asistanFold(t).trim();
      if (nt.isEmpty) continue;
      var s = 0;
      if (q == nt) {
        s = 1000 + nt.length;
      } else if (q.contains(nt)) {
        s = 500 + nt.length;
      } else if (nt.contains(q) && q.length >= 4) {
        s = 200 + q.length;
      } else {
        for (final tok in q.split(' ')) {
          if (tok.length >= 3 && nt.contains(tok)) s += 80 + tok.length;
        }
      }
      if (s > bestScore) {
        bestScore = s;
        best = c;
      }
    }
  }
  return bestScore >= 200 ? best : null;
}

AsistanScenario? asistanMatchConcept(
  String rawQuery,
  List<AsistanConcept> concepts,
) =>
    asistanMatchScenario(rawQuery, concepts);

bool asistanQueryInScope(String raw, List<AsistanScenario> scenarios) {
  final trimmed = raw.trim();
  if (trimmed.length < 2) return false;

  if (AssistantQueryClassifier().classify(trimmed).isInLegalScope) {
    return true;
  }

  final q = trFold(trimmed);
  for (final d in asistanAllDomains) {
    for (final k in d.keywords) {
      if (q.contains(trFold(k))) return true;
    }
  }
  const extra = [
    'ceza',
    'tutanak',
    'saglik',
    'atis',
    'basari',
    'taltif',
    'rapor',
    'heyet',
  ];
  for (final k in extra) {
    if (q.contains(k)) return true;
  }
  return false;
}

class AsistanStructuredAnswer {
  final AsistanScenario scenario;
  final List<AsistanRef> resolvedRefs;

  const AsistanStructuredAnswer({
    required this.scenario,
    required this.resolvedRefs,
  });
}

typedef AsistanAnswer = AsistanStructuredAnswer;

final asistanScopeProvider = Provider.autoDispose<bool>((ref) {
  final raw = ref.watch(asistanQueryProvider).trim();
  if (raw.isEmpty) return true;
  if (raw.length >= 2) return true;
  return false;
});

final asistanIndexProvider =
    FutureProvider<List<AsistanIndexItem>>((ref) async {
  final catalog = await ref.watch(mevzuatCatalogProvider.future);
  final entries = <MevzuatEntry>[
    ...catalog.kanunlar,
    ...catalog.yonetmelikler,
  ];

  final out = <AsistanIndexItem>[];
  for (final entry in entries) {
    final doc =
        await ref.watch(mevzuatDocumentContentProvider(entry.id).future);
    for (final s in doc.sections) {
      if (s.text.trim().isEmpty && s.title.trim().isEmpty) continue;
      out.add(AsistanIndexItem(entry: entry, section: s));
    }
  }
  return out;
});

final legalKnowledgeIndexProvider =
    FutureProvider<List<LegalKnowledgeRecord>>((ref) async {
  final index = await ref.watch(asistanIndexProvider.future);
  final cezaSet = await ref.watch(idariParaCezaProvider.future);
  final mutalaaSet = await ref.watch(mutalaaOzelProvider.future);
  return buildLegalKnowledgeIndex(
    mevzuatItems: index.map((i) => (entry: i.entry, section: i.section)),
    cezaKayitlar: cezaSet.kayitlar,
    extraIndexRecords: legalIndexFromMutalaaOzel(mutalaaSet.kayitlar),
  );
});

/// Geriye dönük — düz mevzuat indeks kayıtları.
final assistantLegalIndexProvider =
    FutureProvider<List<LegalIndexRecord>>((ref) async {
  final knowledge = await ref.watch(legalKnowledgeIndexProvider.future);
  return knowledge.map((k) => k.toIndexRecord()).toList();
});

final legalLlmConfigProvider = FutureProvider<LegalLlmConfig>((ref) async {
  return LegalLlmConfigStorage.load();
});

final legalDecisionEngineProvider =
    FutureProvider<LegalDecisionEngine>((ref) async {
  final records = await ref.watch(legalKnowledgeIndexProvider.future);
  final llmConfig = await ref.watch(legalLlmConfigProvider.future);
  return LegalDecisionEngine(index: records, llmConfig: llmConfig);
});

final assistantLegalSearchServiceProvider =
    FutureProvider<AssistantLegalSearchService>((ref) async {
  final records = await ref.watch(assistantLegalIndexProvider.future);
  return AssistantLegalSearchService(index: records);
});

/// Kaynaklı mevzuat muhakeme — ana cevap kaynağı.
final legalAssistantAnswerProvider =
    FutureProvider.autoDispose<LegalDecisionAnswer?>((ref) async {
  final raw = ref.watch(asistanQueryProvider).trim();
  if (raw.isEmpty) return null;

  final engine = await ref.watch(legalDecisionEngineProvider.future);
  return await engine.answer(raw);
});

/// Geriye dönük alias.
final assistantSearchProvider = legalAssistantAnswerProvider;

/// Senaryo tabanlı cevap (yalnızca geriye dönük; ana akış mevzuat araması).
final asistanAnswerProvider =
    FutureProvider.autoDispose<AsistanStructuredAnswer?>((ref) async {
  return null;
});

final idariParaCezaAsistanProvider =
    Provider.autoDispose<IdariParaCezaKayit?>((ref) {
  final answer = ref.watch(legalAssistantAnswerProvider).valueOrNull;
  final record = answer?.primaryRecord;
  if (record == null ||
      record.sourceType != LegalSourceType.idariParaCeza) {
    return null;
  }
  final id = record.id.replaceFirst('ceza_', '');
  final set = ref.watch(idariParaCezaProvider).valueOrNull;
  if (set == null) return null;
  for (final k in set.kayitlar) {
    if (k.id == id) return k;
  }
  return set.enIyiEslesme(answer!.query);
});

final asistanQueryProvider = StateProvider<String>((ref) => '');

final asistanSelectedDomainProvider =
    StateProvider<AsistanDomain?>((ref) => null);

List<AsistanScenario> asistanFeaturedScenarios(List<AsistanScenario> all) {
  final seen = <AsistanDomain>{};
  final out = <AsistanScenario>[];
  for (final s in all) {
    if (seen.add(s.domain)) out.add(s);
    if (out.length >= 8) break;
  }
  return out;
}

List<AsistanScenario> asistanScenariosForDomain(
  List<AsistanScenario> all,
  AsistanDomain? domain,
) {
  if (domain == null) return all;
  return all.where((s) => s.domain == domain).toList();
}

final asistanResultsProvider =
    FutureProvider.autoDispose<List<AsistanHit>>((ref) async {
  final answer = await ref.watch(legalAssistantAnswerProvider.future);
  if (answer == null || answer.noStrongMatch) return const [];

  final index = await ref.watch(asistanIndexProvider.future);
  final hits = <AsistanHit>[];

  for (final h in answer.topHits) {
    final rec = h.record;
    if (rec.entryId == null || rec.sectionId == null) continue;
    for (final item in index) {
      if (item.entry.id == rec.entryId &&
          item.section.id == rec.sectionId) {
        hits.add(AsistanHit(
          entry: item.entry,
          section: item.section,
          score: h.score,
        ));
        break;
      }
    }
  }
  return hits;
});
