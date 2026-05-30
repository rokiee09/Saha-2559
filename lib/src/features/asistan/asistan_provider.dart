import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mevzuat/mevzuat_provider.dart';

/// Asistan, internet kullanmadan yalnızca uygulama paketindeki mevzuat
/// JSON'ları üzerinde anahtar kelime araması yapar. Üstüne bir kavram/eş-anlam
/// katmanı (concepts.json) doğal dildeki soruları ilgili maddelere bağlar.
/// Hukuki görüş veya resmî kaynak değildir; sonuç ilgili maddeye yönlendirir.

/// Aranabilir tek bir madde kaydı (kanun/yönetmelik + bölüm).
class AsistanIndexItem {
  final MevzuatEntry entry;
  final MevzuatSection section;

  const AsistanIndexItem({required this.entry, required this.section});
}

/// Bir arama sonucu (skor ile).
class AsistanHit {
  final MevzuatEntry entry;
  final MevzuatSection section;
  final double score;

  const AsistanHit({
    required this.entry,
    required this.section,
    required this.score,
  });

  /// "Kaynak" satırı: ör. "2559 PVSK · Madde 16".
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

  /// Gövdeden kısa bir özet parçası (kart için).
  String snippet([int max = 220]) {
    final t = section.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (t.length <= max) return t;
    return '${t.substring(0, max).trimRight()}…';
  }
}

/// Türkçe duyarlı küçük harfe çevirme (I/İ özel durumları dahil).
String asistanNormalize(String input) {
  return input
      .replaceAll('İ', 'i')
      .replaceAll('I', 'ı')
      .toLowerCase();
}

/// Aksan/Türkçe karakterleri sadeleştirir (ç→c, ğ→g, ı→i, ö→o, ş→s, ü→u).
/// Kavram eşleştirmede "güç" ↔ "guc" gibi yazımların tutması için kullanılır.
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

/// Bir kavramın yönlendirdiği kaynak (kanun/yönetmelik + opsiyonel madde).
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

/// Doğal dildeki soruyu ilgili maddelere bağlayan offline kavram.
class AsistanConcept {
  final String id;
  final String label;
  final List<String> triggers;
  final List<String> expand;
  final String answer;
  final List<AsistanRef> refs;

  const AsistanConcept({
    required this.id,
    required this.label,
    required this.triggers,
    required this.expand,
    required this.answer,
    required this.refs,
  });

  factory AsistanConcept.fromJson(Map<String, dynamic> json) {
    List<String> strList(dynamic v) =>
        (v as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [];
    return AsistanConcept(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      triggers: strList(json['triggers']),
      expand: strList(json['expand']),
      answer: json['answer'] as String? ?? '',
      refs: (json['refs'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(AsistanRef.fromJson)
              .toList() ??
          const [],
    );
  }
}

const _conceptsPath = 'assets/asistan/concepts.json';

/// concepts.json'u paketten yükler (offline kavram haritası).
final asistanConceptsProvider =
    FutureProvider<List<AsistanConcept>>((ref) async {
  try {
    final str = await rootBundle.loadString(_conceptsPath);
    final json = jsonDecode(str) as Map<String, dynamic>;
    final list = (json['concepts'] as List<dynamic>?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(AsistanConcept.fromJson)
        .where((c) => c.triggers.isNotEmpty)
        .toList();
  } catch (_) {
    return const <AsistanConcept>[];
  }
});

/// Sorguya en uygun kavramı seçer (en uzun eşleşen tetikleyici kazanır).
AsistanConcept? asistanMatchConcept(
  String rawQuery,
  List<AsistanConcept> concepts,
) {
  final q = asistanFold(rawQuery).replaceAll(RegExp(r'\s+'), ' ').trim();
  if (q.isEmpty) return null;
  AsistanConcept? best;
  var bestScore = 0;
  for (final c in concepts) {
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

/// Asistan cevap kartı verisi: kavram + paket içinde gerçekten bulunan kaynaklar.
class AsistanAnswer {
  final AsistanConcept concept;
  final List<AsistanRef> resolvedRefs;

  const AsistanAnswer({required this.concept, required this.resolvedRefs});
}

/// Sorgu için kavram cevabını üretir; refs paket içinde doğrulanır.
final asistanAnswerProvider =
    FutureProvider.autoDispose<AsistanAnswer?>((ref) async {
  final raw = ref.watch(asistanQueryProvider).trim();
  if (raw.isEmpty) return null;
  final concepts = await ref.watch(asistanConceptsProvider.future);
  final concept = asistanMatchConcept(raw, concepts);
  if (concept == null) return null;

  final index = await ref.watch(asistanIndexProvider.future);
  final entryIds = <String>{for (final i in index) i.entry.id};
  final sectionIds = <String>{for (final i in index) i.section.id};

  final resolved = <AsistanRef>[];
  for (final r in concept.refs) {
    if (!entryIds.contains(r.entryId)) continue;
    if (r.sectionId != null && !sectionIds.contains(r.sectionId)) {
      // Madde paket içinde yoksa belgenin tümüne yönlendir.
      resolved.add(AsistanRef(entryId: r.entryId, label: r.label));
    } else {
      resolved.add(r);
    }
  }
  return AsistanAnswer(concept: concept, resolvedRefs: resolved);
});

/// Tüm mevzuat maddelerini tek seferde yükleyip bellekte tutan dizin.
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

/// Asistan arama metni.
final asistanQueryProvider = StateProvider<String>((ref) => '');

/// Hızlı konu butonları (etiket, arama metni).
const List<({String label, String query})> asistanQuickTopics = [
  (label: 'Yakalama', query: 'yakalama gözaltı'),
  (label: 'Zor kullanma', query: 'zor kullanma'),
  (label: 'Arama', query: 'arama el koyma'),
  (label: 'İfade alma', query: 'ifade alma'),
  (label: 'Disiplin', query: 'disiplin ceza'),
  (label: 'Durdurma', query: 'durdurma kimlik sorma'),
  (label: 'Refakat izni', query: 'refakat izni'),
  (label: 'Yıllık izin', query: 'yıllık izin'),
];

final asistanResultsProvider =
    FutureProvider.autoDispose<List<AsistanHit>>((ref) async {
  final raw = ref.watch(asistanQueryProvider).trim();
  if (raw.isEmpty) return const [];

  final normalized = asistanNormalize(raw);
  final phrase = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  final isPhrase = phrase.contains(' ');

  final tokens = normalized
      .split(RegExp(r'[^0-9a-zçğıöşü]+'))
      .where((t) => t.length >= 2)
      .toList();
  if (tokens.isEmpty) return const [];

  // Kavram eşleşirse eş-anlam genişletme ve ilgili madde önceliklendirmesi.
  final concepts = await ref.watch(asistanConceptsProvider.future);
  final concept = asistanMatchConcept(raw, concepts);
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
      // Uzun metinlerin tek kelime tekrarıyla öne çıkmasını engelle.
      final occurrences = t.allMatches(body).length;
      if (occurrences > 0) score += occurrences > 3 ? 3.0 : occurrences.toDouble();
    }

    // Tam ifade eşleşmesi (ör. "zor kullanma") en güçlü sinyal: ilgili
    // maddeyi (PVSK 16 vb.) gevşek kelime eşleşmelerinin önüne taşır.
    if (isPhrase) {
      if (title.contains(phrase)) score += 40;
      if (ref0.contains(phrase)) score += 25;
      if (body.contains(phrase)) score += 25;
    }

    // Tüm kelimeleri içeren maddeleri öne çıkar.
    final matchedAll = tokens.every(
      (t) => title.contains(t) || body.contains(t) || ref0.contains(t),
    );
    if (matchedAll && tokens.length > 1) score += 8;

    // Kavram eş-anlam genişletmesi: aksan sadeleştirilmiş eşleşme.
    if (expandTokens.isNotEmpty) {
      final foldedTitle = asistanFold(title);
      final foldedBody = asistanFold(body);
      for (final e in expandTokens) {
        if (foldedTitle.contains(e)) score += 3;
        if (foldedBody.contains(e)) score += 1.5;
      }
    }

    // Kavramın işaret ettiği maddeyi her zaman en üste taşı.
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
  return hits.length > 30 ? hits.sublist(0, 30) : hits;
});
