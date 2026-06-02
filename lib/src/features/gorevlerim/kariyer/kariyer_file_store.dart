import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Kariyer modülü belge ve görselleri — yalnızca cihazda.
Future<Directory> kariyerFilesDir(String sub) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}${Platform.pathSeparator}kariyer_$sub');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}

String _extOf(String path) {
  final dot = path.lastIndexOf('.');
  final slash = path.lastIndexOf(RegExp(r'[\\/]'));
  if (dot > slash && dot != -1) {
    final ext = path.substring(dot);
    if (ext.length <= 6) return ext;
  }
  return '';
}

Future<String> kariyerCopyFile({
  required String sub,
  required String sourcePath,
  required String prefix,
}) async {
  final dir = await kariyerFilesDir(sub);
  final ext = _extOf(sourcePath);
  final dest =
      '${dir.path}${Platform.pathSeparator}${prefix}_${DateTime.now().microsecondsSinceEpoch}$ext';
  await File(sourcePath).copy(dest);
  return dest;
}

Future<void> kariyerDeleteFile(String path) async {
  try {
    final f = File(path);
    if (await f.exists()) await f.delete();
  } catch (_) {}
}
