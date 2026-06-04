import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/common/theme/saha_module_theme.dart';
import 'package:coderipple/src/common/widgets/module_section_header.dart';
import 'package:coderipple/src/common/widgets/saha_empty_state.dart';
import 'package:coderipple/src/common/widgets/saha_module_card.dart';

void main() {
  testWidgets('SahaModuleCard.feature gösterir ve dokunulur', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SahaModuleCard.feature(
            area: SahaModuleArea.mevzuat,
            title: 'Mevzuat',
            subtitle: 'Kanun ve yönetmelik',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Mevzuat'), findsOneWidget);
    await tester.tap(find.text('Mevzuat'));
    expect(tapped, isTrue);
  });

  testWidgets('ModuleSectionHeader alan vurgusu çizer', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ModuleSectionHeader(
            'Hızlı geçiş',
            area: SahaModuleArea.asistan,
          ),
        ),
      ),
    );

    expect(find.text('Hızlı geçiş'), findsOneWidget);
    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('SahaEmptyState özel ikon ve aksiyon', (tester) async {
    var action = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SahaEmptyState(
            theme: SahaModuleTheme.forArea(SahaModuleArea.asistan),
            icon: Icons.search_off_rounded,
            title: 'Sonuç yok',
            message: 'Deneyin',
            actionLabel: 'Geri',
            onAction: () => action = true,
          ),
        ),
      ),
    );

    expect(find.text('Sonuç yok'), findsOneWidget);
    await tester.tap(find.text('Geri'));
    expect(action, isTrue);
  });
}
