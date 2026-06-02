import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/martyrs/martyrs_loader.dart';

void main() {
  test('parseMartyrsFromJson assigns stable ids and dates', () {
    const json = '''
[
  {"fullName":"Polis Memuru Ali","cityName":"Ankara","dateOfMartyrdom":"2020-07-16"},
  {"fullName":"Komiser Ayşe","cityName":"Belirtilmedi","dateOfMartyrdom":"2019-01-01"}
]
''';
    final list = parseMartyrsFromJson(json);
    expect(list.length, 2);
    expect(list[0].id, 1);
    expect(list[1].id, 2);
    expect(list[0].fullName, contains('Ali'));
    expect(list[0].dateOfMartyrdom, isNotNull);
    expect(list[0].dateOfMartyrdom!.year, 2020);
  });
}
