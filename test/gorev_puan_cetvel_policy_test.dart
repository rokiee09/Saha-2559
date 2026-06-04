import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/araclar/gorev_puanlari/gorev_puan_cetvel_policy.dart';

void main() {
  group('gorevPuanCetvelYili', () {
    test('tamamen 2025 öncesi', () {
      expect(
        gorevPuanCetvelYili(
          DateTime(2024, 6, 1),
          DateTime(2025, 12, 31),
        ),
        2025,
      );
    });

    test('tamamen 2026 sonrası', () {
      expect(
        gorevPuanCetvelYili(
          DateTime(2026, 3, 1),
          DateTime(2026, 8, 1),
        ),
        2026,
      );
    });

    test('kesit geçen dönem başlangıca göre 2025', () {
      expect(
        gorevPuanCetvelYili(
          DateTime(2025, 10, 1),
          DateTime(2026, 6, 1),
        ),
        2025,
      );
    });
  });

  group('gorevPuanCetvelYiliSarkIle', () {
    test('şark sonrası 2026 görevi 2026 cetveli', () {
      expect(
        gorevPuanCetvelYiliSarkIle(
          baslangic: DateTime(2026, 2, 1),
          bitis: DateTime(2026, 5, 1),
          sarkBaslangic: DateTime(2025, 8, 1),
        ),
        2026,
      );
    });
  });
}
