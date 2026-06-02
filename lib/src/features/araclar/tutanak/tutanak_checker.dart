/// Tutanak taslağı için kural tabanlı eksiklik kontrolü (çevrimdışı).
class TutanakCheckIssue {
  const TutanakCheckIssue({
    required this.severity,
    required this.message,
  });

  final TutanakCheckSeverity severity;
  final String message;
}

enum TutanakCheckSeverity { warning, info }

class TutanakChecker {
  const TutanakChecker._();

  static const _placeholders = {'.....', 'gg.aa.yyyy', 'ss:dd'};

  static List<TutanakCheckIssue> check({
    required Map<String, String> values,
    required String draft,
  }) {
    final issues = <TutanakCheckIssue>[];

    void requireField(String key, String label) {
      final v = values[key]?.trim() ?? '';
      if (v.isEmpty || _placeholders.contains(v)) {
        issues.add(TutanakCheckIssue(
          severity: TutanakCheckSeverity.warning,
          message: '$label eksik veya doldurulmamış.',
        ));
      }
    }

    requireField('tarih', 'Tarih');
    requireField('saat', 'Saat');
    requireField('yer', 'Yer bilgisi');

    final bodyKeys = values.entries
        .where((e) => !{'tarih', 'saat', 'yer'}.contains(e.key))
        .where((e) => e.value.trim().isNotEmpty)
        .length;
    if (bodyKeys == 0) {
      issues.add(const TutanakCheckIssue(
        severity: TutanakCheckSeverity.warning,
        message: 'Tutanak gövdesi boş; olay/kişi/eşya bilgilerini ekleyin.',
      ));
    }

    if (!RegExp(r'\d{1,2}[./]\d{1,2}[./]\d{2,4}').hasMatch(draft) &&
        (values['tarih']?.trim().isEmpty ?? true)) {
      issues.add(const TutanakCheckIssue(
        severity: TutanakCheckSeverity.info,
        message: 'Metinde okunaklı bir tarih formatı görünmüyor.',
      ));
    }

    if (!RegExp(r'\d{1,2}:\d{2}').hasMatch(draft) &&
        (values['saat']?.trim().isEmpty ?? true)) {
      issues.add(const TutanakCheckIssue(
        severity: TutanakCheckSeverity.info,
        message: 'Metinde saat bilgisi görünmüyor.',
      ));
    }

    if (draft.contains('.....')) {
      issues.add(const TutanakCheckIssue(
        severity: TutanakCheckSeverity.warning,
        message: 'Taslakta doldurulmamış alan işaretleri (.....) var.',
      ));
    }

    return issues;
  }
}
