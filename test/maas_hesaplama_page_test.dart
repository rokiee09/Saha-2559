import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/haklar/maas_hesaplama_page.dart';

void main() {
  testWidgets('MaasHesaplamaPage açılır ve sonuç alanı görünür', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MaasHesaplamaPage()),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('Tahmini maaş bilgisi'), findsOneWidget);
    expect(find.textContaining('Veri yüklenemedi'), findsNothing);
  });
}
