import 'package:flutter/material.dart';

import '../theme/police_colors.dart';

/// Metinde `query` ile eşleşen dilimleri arka planla vurgular (case-insensitive).
List<TextSpan> highlightTextSpans({
  required String text,
  required String query,
  required TextStyle baseStyle,
  Color backgroundColor = PoliceColors.searchHighlightBg,
  double highlightOpacity = 0.42,
}) {
  final q = query.trim();
  if (q.isEmpty || text.isEmpty) {
    return [TextSpan(text: text, style: baseStyle)];
  }
  final hl = baseStyle.merge(
    TextStyle(
      backgroundColor: backgroundColor.withValues(alpha: highlightOpacity),
    ),
  );
  try {
    final pattern = RegExp(RegExp.escape(q), caseSensitive: false);
    final spans = <TextSpan>[];
    var start = 0;
    for (final m in pattern.allMatches(text)) {
      if (m.start > start) {
        spans.add(TextSpan(text: text.substring(start, m.start), style: baseStyle));
      }
      spans.add(
        TextSpan(
          text: text.substring(m.start, m.end),
          style: hl,
        ),
      );
      start = m.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }
    return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
  } catch (_) {
    return [TextSpan(text: text, style: baseStyle)];
  }
}
