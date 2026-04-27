import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart' as path_drawing;
import 'package:xml/xml.dart' as xml;

class TurkeySvgPathEntry {
  TurkeySvgPathEntry({required this.id, required this.path});
  final String id;
  final Path path;
}

class TurkeySvgPathParser {
  TurkeySvgPathParser({
    required this.entries,
    required this.viewBoxW,
    required this.viewBoxH,
  });

  final List<TurkeySvgPathEntry> entries;
  final double viewBoxW;
  final double viewBoxH;

  static TurkeySvgPathParser? fromSvgString(String raw) {
    final paths = <TurkeySvgPathEntry>[];
    var vbW = 1000.0;
    var vbH = 500.0;

    late final xml.XmlDocument doc;
    try {
      doc = xml.XmlDocument.parse(raw);
    } catch (_) {
      return null;
    }

    final s = doc.rootElement.name.local == 'svg' ? doc.rootElement : null;
    if (s != null) {
      final vb = s.getAttribute('viewBox') ?? s.getAttribute('viewbox');
      if (vb != null) {
        final p = vb.trim().split(RegExp(r'[\s,]+'));
        if (p.length >= 4) {
          final w = double.tryParse(p[2]);
          final h = double.tryParse(p[3]);
          if (w != null && w > 0) vbW = w;
          if (h != null && h > 0) vbH = h;
        }
      } else {
        final w = double.tryParse(
          s.getAttribute('width')?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '',
        );
        final h = double.tryParse(
          s.getAttribute('height')?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '',
        );
        if (w != null && w > 0) vbW = w;
        if (h != null && h > 0) vbH = h;
      }
    }

    void addPathFromElement(xml.XmlElement el, String? inheritId) {
      final name = el.name.local;
      String? d = el.getAttribute('d');
      if (d == null && name == 'polygon') {
        final pts = el.getAttribute('points');
        if (pts != null) d = 'M${pts}Z';
      } else if (d == null && name == 'polyline') {
        final pts = el.getAttribute('points');
        if (pts != null) d = 'M$pts';
      }
      if (d == null || d.isEmpty) return;
      var id = el.getAttribute('id')?.trim() ?? inheritId;
      if (id == null || id.isEmpty) return;
      try {
        final p = path_drawing.parseSvgPathData(d);
        paths.add(TurkeySvgPathEntry(id: id, path: p));
      } catch (_) {}
    }

    void visit(xml.XmlNode node, String? gId) {
      if (node is! xml.XmlElement) return;
      final name = node.name.local;
      if (name == 'defs' || name == 'clipPath' || name == 'mask' || name == 'metadata') {
        return;
      }
      var nextG = gId;
      if (name == 'g' || name == 'svg' || name == 'switch') {
        final ig = node.getAttribute('id')?.trim();
        if (ig != null && ig.isNotEmpty) nextG = ig;
        for (final c in node.children) {
          visit(c, nextG);
        }
        return;
      }
      if (name == 'path' || name == 'polygon' || name == 'polyline') {
        addPathFromElement(node, gId);
      }
    }

    for (final c in doc.rootElement.children) {
      visit(c, null);
    }
    if (paths.isEmpty) {
      for (final e in doc.rootElement.findAllElements('path')) {
        addPathFromElement(e, e.getAttribute('id')?.trim());
      }
    }
    if (paths.isEmpty) return null;
    return TurkeySvgPathParser(
      entries: paths,
      viewBoxW: vbW,
      viewBoxH: vbH,
    );
  }

  double _scaleFor(Size size) {
    if (size.isEmpty) return 1;
    return (size.width / viewBoxW < size.height / viewBoxH)
        ? size.width / viewBoxW
        : size.height / viewBoxH;
  }

  Offset _viewBoxPoint(Offset local, Size size) {
    if (size.isEmpty) return Offset.zero;
    final s = _scaleFor(size);
    final ox = (size.width - viewBoxW * s) / 2;
    final oy = (size.height - viewBoxH * s) / 2;
    return Offset((local.dx - ox) / s, (local.dy - oy) / s);
  }

  String? hitId(Offset local, Size size) {
    final p = _viewBoxPoint(local, size);
    for (var i = entries.length - 1; i >= 0; i--) {
      if (entries[i].path.contains(p)) {
        return entries[i].id;
      }
    }
    return null;
  }

  void paintHighlight(
    Canvas canvas,
    Size size, {
    required String? highlightId,
    required Color color,
  }) {
    if (highlightId == null) return;
    for (final e in entries) {
      if (e.id == highlightId) {
        final s = _scaleFor(size);
        final ox = (size.width - viewBoxW * s) / 2;
        final oy = (size.height - viewBoxH * s) / 2;
        canvas
          ..save()
          ..translate(ox, oy)
          ..scale(s)
          ..drawPath(
            e.path,
            Paint()..color = color,
          )
          ..restore();
        return;
      }
    }
  }
}
