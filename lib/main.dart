import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/data/db/isar_service.dart';
import 'src/data/repositories/offline_import_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await IsarService.init();
    await OfflineImportService.ensureLawArticlesSeeded();
  }
  runApp(const ProviderScope(child: PolisMevzuatApp()));
}

