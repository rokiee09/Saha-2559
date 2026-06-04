import '../assistant_sensitive_query.dart';
import '../../../common/text/tr_text.dart';
import '../../araclar/idari_para_ceza/idari_para_ceza_data.dart';
import '../../araclar/tutanak/tutanak_templates.dart';
import '../../saglik/saglik_rehberi_data.dart';
import '../asistan_domain.dart';
import '../asistan_provider.dart';
import 'assistant_help_corpus.dart';
import 'assistant_models.dart';
import 'query_normalizer.dart';

/// Birleşik asistan arama servisi — tüm yerel kaynakları tarar.
class AssistantSearchService {
  const AssistantSearchService({
    required this.scenarios,
    required this.mevzuatIndex,
    required this.cezaKayitlar,
  });

  final List<AsistanScenario> scenarios;
  final List<AsistanIndexItem> mevzuatIndex;
  final List<IdariParaCezaKayit> cezaKayitlar;

  static bool isSensitiveQuery(String raw) =>
      AssistantSensitiveQuery.matches(raw);

  AssistantAnswer search(String rawQuery) {
    final trimmed = rawQuery.trim();
    if (trimmed.length < 2) return AssistantAnswer.empty(trimmed);

    final nq = QueryNormalizer.normalize(trimmed);
    if (nq.tokens.isEmpty && nq.folded.length < 2) {
      return AssistantAnswer.empty(trimmed);
    }

    final hits = <SearchResult>[
      ..._searchScenarios(nq),
      ..._searchHelp(nq),
      ..._searchSaglik(nq),
      ..._searchTutanak(nq),
      ..._searchIdariParaCeza(nq),
      ..._searchMevzuat(nq),
    ];

    hits.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    final top = hits.length > 3 ? hits.sublist(0, 3) : hits;

    if (top.isEmpty || top.first.relevanceScore < kAssistantMinRelevanceScore) {
      if (isSensitiveQuery(trimmed)) {
        return AssistantAnswer.sensitive(trimmed);
      }
      return AssistantAnswer.empty(trimmed);
    }

    if (isSensitiveQuery(trimmed) && top.first.relevanceScore < 55) {
      return AssistantAnswer.sensitive(trimmed);
    }

    final primary = top.first;
    return AssistantAnswer(
      query: trimmed,
      primaryCategory: primary.category,
      primary: primary,
      topResults: top,
    );
  }

  AssistantCategory? classify(String rawQuery) {
    final answer = search(rawQuery);
    return answer.primaryCategory;
  }

  List<SearchResult> _searchScenarios(NormalizedQuery nq) {
    final out = <SearchResult>[];
    for (final s in scenarios) {
      var score = 0.0;

      final titleF = trFold(s.title);
      final sitF = trFold(s.situation);

      if (nq.folded.contains(titleF) && titleF.length >= 4) score += 50;
      for (final t in nq.expandedTokens) {
        if (titleF.contains(t)) score += 50;
        if (sitF.contains(t)) score += 10;
      }

      for (final trigger in s.triggers) {
        final tf = trFold(trigger);
        if (tf.isEmpty) continue;
        if (nq.folded == tf) {
          score += 80;
        } else if (nq.folded.contains(tf)) {
          score += 50;
        } else if (tf.contains(nq.folded) && nq.folded.length >= 4) {
          score += 35;
        } else {
          for (final tok in nq.expandedTokens) {
            if (tf.contains(tok)) score += 25;
            if (SynonymDictionary.sharesSynonymGroup(tf, tok)) score += 15;
          }
        }
      }

      for (final e in s.expand) {
        final ef = trFold(e);
        if (nq.expandedTokens.contains(ef)) score += 15;
      }

      for (final law in nq.lawRefs) {
        if (trFold(s.source).contains(law) ||
            trFold(s.domain.id).contains(law)) {
          score += 40;
        }
      }

      if (score >= kAssistantMinRelevanceScore) {
        out.add(SearchResult(
          id: 'scenario_${s.id}',
          category: _domainToCategory(s.domain),
          title: s.title,
          shortAnswer: s.summary,
          source: s.source,
          appContext: s.appContext,
          relevanceScore: score,
          isMevzuatBacked: true,
          nav: s.refs.isNotEmpty
              ? SearchResultNav(
                  mevzuatEntryId: s.refs.first.entryId,
                  mevzuatSectionId: s.refs.first.sectionId,
                )
              : null,
        ));
      }
    }
    return out;
  }

  List<SearchResult> _searchMevzuat(NormalizedQuery nq) {
    final out = <SearchResult>[];
    for (final item in mevzuatIndex) {
      final titleRaw =
          '${item.section.title} ${item.section.article} ${item.entry.displayTitle}';
      final titleF = trFold(titleRaw);
      final bodyF = trFold(item.section.text);
      final entryF = trFold('${item.entry.code ?? ''} ${item.entry.name}');

      var score = 0.0;

      for (final t in nq.expandedTokens) {
        if (titleF.contains(t)) score += 50;
        if (entryF.contains(t)) score += 40;
        if (bodyF.contains(t)) score += 10;
        if (SynonymDictionary.sharesSynonymGroup(titleRaw, t)) score += 15;
      }

      if (nq.folded.length >= 6 && bodyF.contains(nq.folded)) score += 25;

      for (final art in nq.articleRefs) {
        final artF = trFold(item.section.article);
        if (artF.contains(art)) score += 40;
      }

      for (final law in nq.lawRefs) {
        if (entryF.contains(law)) score += 40;
      }

      if (score >= kAssistantMinRelevanceScore) {
        final code = item.entry.code?.trim();
        final source = (code != null && code.isNotEmpty)
            ? '$code ${item.entry.catalogTag} · ${item.section.article}'
            : '${item.entry.name} · ${item.section.article}';
        out.add(SearchResult(
          id: 'mevzuat_${item.section.id}',
          category: AssistantCategory.mevzuat,
          title: item.section.title.trim().isNotEmpty
              ? item.section.title
              : item.section.article,
          shortAnswer:
              '${asistanLegalPrefix}, ${item.section.title.isNotEmpty ? item.section.title : item.section.article} hükmü ilgili olabilir. Tam metni inceleyin.',
          source: source,
          appContext:
              'Mevzuat sekmesinden ilgili maddeyi açıp görev kaydınızla karşılaştırın.',
          relevanceScore: score,
          isMevzuatBacked: true,
          nav: SearchResultNav(
            mevzuatEntryId: item.entry.id,
            mevzuatSectionId: item.section.id,
          ),
        ));
      }
    }
    return out;
  }

  List<SearchResult> _searchIdariParaCeza(NormalizedQuery nq) {
    final out = <SearchResult>[];
    for (final k in cezaKayitlar) {
      var score = 0.0;
      final kabF = trFold(k.kabahatAdi);
      final metaF = trFold(k.aramaMetni);

      if (nq.folded.contains(kabF) && kabF.length >= 4) score += 50;
      for (final t in nq.expandedTokens) {
        if (kabF.contains(t)) score += 50;
        if (metaF.contains(t)) score += 25;
        if (SynonymDictionary.sharesSynonymGroup('ceza', t)) score += 15;
      }

      if (score >= kAssistantMinRelevanceScore) {
        out.add(SearchResult(
          id: 'ceza_${k.id}',
          category: AssistantCategory.idariParaCeza,
          title: k.kabahatAdi,
          shortAnswer:
              '${k.kabahatAdi} için 2026 idari para ceza tutarı ${k.cezaMetni}. '
              '${k.kanun} ${k.madde}.',
          source: '${k.kanun} (${k.kanunSayisi}) · ${k.madde}',
          appContext:
              'Araçlar → İdari Para Cezaları bölümünden detay, itiraz mercii '
              've belge bilgisine ulaşabilirsiniz.',
          relevanceScore: score,
          nav: SearchResultNav(
            moduleRoute: 'idari_para_ceza',
            moduleQuery: k.kabahatAdi,
          ),
        ));
      }
    }
    return out;
  }

  List<SearchResult> _searchTutanak(NormalizedQuery nq) {
    final out = <SearchResult>[];
    for (final t in TutanakTemplate.all) {
      var score = 0.0;
      final titleF = trFold(t.title);
      final descF = trFold(t.description);

      for (final tok in nq.expandedTokens) {
        if (titleF.contains(tok)) score += 50;
        if (descF.contains(tok)) score += 25;
        if (SynonymDictionary.sharesSynonymGroup('tutanak', tok)) score += 15;
      }

      if (score >= kAssistantMinRelevanceScore) {
        out.add(SearchResult(
          id: 'tutanak_${t.id}',
          category: AssistantCategory.tutanak,
          title: t.title,
          shortAnswer:
              '$titleF şablonu Araçlar → Tutanak Merkezi\'nde taslak olarak sunulur.',
          source: 'SAHA 2559 · Tutanak şablonu',
          appContext:
              'Şablonu seçip alanları doldurun; PDF veya metin olarak paylaşın. '
              'Resmî form yerine geçmez.',
          relevanceScore: score,
          nav: SearchResultNav(
            moduleRoute: 'tutanak',
            tutanakTemplateId: t.id,
          ),
        ));
      }
    }
    return out;
  }

  List<SearchResult> _searchSaglik(NormalizedQuery nq) {
    final out = <SearchResult>[];

    for (final s in kSaglikSenaryolari) {
      var score = 0.0;
      final titleF = trFold(s.baslik);
      for (final k in s.anahtarlar) {
        final kf = trFold(k);
        if (nq.folded.contains(kf)) score += 50;
        for (final t in nq.expandedTokens) {
          if (kf.contains(t) || t.contains(kf)) score += 25;
          if (SynonymDictionary.sharesSynonymGroup(k, t)) score += 15;
        }
      }
      if (titleF.contains(nq.folded) && nq.folded.length >= 5) score += 40;

      if (score >= kAssistantMinRelevanceScore) {
        out.add(SearchResult(
          id: 'saglik_${s.id}',
          category: AssistantCategory.saglik,
          title: s.baslik,
          shortAnswer: s.ozet,
          source: s.mevzuatNotlari.isNotEmpty
              ? s.mevzuatNotlari.first
              : 'Sağlık ve Sosyal Haklar rehberi',
          appContext: s.uygulamada,
          relevanceScore: score,
          isMevzuatBacked: true,
          nav: SearchResultNav(
            moduleRoute: 'saglik',
            saglikKonuId: s.ilgiliKonu?.id,
          ),
        ));
      }
    }

    for (final konu in SaglikRehberKonu.values) {
      final icerik = rehberIcerik(konu);
      var score = 0.0;
      final titleF = trFold(konu.title);
      final ozetF = trFold(icerik.ozet);
      for (final t in nq.expandedTokens) {
        if (titleF.contains(t)) score += 50;
        if (ozetF.contains(t)) score += 10;
        if (SynonymDictionary.sharesSynonymGroup('saglik', t)) score += 15;
      }
      if (score >= kAssistantMinRelevanceScore) {
        out.add(SearchResult(
          id: 'saglik_konu_${konu.id}',
          category: AssistantCategory.saglik,
          title: konu.title,
          shortAnswer: icerik.ozet,
          source: 'Sağlık ve Sosyal Haklar · ${konu.title}',
          appContext: icerik.uygulamada,
          relevanceScore: score,
          isMevzuatBacked: true,
          nav: SearchResultNav(
            moduleRoute: 'saglik',
            saglikKonuId: konu.id,
          ),
        ));
      }
    }
    return out;
  }

  List<SearchResult> _searchHelp(NormalizedQuery nq) {
    final out = <SearchResult>[];
    for (final h in kAssistantHelpEntries) {
      var score = 0.0;
      final titleF = trFold(h.title);
      if (nq.folded.contains(titleF)) score += 50;
      for (final kw in h.keywords) {
        final kf = trFold(kw);
        if (nq.folded.contains(kf)) score += 50;
        for (final t in nq.expandedTokens) {
          if (kf.contains(t)) score += 25;
        }
      }
      if (score >= kAssistantMinRelevanceScore) {
        out.add(SearchResult(
          id: 'help_${h.id}',
          category: h.category,
          title: h.title,
          shortAnswer: h.shortAnswer,
          source: h.source,
          appContext: h.appContext,
          relevanceScore: score,
          nav: h.nav,
        ));
      }
    }
    return out;
  }

  AssistantCategory _domainToCategory(AsistanDomain domain) {
    return switch (domain) {
      AsistanDomain.izin ||
      AsistanDomain.tayin ||
      AsistanDomain.lojman ||
      AsistanDomain.maas ||
      AsistanDomain.disiplin =>
        AssistantCategory.kariyer,
      _ => AssistantCategory.mevzuat,
    };
  }
}

/// Örnek / sık kullanılan giriş soruları.
const kAsistanOrnekSorular = [
  'Kimlik vermeyen şahsa ne yapılır?',
  'Dilencilik cezası ne kadar?',
  'Araçta arama için karar gerekir mi?',
  'Başarı belgesi kaç tane olursa üstün başarı olur?',
  'Atış izni kullandım nasıl kaydederim?',
  'Sağlık raporu nereden takip edilir?',
  'Tutanak örneği lazım.',
  'PVSK zor kullanma maddesi nedir?',
];

/// Geriye dönük uyumluluk.
String asistanFold(String input) => trFold(input);

String asistanNormalize(String input) => trLower(input);
