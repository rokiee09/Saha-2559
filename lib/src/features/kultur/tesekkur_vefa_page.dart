import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/theme/police_colors.dart';
import '../../common/widgets/police_filigran_layer.dart';
import 'tesekkur_vefa_content.dart';

const _assetPath = 'assets/kultur/tesekkur_vefa.txt';

/// Teşekkür ve vefa metni — süslü okuma ekranı.
class TesekkurVefaPage extends StatelessWidget {
  const TesekkurVefaPage({super.key});

  static Future<TesekkurVefaContent> _load() async {
    final raw = await rootBundle.loadString(_assetPath);
    return TesekkurVefaContent.parse(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vefa ve Teşekkür',
          style: TextStyle(
            color: PoliceColors.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<TesekkurVefaContent>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
            );
          }
          if (snap.hasError || !snap.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Metin yüklenemedi.\nassets/kultur/tesekkur_vefa.txt dosyasını kontrol edin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.9),
                  ),
                ),
              ),
            );
          }
          return _VefaReader(content: snap.data!);
        },
      ),
    );
  }
}

class _VefaReader extends StatelessWidget {
  const _VefaReader({required this.content});

  final TesekkurVefaContent content;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        const PoliceFiligranLayer(),
        ColoredBox(color: cs.surface.withValues(alpha: 0.9)),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              children: [
                const _OrnamentHeader(),
                const SizedBox(height: 20),
                Text(
                  content.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PoliceColors.gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: 3.2,
                    height: 1.25,
                  ),
                ),
                if (content.subtitle != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    content.subtitle!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PoliceColors.titleOnDark.withValues(alpha: 0.88),
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const _GoldDivider(),
                const SizedBox(height: 24),
                for (var i = 0; i < content.paragraphs.length; i++) ...[
                  if (i > 0) const SizedBox(height: 18),
                  _VefaParagraph(text: content.paragraphs[i]),
                ],
                if (content.footer != null) ...[
                  const SizedBox(height: 28),
                  const _GoldDivider(),
                  const SizedBox(height: 20),
                  Text(
                    content.footer!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PoliceColors.gold.withValues(alpha: 0.85),
                      fontSize: 14.5,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      height: 1.55,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                const PhosphorIcon(
                  PhosphorIconsRegular.medal,
                  color: PoliceColors.gold,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrnamentHeader extends StatelessWidget {
  const _OrnamentHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ornamentLine()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.diamond_outlined,
            size: 14,
            color: PoliceColors.gold.withValues(alpha: 0.75),
          ),
        ),
        const PhosphorIcon(
          PhosphorIconsFill.heart,
          color: PoliceColors.gold,
          size: 22,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.diamond_outlined,
            size: 14,
            color: PoliceColors.gold.withValues(alpha: 0.75),
          ),
        ),
        Expanded(child: _ornamentLine()),
      ],
    );
  }

  static Widget _ornamentLine() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            PoliceColors.gold.withValues(alpha: 0.55),
            PoliceColors.gold.withValues(alpha: 0.85),
          ],
        ),
      ),
    );
  }
}

class _GoldDivider extends StatelessWidget {
  const _GoldDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: PoliceColors.gold.withValues(alpha: 0.35),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '◆',
            style: TextStyle(
              color: PoliceColors.gold.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: PoliceColors.gold.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }
}

class _VefaParagraph extends StatelessWidget {
  const _VefaParagraph({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.length < 2) return const SizedBox.shrink();

    final first = text[0];
    final rest = text.substring(1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          first,
          style: TextStyle(
            color: PoliceColors.gold,
            fontSize: 42,
            fontWeight: FontWeight.w300,
            height: 0.95,
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              rest,
              style: TextStyle(
                color: PoliceColors.mevzuatBodyText.withValues(alpha: 0.95),
                fontSize: 16.5,
                height: 1.65,
                letterSpacing: 0.15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
