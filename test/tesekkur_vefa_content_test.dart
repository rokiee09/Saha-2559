import 'package:flutter_test/flutter_test.dart';
import 'package:coderipple/src/features/kultur/tesekkur_vefa_content.dart';

void main() {
  test('TesekkurVefaContent.parse başlık ve paragraflar', () {
    const raw = '''
# Teşekkür ve Vefa

## Alt başlık

Birinci paragraf.

İkinci paragraf.

---
Dipnot
''';
    final c = TesekkurVefaContent.parse(raw);
    expect(c.title, 'Teşekkür ve Vefa');
    expect(c.subtitle, 'Alt başlık');
    expect(c.paragraphs.length, 2);
    expect(c.footer, 'Dipnot');
  });
}
