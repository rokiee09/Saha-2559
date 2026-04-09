import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saha_2559/src/app.dart';

void main() {
  testWidgets('Uygulama açılış smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PolisMevzuatApp()),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
