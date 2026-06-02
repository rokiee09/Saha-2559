import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mevzuat/mevzuat_provider.dart';
import 'asistan_domain.dart';

/// Polis çalışma asistanı: offline senaryo + mevzuat yönlendirme.
/// Genel amaçlı sohbet değildir; hukuki tavsiye vermez.

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

String asistanNormalize(String input) {
  return input
      .replaceAll('İ', 'i')
      .replaceAll('I', 'ı')
      .toLowerCase();
}

String asistanFold(String input) {
  final lower = asistanNormalize(input);
  const map = {
    'ç': 'c',
    'ğ': 'g',
    'ı': 'i',
    'ö': 'o',
    'ş': 's',
    'ü': 'u',
    'â': 'a',
    'î': 'i',
    'û': 'u',
  };
  final sb = StringBuffer();
  for (final ch in lower.split('')) {
    sb.write(map[ch] ?? ch);
  }
  return sb.toString();
}

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

/// Senaryo tabanlı çalışma asistanı kaydı.
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

  /// Eski concepts.json uyumluluğu.
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

/// Eski test ve API uyumluluğu.
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

/// Eski provider adı.
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
      }
      if (s > bestScore) {
        bestScore = s;
        best = c;
      }
    }
  }
  return best;
}

AsistanScenario? asistanMatchConcept(
  String rawQuery,
  List<AsistanConcept> concepts,
) =>
    asistanMatchScenario(rawQuery, concepts);

/// Sorgu uzmanlık alanı içinde mi?
bool asistanQueryInScope(String raw, List<AsistanScenario> scenarios) {
  final trimmed = raw.trim();
  if (trimmed.length < 2) return false;
  if (asistanMatchScenario(trimmed, scenarios) != null) return true;

  final q = asistanFold(trimmed);
  for (final d in asistanAllDomains) {
    for (final k in d.keywords) {
      final nk = asistanFold(k);
      if (nk.length >= 2 && q.contains(nk)) return true;
    }
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

/// Eski cevap tipi.
typedef AsistanAnswer = AsistanStructuredAnswer;

final asistanScopeProvider = Provider.autoDispose<bool>((ref) {
  final raw = ref.watch(asistanQueryProvider).trim();
  if (raw.isEmpty) return true;
  final scenarios = ref.watch(asistanScenariosProvider).valueOrNull;
  if (scenarios == null) return true;
  return asistanQueryInScope(raw, scenarios);
});

final asistanAnswerProvider =
    FutureProvider.autoDispose<AsistanStructuredAnswer?>((ref) async {
  final raw = ref.watch(asistanQueryProvider).trim();
  if (raw.isEmpty) return null;
  if (!ref.watch(asistanScopeProvider)) return null;

  final scenarios = await ref.watch(asistanScenariosProvider.future);
  final scenario = asistanMatchScenario(raw, scenarios);
  if (scenario == null) return null;

  final index = await ref.watch(asistanIndexProvider.future);
  final entryIds = <String>{for (final i in index) i.entry.id};
  final sectionIds = <String>{for (final i in index) i.section.id};

  final resolved = <AsistanRef>[];
  for (final r in scenario.refs) {
    if (!entryIds.contains(r.entryId)) continue;
    if (r.sectionId != null && !sectionIds.contains(r.sectionId)) {
      resolved.add(AsistanRef(entryId: r.entryId, label: r.label));
    } else {
      resolved.add(r);
    }
  }
  return AsistanStructuredAnswer(scenario: scenario, resolvedRefs: resolved);
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
    final doc = await ref.watch(mevzuatDocumentContentProvider(entry.id).future);
    for (final s in doc.sections) {
      if (s.text.trim().isEmpty && s.title.trim().isEmpty) continue;
      out.add(AsistanIndexItem(entry: entry, section: s));
    }
  }
  return out;
});

final asistanQueryProvider = StateProvider<String>((ref) => '');

/// Seçili uzmanlık alanı (null = tümü).
final asistanSelectedDomainProvider =
    StateProvider<AsistanDomain?>((ref) => null);

/// Giriş ekranında gösterilen örnek senaryolar.
List<AsistanScenario> asistanFeaturedScenarios(List<AsistanScenario> all) {
  final seen = <AsistanDomain>{};
  final out = <AsistanScenario>[];
  for (final s in all) {
    if (seen.add(s.domain)) out.add(s);
    if (out.length >= 8) break;
  }
  return out;
}

/// Alan filtresine göre senaryolar.
List<AsistanScenario> asistanScenariosForDomain(
  List<AsistanScenario> all,
  AsistanDomain? domain,
) {
  if (domain == null) return all;
  return all.where((s) => s.domain == domain).toList();
}

final asistanResultsProvider =
    FutureProvider.autoDispose<List<AsistanHit>>((ref) async {
  final raw = ref.watch(asistanQueryProvider).trim();
  if (raw.isEmpty) return const [];
  if (!ref.watch(asistanScopeProvider)) return const [];

  final scenarios = await ref.watch(asistanScenariosProvider.future);
  final structured = asistanMatchScenario(raw, scenarios);
  // Senaryo eşleşince madde aramasını gizle — mevzuatı kullandırmaya odaklan.
  if (structured != null) return const [];

  final normalized = asistanNormalize(raw);
  final phrase = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  final isPhrase = phrase.contains(' ');

  final tokens = normalized
      .split(RegExp(r'[^0-9a-zçğıöşü]+'))
      .where((t) => t.length >= 2)
      .toList();
  if (tokens.isEmpty) return const [];

  final concept = structured;
  final expandTokens = <String>{
    if (concept != null)
      for (final e in concept.expand)
        if (asistanFold(e).trim().length >= 2) asistanFold(e).trim(),
  };
  final refSectionIds = <String>{
    if (concept != null)
      for (final r in concept.refs)
        if (r.sectionId != null) r.sectionId!,
  };

  final index = await ref.watch(asistanIndexProvider.future);
  final hits = <AsistanHit>[];

  for (final item in index) {
    final title = asistanNormalize(
      '${item.section.title} ${item.section.article}',
    );
    final body = asistanNormalize(item.section.text);
    final ref0 = asistanNormalize(
      '${item.entry.displayTitle} ${item.entry.catalogTag}',
    );

    var score = 0.0;
    for (final t in tokens) {
      if (title.contains(t)) score += 6;
      if (ref0.contains(t)) score += 4;
      final occurrences = t.allMatches(body).length;
      if (occurrences > 0) score += occurrences > 3 ? 3.0 : occurrences.toDouble();
    }

    if (isPhrase) {
      if (title.contains(phrase)) score += 40;
      if (ref0.contains(phrase)) score += 25;
      if (body.contains(phrase)) score += 25;
    }

    final matchedAll = tokens.every(
      (t) => title.contains(t) || body.contains(t) || ref0.contains(t),
    );
    if (matchedAll && tokens.length > 1) score += 8;

    if (expandTokens.isNotEmpty) {
      final foldedTitle = asistanFold(title);
      final foldedBody = asistanFold(body);
      for (final e in expandTokens) {
        if (foldedTitle.contains(e)) score += 3;
        if (foldedBody.contains(e)) score += 1.5;
      }
    }

    if (refSectionIds.contains(item.section.id)) {
      score += 200;
    }

    if (score > 0) {
      hits.add(
        AsistanHit(entry: item.entry, section: item.section, score: score),
      );
    }
  }

  hits.sort((a, b) => b.score.compareTo(a.score));
  return hits.length > 5 ? hits.sublist(0, 5) : hits;
});
