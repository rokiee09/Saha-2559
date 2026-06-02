import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/theme/police_colors.dart';

/// 6 haneli PIN girişi — düz metin gösterilmez.
class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.onCompleted,
    this.title = 'PIN girin',
    this.subtitle,
    this.errorText,
    this.enabled = true,
  });

  final void Function(String pin) onCompleted;
  final String title;
  final String? subtitle;
  final String? errorText;
  final bool enabled;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _digits = '';

  void _tap(String d) {
    if (!widget.enabled || _digits.length >= 6) return;
    HapticFeedback.lightImpact();
    setState(() => _digits += d);
    if (_digits.length == 6) {
      widget.onCompleted(_digits);
      setState(() => _digits = '');
    }
  }

  void _backspace() {
    if (_digits.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  void clear() => setState(() => _digits = '');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: PoliceColors.titleOnDark,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.95),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            final filled = i < _digits.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled
                    ? PoliceColors.primaryBlue
                    : PoliceColors.textMuted.withValues(alpha: 0.35),
                border: Border.all(
                  color: PoliceColors.accentMix(0.5),
                  width: 1,
                ),
              ),
            );
          }),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 14),
          Text(
            widget.errorText!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PoliceColors.gold.withValues(alpha: 0.95),
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 28),
        _numGrid(),
      ],
    );
  }

  Widget _numGrid() {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((k) {
              if (k.isEmpty) {
                return const SizedBox(width: 72, height: 56);
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Material(
                  color: PoliceColors.navy.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: widget.enabled
                        ? () {
                            if (k == '⌫') {
                              _backspace();
                            } else {
                              _tap(k);
                            }
                          }
                        : null,
                    child: SizedBox(
                      width: 72,
                      height: 56,
                      child: Center(
                        child: Text(
                          k,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: PoliceColors.titleOnDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
