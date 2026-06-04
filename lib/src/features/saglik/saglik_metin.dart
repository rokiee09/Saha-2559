/// Uygulama içi sağlık metinleri (PDF'den aktarılmış).
enum SaglikMetinId {
  emniyetSaglikSartlari,
  saglikUygulamalari,
}

extension SaglikMetinIdX on SaglikMetinId {
  String get assetPath => switch (this) {
        SaglikMetinId.emniyetSaglikSartlari =>
          'assets/saglik/emniyet_saglik_sartlari.json',
        SaglikMetinId.saglikUygulamalari =>
          'assets/saglik/saglik_uygulamalari_rehberi.json',
      };

  String get listTitle => switch (this) {
        SaglikMetinId.emniyetSaglikSartlari =>
          'Emniyet Sağlık Şartları Yönetmeliği',
        SaglikMetinId.saglikUygulamalari =>
          'Sağlık Uygulamaları Rehberi',
      };

  String get listSubtitle => switch (this) {
        SaglikMetinId.emniyetSaglikSartlari =>
          'Sağlık kurulu raporu, form ve branş sınıflandırması (ekler)',
        SaglikMetinId.saglikUygulamalari =>
          'Rapor, istirahat, heyet ve hakem sevk uygulamaları',
      };
}

class SaglikMetinBolum {
  const SaglikMetinBolum({
    required this.id,
    required this.article,
    required this.title,
    required this.text,
  });

  final String id;
  final String article;
  final String title;
  final String text;

  factory SaglikMetinBolum.fromJson(Map<String, dynamic> json) {
    return SaglikMetinBolum(
      id: json['id'] as String? ?? '',
      article: json['article'] as String? ?? '',
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}

class SaglikMetinBelge {
  const SaglikMetinBelge({
    required this.law,
    required this.displayTitle,
    required this.subtitle,
    required this.source,
    required this.sections,
    this.disclaimer,
  });

  final String law;
  final String displayTitle;
  final String subtitle;
  final String source;
  final List<SaglikMetinBolum> sections;
  final String? disclaimer;

  factory SaglikMetinBelge.fromJson(Map<String, dynamic> json) {
    final raw = json['articles'];
    final sections = raw is List
        ? raw
            .whereType<Map<String, dynamic>>()
            .map(SaglikMetinBolum.fromJson)
            .toList()
        : <SaglikMetinBolum>[];
    return SaglikMetinBelge(
      law: json['law'] as String? ?? '',
      displayTitle: json['displayTitle'] as String? ?? json['law'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      source: json['source'] as String? ?? '',
      disclaimer: json['disclaimer'] as String?,
      sections: sections,
    );
  }
}
