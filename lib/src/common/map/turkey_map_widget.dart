import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../phone/phone_dial_handler.dart';
import '../../data/models/city_contact.dart';
import 'city_contact_plate_match.dart';
import 'il_telefonlari.dart';
import 'turkey_svg_path_parser.dart';

/// (viewBox bilinmiyorken) yedek oran; [tr.svg] 1000×422 kullanır.
const double kDefaultMapCoordW = 1000;
const double kDefaultMapCoordH = 500;

/// Path yoksa (yedek) — id plaka; `TR34` / `34` aynı plaka eşlemesine gider.
const List<({String id, double l, double t, double w, double h})> kManualRegionFallback =
    <({String id, double l, double t, double w, double h})>[
  (id: 'TR34', l: 0.04, t: 0.16, w: 0.18, h: 0.32),
  (id: 'TR06', l: 0.26, t: 0.12, w: 0.16, h: 0.32),
  (id: 'TR35', l: 0.45, t: 0.24, w: 0.17, h: 0.40),
  (id: 'TR16', l: 0.12, t: 0.56, w: 0.18, h: 0.28),
  (id: 'TR07', l: 0.48, t: 0.08, w: 0.20, h: 0.28),
];

String? _manualHit(Offset p, Size size) {
  for (var i = kManualRegionFallback.length - 1; i >= 0; i--) {
    final z = kManualRegionFallback[i];
    final r = Rect.fromLTWH(
      z.l * size.width,
      z.t * size.height,
      z.w * size.width,
      z.h * size.height,
    );
    if (r.contains(p)) {
      return z.id;
    }
  }
  return null;
}

class _PathHighlightPainter extends CustomPainter {
  _PathHighlightPainter(this.parser, this.highlightId, this.color);

  final TurkeySvgPathParser parser;
  final String? highlightId;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    parser.paintHighlight(canvas, size, highlightId: highlightId, color: color);
  }

  @override
  bool shouldRepaint(covariant _PathHighlightPainter oldDelegate) {
    return oldDelegate.highlightId != highlightId || oldDelegate.color != color;
  }
}

class TurkeyMapWidget extends StatefulWidget {
  const TurkeyMapWidget({
    super.key,
    this.showSnackBarOnTap = true,
    this.vectorAssetPath = 'assets/images/tr.svg',
    this.rasterAssetPath = 'assets/images/Turkey_provinces_blank_gray.svg.png',
    this.contactsJsonPath = 'assets/json/city_contacts.json',
    this.useRasterBackground = false,
    this.cityContacts,
  });

  final bool showSnackBarOnTap;
  final String vectorAssetPath;
  final String rasterAssetPath;
  final String contactsJsonPath;
  final bool useRasterBackground;
  /// Isar’da yüklü il listesi; plaka eşleşmesi [findCityContactByPlateCode] ile.
  final List<CityContact>? cityContacts;

  @override
  State<TurkeyMapWidget> createState() => _TurkeyMapWidgetState();
}

class _TurkeyMapWidgetState extends State<TurkeyMapWidget> {
  String? _svgRaw;
  TurkeySvgPathParser? _parser;
  String? _highlightId;
  Timer? _hlTimer;
  String? _loadError;
  bool _loadDone = false;
  Map<String, String> _phonesByIlKey = {};
  Map<String, String> _phonesByPlate = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final jsonRaw = await rootBundle.loadString(widget.contactsJsonPath);
      final decoded = jsonDecode(jsonRaw);
      final byKey = <String, String>{};
      final byPlate = <String, String>{};
      if (decoded is List<dynamic>) {
        for (final e in decoded) {
          if (e is! Map<String, dynamic>) {
            continue;
          }
          final name = e['cityName'] as String?;
          final phone = e['phone'] as String?;
          final ilKey = ilKeyForGosterimAdi(name);
          if (ilKey != null && phone != null) {
            byKey[ilKey] = phoneDigitsForDial(phone);
          }
          final plate = e['plateCode'] as String?;
          if (plate != null && phone != null) {
            byPlate[plate] = phoneDigitsForDial(phone);
          }
        }
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _phonesByIlKey = byKey;
        _phonesByPlate = byPlate;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _phonesByIlKey = {};
          _phonesByPlate = {};
        });
      }
    }
    try {
      final s = await rootBundle.loadString(widget.vectorAssetPath);
      if (!mounted) {
        return;
      }
      setState(() {
        _loadDone = true;
        _svgRaw = s;
        _parser = TurkeySvgPathParser.fromSvgString(s);
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadDone = true;
        _loadError = e.toString();
      });
    }
  }

  void _clearHl() {
    _hlTimer?.cancel();
    _hlTimer = null;
    if (mounted) {
      setState(() => _highlightId = null);
    }
  }

  void _flashHighlight(String id) {
    _hlTimer?.cancel();
    setState(() => _highlightId = id);
    _hlTimer = Timer(const Duration(milliseconds: 450), _clearHl);
  }

  String? _digitsForHitId(String hitId) {
    final plate = plateCodeFromTrSvgId(hitId);
    final fromDb = findCityContactByPlateCode(
      widget.cityContacts ?? const <CityContact>[],
      plate,
    );
    if (fromDb != null) {
      return phoneDigitsForDial(fromDb.phone);
    }
    final fromJson = _phonesByPlate[plate];
    if (fromJson != null && fromJson.isNotEmpty) {
      return fromJson;
    }
    final k = ilKeyFromHitId(hitId);
    if (k != null) {
      final p = _phonesByIlKey[k];
      if (p != null && p.isNotEmpty) {
        return p;
      }
    }
    return emniyetTelefonHanesiId(hitId);
  }

  String? _labelForHitId(String hitId) {
    final plate = plateCodeFromTrSvgId(hitId);
    final fromDb = findCityContactByPlateCode(
      widget.cityContacts ?? const <CityContact>[],
      plate,
    );
    if (fromDb != null) {
      return fromDb.cityName;
    }
    final k = ilKeyFromHitId(hitId);
    return gosterimAdiForIlKey(k);
  }

  Future<void> _dialForHitId(String hitId) async {
    final digits = _digitsForHitId(hitId);
    if (digits == null || digits.isEmpty) {
      if (mounted && widget.showSnackBarOnTap) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu bölge için numara tanımlı değil.')),
        );
      }
      return;
    }
    _flashHighlight(hitId);
    if (mounted && widget.showSnackBarOnTap && !kIsWeb) {
      final ad = _labelForHitId(hitId);
      if (ad != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ad),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    if (!context.mounted) {
      return;
    }
    final ad = _labelForHitId(hitId);
    await dialOrShowNumberDialog(
      context,
      phone: digits,
      placeName: ad,
    );
  }

  @override
  void dispose() {
    _hlTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadDone) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Vektör harita yüklenemedi (tıklama için gerekli).\n$_loadError',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }
    if (_svgRaw == null) {
      return const SizedBox.shrink();
    }

    final parser = _parser;
    final useParser = parser != null && parser.entries.isNotEmpty;
    final vbW = parser?.viewBoxW ?? kDefaultMapCoordW;
    final vbH = parser?.viewBoxH ?? kDefaultMapCoordH;
    final surface = Theme.of(context).colorScheme.surface;
    final tint = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45);
    final hl = Theme.of(context).colorScheme.primary.withValues(alpha: 0.4);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: vbW,
              height: vbH,
              child: LayoutBuilder(
                builder: (context, inner) {
                  final size = Size(inner.maxWidth, inner.maxHeight);
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: surface),
                        if (widget.useRasterBackground)
                          Positioned.fill(
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                tint,
                                BlendMode.srcIn,
                              ),
                              child: Image.asset(
                                widget.rasterAssetPath,
                                fit: BoxFit.fill,
                                filterQuality: FilterQuality.medium,
                              ),
                            ),
                          )
                        else
                          Positioned.fill(
                            child: SvgPicture.string(
                              _svgRaw!,
                              fit: BoxFit.fill,
                              allowDrawingOutsideViewBox: true,
                              colorFilter: ColorFilter.mode(
                                tint,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        if (useParser && _highlightId != null)
                          Positioned.fill(
                            child: CustomPaint(
                              size: size,
                              painter: _PathHighlightPainter(
                                parser,
                                _highlightId,
                                hl,
                              ),
                            ),
                          ),
                        if (!useParser)
                          for (final z in kManualRegionFallback)
                            if (z.id == _highlightId)
                              Positioned(
                                left: z.l * size.width,
                                top: z.t * size.height,
                                width: z.w * size.width,
                                height: z.h * size.height,
                                child: IgnorePointer(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: hl,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                        Positioned.fill(
                          child: Listener(
                            behavior: HitTestBehavior.opaque,
                            onPointerDown: (e) {
                              String? hit;
                              if (useParser) {
                                hit = parser.hitId(e.localPosition, size);
                              } else {
                                hit = _manualHit(e.localPosition, size);
                              }
                              if (hit != null) {
                                unawaited(_dialForHitId(hit));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
