import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// Tutanak taslağını PDF olarak üretir; font yüklenemezse metin paylaşır.
class TutanakPdf {
  const TutanakPdf._();

  static Future<Uint8List?> tryBuildBytes({
    required String title,
    required String body,
  }) async {
    try {
      final font = await PdfGoogleFonts.notoSansRegular();
      final bold = await PdfGoogleFonts.notoSansBold();
      final doc = pw.Document();
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(48),
          build: (context) => [
            pw.Text(
              title.toUpperCase(),
              style: pw.TextStyle(font: bold, fontSize: 14),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              body,
              style: pw.TextStyle(font: font, fontSize: 11, lineSpacing: 4),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              '— SAHA 2559 taslak çıktısı; resmî tutanak değildir.',
              style: pw.TextStyle(
                font: font,
                fontSize: 8,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
      );
      return doc.save();
    } catch (_) {
      return null;
    }
  }

  static Future<void> export({
    required String title,
    required String body,
  }) async {
    final bytes = await tryBuildBytes(title: title, body: body);
    if (bytes != null) {
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${_safeName(title)}.pdf',
      );
      return;
    }
    await Share.share(body, subject: title);
  }

  static String _safeName(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9ğüşıöçĞÜŞİÖÇ]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
