// Mevzuat verisi bütünlük doğrulayıcısı.
//
// Çalıştırma (repo kökünden):
//   dart run tool/validate_mevzuat.dart
//
// Kurallar:
//   HATA  -> bozuk JSON, eksik/boş id-name-path, var olmayan dosya,
//            'articles' yok/boş, bir maddede 'article' veya 'text' boş.
//   UYARI -> kaynak (sourceUrl/source) yok, madde 'title'/'id' eksik,
//            katalogda referans verilmeyen yetim JSON dosyası.
//
// En az bir HATA varsa süreç 1 koduyla çıkar (CI'ı kırar).

import 'dart:convert';
import 'dart:io';

const String _baseDir = 'assets/mevzuat';
const String _catalogPath = '$_baseDir/catalog.json';

final List<String> _errors = [];
final List<String> _warnings = [];

void _err(String m) => _errors.add(m);
void _warn(String m) => _warnings.add(m);

void main() {
  final catalogFile = File(_catalogPath);
  if (!catalogFile.existsSync()) {
    stderr.writeln('HATA: $_catalogPath bulunamadı (repo kökünden çalıştırın).');
    exit(1);
  }

  Map<String, dynamic> catalog;
  try {
    catalog = jsonDecode(catalogFile.readAsStringSync()) as Map<String, dynamic>;
  } catch (e) {
    stderr.writeln('HATA: catalog.json çözümlenemedi: $e');
    exit(1);
  }

  final referencedPaths = <String>{};
  var entryCount = 0;
  var articleCount = 0;

  for (final group in const ['kanunlar', 'yonetmelikler']) {
    final list = catalog[group];
    if (list == null) {
      _warn('catalog.json içinde "$group" anahtarı yok.');
      continue;
    }
    if (list is! List) {
      _err('catalog.json "$group" bir liste değil.');
      continue;
    }
    for (final raw in list) {
      entryCount++;
      if (raw is! Map<String, dynamic>) {
        _err('[$group] geçersiz giriş (nesne değil): $raw');
        continue;
      }
      final id = (raw['id'] as String?)?.trim() ?? '';
      final name = (raw['name'] as String?)?.trim() ?? '';
      final path = (raw['path'] as String?)?.trim() ?? '';
      final label = id.isNotEmpty ? id : (name.isNotEmpty ? name : '<isimsiz>');

      if (id.isEmpty) _err('[$group] "id" boş: $label');
      if (name.isEmpty) _err('[$group/$label] "name" boş.');
      if (path.isEmpty) {
        _err('[$group/$label] "path" boş.');
        continue;
      }

      final hasEntrySource =
          ((raw['sourceUrl'] as String?)?.trim().isNotEmpty ?? false);

      referencedPaths.add(path);
      final file = File('$_baseDir/$path');
      if (!file.existsSync()) {
        _err('[$group/$label] dosya yok: $_baseDir/$path');
        continue;
      }

      articleCount += _validateArticleFile(file, label, hasEntrySource);
    }
  }

  _checkOrphans(referencedPaths);

  stdout.writeln('— Mevzuat doğrulama —');
  stdout.writeln('Giriş: $entryCount · Madde: $articleCount');
  for (final w in _warnings) {
    stdout.writeln('UYARI: $w');
  }
  for (final e in _errors) {
    stderr.writeln('HATA: $e');
  }
  stdout.writeln('Toplam: ${_errors.length} hata, ${_warnings.length} uyarı.');

  exit(_errors.isEmpty ? 0 : 1);
}

int _validateArticleFile(File file, String label, bool hasEntrySource) {
  Map<String, dynamic> doc;
  try {
    doc = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  } catch (e) {
    _err('[$label] JSON çözümlenemedi (${file.path}): $e');
    return 0;
  }

  final hasFileSource = ((doc['sourceUrl'] as String?)?.trim().isNotEmpty ?? false) ||
      ((doc['source'] as String?)?.trim().isNotEmpty ?? false);
  if (!hasEntrySource && !hasFileSource) {
    _warn('[$label] kaynak (sourceUrl/source) belirtilmemiş.');
  }

  final articles = doc['articles'];
  if (articles == null || articles is! List || articles.isEmpty) {
    _err('[$label] "articles" yok veya boş (${file.path}).');
    return 0;
  }

  var idx = 0;
  for (final a in articles) {
    idx++;
    if (a is! Map<String, dynamic>) {
      _err('[$label] madde #$idx nesne değil.');
      continue;
    }
    final article = (a['article'] as String?)?.trim() ?? '';
    final text = (a['text'] as String?)?.trim() ?? '';
    final id = (a['id'] as String?)?.trim() ?? '';

    if (article.isEmpty) _err('[$label] madde #$idx "article" boş.');
    if (text.isEmpty) _err('[$label] madde #$idx ($article) "text" boş.');
    if (id.isEmpty) _warn('[$label] madde #$idx ($article) "id" eksik.');
    if (!a.containsKey('title')) {
      _warn('[$label] madde #$idx ($article) "title" anahtarı yok.');
    }
  }

  return articles.length;
}

void _checkOrphans(Set<String> referenced) {
  for (final sub in const ['kanunlar', 'yonetmelikler']) {
    final dir = Directory('$_baseDir/$sub');
    if (!dir.existsSync()) continue;
    for (final f in dir.listSync().whereType<File>()) {
      if (!f.path.endsWith('.json')) continue;
      final rel = '$sub/${f.uri.pathSegments.last}';
      if (!referenced.contains(rel)) {
        _warn('Katalogda referans verilmeyen dosya: $_baseDir/$rel');
      }
    }
  }
}
